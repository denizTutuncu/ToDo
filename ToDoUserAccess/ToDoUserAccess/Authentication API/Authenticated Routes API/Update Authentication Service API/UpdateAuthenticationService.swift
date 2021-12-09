//
//  UpdateAuthenticationService.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import Foundation

public final class UpdateAuthenticationService: UpdateAuthService {
    private var urlRequests: [URLRequest]
    private let client: AuthenticatedHTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case badResponse
        case unauthorized
        case unexpected
    }
    
    public typealias Result = UpdateAuthService.Result
    
    public init(client: AuthenticatedHTTPClient) {
        self.urlRequests = []
        self.client = client
    }
    
    public func perform(request: UpdateAuthRequest, completion: @escaping (Result) -> Void) {

        let urlRequest = createRequest(request)
        
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
                self?.clearURLRequestQueue()
            }
        }
    }
    
    private func createRequest(_ updateAuthRequest: UpdateAuthRequest) -> URLRequest {
        let baseURL = URL(string: "https://ancient-plateau-22374.herokuapp.com")!
        let finalURL = baseURL.appendingPathComponent("user")
        var urlRequest =  URLRequest(url: finalURL)
        
        urlRequest.httpMethod = "PUT"
        urlRequest.httpBody = makeRequestHttpBodyData(email: updateAuthRequest.email, password: updateAuthRequest.password)
        
        let headers = ["Content-Type":"application/json"]
        for header in headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
                
        return urlRequest
    }
    
    
    private func makeRequestHttpBodyData(email: String, password: String) -> Data {
        let json = [
            "email": email,
            "password": password,
        ].compactMapValues { $0 }
        
        let data = ["user" : json]
        return try! JSONSerialization.data(withJSONObject: data)
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
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let logInResponseData = try UpdatedAuthResponseMapper
                .map(data, from: response)
            return .success(UpdateAuthResponse(email: logInResponseData.email))
        } catch {
            return .failure(error)
        }
    }
}
