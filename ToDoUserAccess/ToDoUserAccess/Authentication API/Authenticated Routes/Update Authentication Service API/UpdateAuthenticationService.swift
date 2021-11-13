//
//  UpdateAuthenticationService.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import Foundation

public protocol URLRequestWithHTTPBody: AuthenticationService {
    var token: String { get }
}

public final class UpdateAuthenticationService: URLRequestWithHTTPBody {
    public let token: String
    private let request: URLRequest
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case badResponse
        case emptyToken
    }
    
    public typealias Result = AuthenticationService.Result
    
    public init(token: String, request: URLRequest, client: HTTPClient) {
        self.token = token
        self.request = request
        self.client = client
    }
    
    public func perform(completion: @escaping (Result) -> Void) {
        
        guard !token.isEmpty else { completion(.failure(Error.emptyToken)); return }
        
        // Maybe update the request here before pass it ?? //
        
        client.send(request) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(UpdateAuthenticationService.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
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
