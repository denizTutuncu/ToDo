//
//  GenericAuthenticationService.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/30/21.
//

import Foundation

public class GenericAuthenticationService<Response> {
    private var urlRequests: [URLRequest]
    private let client: HTTPClient
    private let mapper: (Data, HTTPURLResponse) throws -> Response
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case badResponse
        case unauthorized
        case unexpected
    }
    
    public typealias Result = Swift.Result<Response,Error>
    
    public init(client: HTTPClient, mapper: @escaping (Data, HTTPURLResponse) throws -> Response) {
        self.urlRequests = []
        self.client = client
        self.mapper = mapper
    }
    
    public func perform(request: UpdateAuthRequest, completion: @escaping (Result) -> Void) {

        let urlRequest = URLRequest(url: URL(string: "")!)
        
        switch secureURLRequestQueue(urlRequest) {
        case .none:
            break
            
        case let .some(urlRequest):
            client.send(urlRequest) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success((data, response)):
                    do {
                        completion(.success(try self.mapper(data, response)))
                    } catch {
                        completion(.failure(Error.connectivity))
                    }
                case .failure:
                    completion(.failure(Error.connectivity))
                }
                self.clearURLRequestQueue()
            }
        }
    }
    
    private func secureURLRequestQueue(_ urlRequest: URLRequest) -> URLRequest? {
        guard urlRequests.isEmpty else { return nil }
        updateQueueWith(urlRequest)
        return urlRequest
    }
    
    private func clearURLRequestQueue() {
        urlRequests = []
    }
    
    private func updateQueueWith(_ urlRequest: URLRequest) {
        urlRequests.append(urlRequest)
    }
    
}
