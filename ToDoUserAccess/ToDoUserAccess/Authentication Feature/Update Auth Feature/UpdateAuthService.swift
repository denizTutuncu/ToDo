//
//  UpdateAuthService.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/30/21.
//

import Foundation

public struct UpdateAuthRequest {
    public let email: String
    public let password: String
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct UpdateAuthResponse: Equatable {
    public let email: String
    public init(email: String) {
        self.email = email
    }
}

public protocol UpdateAuthService {
    typealias Result = Swift.Result<UpdateAuthResponse, Error>
    func perform(request: UpdateAuthRequest, completion: @escaping (Result) -> Void)
}
