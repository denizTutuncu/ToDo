//
//  SharedTestHelpers.swift
//  ToDoUserAccessTests
//
//  Created by Deniz Tutuncu on 10/27/21.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("Any data".utf8)
}

func testURLRequest() -> URLRequest {
    var urlRequest = URLRequest(url: anyURL())
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = anyData()
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return urlRequest
}
