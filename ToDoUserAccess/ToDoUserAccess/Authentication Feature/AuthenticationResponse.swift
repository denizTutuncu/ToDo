//
//  AuthenticationResponse.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import Foundation

public struct AuthenticationResponse: Equatable {
    public let email: String?
    public let token: String?
    public init(email: String? = nil, token: String? = nil) {
        self.email = email
        self.token = token
    }
}
