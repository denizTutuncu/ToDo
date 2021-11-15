//
//  SignupAuthenticationService.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import Foundation

public final class SignupAuthenticationService: AuthenticationService {    
    private var requests: [URLRequest]
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case badResponse
    }
    
    public typealias Result = AuthenticationService.Result
    
    public init(client: HTTPClient) {
        self.requests = []
        self.client = client
    }
    
    public func perform(urlRequest: URLRequest, completion: @escaping (Result) -> Void) {
        switch secureURLRequestQueue(urlRequest) {
        case .none:
            break
            
        case let .some(urlRequest):
            client.send(urlRequest) { [weak self] result in
                guard self != nil else { return }
                switch result {
                case let .success((data, response)):
                    completion(SignupAuthenticationService.map(data, from: response))
                case .failure:
                    completion(.failure(Error.connectivity))
                }
                self?.requests = []
            }
        }
        
    }
    
    private func secureURLRequestQueue(_ request: URLRequest) -> URLRequest? {
        guard requests.isEmpty else { return nil }
        requests.append(request)
        return request
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let signUpResponseData = try SignupAuthenticationResponseMapper
                .map(data, from: response)
            return .success(AuthenticationResponse(email: signUpResponseData.email, token: signUpResponseData.token))
        } catch {
            return .failure(error)
        }
    }
}
