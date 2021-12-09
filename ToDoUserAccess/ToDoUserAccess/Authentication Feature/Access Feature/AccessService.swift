//
//  AccessService.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/30/21.
//

import Foundation

public struct AccessRequest {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct AccessResponse: Equatable {
    public let email: String
    public let token: String
    public init(email: String, token: String) {
        self.email = email
        self.token = token
    }
}

public protocol AccessService {
    typealias Result = Swift.Result<AccessResponse, Error>
    func perform(request: AccessRequest, completion: @escaping (Result) -> Void)
}
