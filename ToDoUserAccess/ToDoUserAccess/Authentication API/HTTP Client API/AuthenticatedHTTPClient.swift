//
//  AuthenticatedHTTPClient.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/30/21.
//

import Foundation

private extension AuthenticatedHTTPClient {
    
    private func hasToken(_ token: String) throws {
        guard !token.isEmpty else { throw Error.invalidToken }
    }
    
    private func signRequest(_ request: URLRequest, with token: String) -> URLRequest {
        var urlRequest = request
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}

public class AuthenticatedHTTPClient: HTTPClient {
    
    private let decoratee: HTTPClient
    private var token: String
    
    public init(decoratee: HTTPClient, token: String = "") {
        self.decoratee = decoratee
        self.token = token
    }
    
    private enum Error: Swift.Error {
        case connectivity
        case invalidToken
    }
    
    public func send(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        do {
            try hasToken(token)
        } catch let err {
            completion(.failure(err))
            return
        }
        
        decoratee.send( signRequest(request, with: token) ) { result in
            switch result {
            case let .success((data, response)):
                completion(.success((data, response)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
}
