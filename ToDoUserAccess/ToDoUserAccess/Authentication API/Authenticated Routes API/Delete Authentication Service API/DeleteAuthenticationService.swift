////
////  DeleteAuthenticationService.swift
////  ToDoUserAccess
////
////  Created by Deniz Tutuncu on 11/18/21.
////
//
//import Foundation
//
//public final class DeleteAuthenticationService: AuthenticationService {
//    private var urlRequests: [URLRequest]
//    private let client: HTTPClient
//    
//    public enum Error: Swift.Error {
//        case connectivity
//        case badResponse
//        case unauthorized
//        case unexpected
//    }
//    
//    public typealias Result = AuthenticationService.Result
//    
//    public init(client: HTTPClient) {
//        self.urlRequests = []
//        self.client = client
//    }
//    
//    public func perform(urlRequest: URLRequest, completion: @escaping (Result) -> Void) {
//        switch secureURLRequestQueue(urlRequest) {
//        case .none:
//            break
//            
//        case let .some(urlRequest):
//            client.send(urlRequest) { [weak self] result in
//                guard self != nil else { return }
//                switch result {
//                case let .success((_, response)):
//                    completion(DeleteAuthenticationService.map(response))
//                case .failure:
//                    completion(.failure(Error.connectivity))
//                }
//                self?.clearURLRequestQueue()
//            }
//        }
//    }
//
//    private func secureURLRequestQueue(_ urlRequest: URLRequest) -> URLRequest? {
//        guard urlRequests.isEmpty else { return nil }
//        updateQueueWith(urlRequest)
//        return urlRequest
//    }
//    
//    private func clearURLRequestQueue() {
//        urlRequests = []
//    }
//    
//    private func updateQueueWith(_ urlRequest: URLRequest) {
//        urlRequests.append(urlRequest)
//    }
//    
//    private static func map(_ response: HTTPURLResponse) -> Result {
//        do {
//            try DeleteAuthenticationMapper
//                .map(response)
//            return .success(AuthenticationResponse(email: nil, token: nil))
//        } catch {
//            return .failure(error)
//        }
//    }
//}
