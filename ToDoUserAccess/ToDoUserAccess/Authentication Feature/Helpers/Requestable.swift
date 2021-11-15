//
//  Requestable.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 10/28/21.
//

import Foundation

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
}

public protocol Requestable {
    var baseURL: URL { get }
    var path: String { get }
    var headerField: [String:String] { get }
    var httpMethod: HTTPMethod { get }
    var httpBody: Data? { get }
    var queryParameters: [String:Any] { get }
    func makeURLRequest() -> URLRequest
}

public extension Requestable {
    
    var path: String {
        return ""
    }
    
    var headerField: [String:String] {
        return [:]
    }
    
    var httpMethod: HTTPMethod {
        .GET
    }
    
    var httpBody: Data? {
        nil
    }
    
    var queryParameters: [String:Any] {
        [:]
    }
    
    func makeURLRequest() -> URLRequest {
        let finalURL = baseURL.appendingPathComponent(path)
        var urlRequest =  URLRequest(url: finalURL)
        
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.httpBody = httpBody
       
        for header in headerField {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
                
        return urlRequest
    }
}
