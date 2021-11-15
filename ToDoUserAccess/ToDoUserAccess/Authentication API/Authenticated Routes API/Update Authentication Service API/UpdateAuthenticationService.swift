//
//  UpdateAuthenticationService.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import Foundation

public final class UpdateAuthenticationService: AuthenticationService {
    private var urlRequests: [URLRequest]
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case badResponse
    }
    
    public typealias Result = AuthenticationService.Result
    
    public init(client: HTTPClient) {
        self.urlRequests = []
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
                    completion(UpdateAuthenticationService.map(data, from: response))
                case .failure:
                    completion(.failure(Error.connectivity))
                }
                self?.urlRequests = []
            }
        }        
    }
    
    private func secureURLRequestQueue(_ request: URLRequest) -> URLRequest? {
        guard urlRequests.isEmpty else { return nil }
        urlRequests.append(request)
        return request
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let logInResponseData = try UpdatedAuthResponseMapper
                .map(data, from: response)
            return .success(AuthenticationResponse(email: logInResponseData.email))
        } catch {
            return .failure(error)
        }
    }
}
