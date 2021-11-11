//
//  SignupResponse.swift
//  ToDoiOS
//
//  Created by Deniz Tutuncu on 10/29/21.
//

import Foundation

struct TopLevelJSON: Codable {
    let data: SignupResponse
}

struct SignupResponse: Codable {
    let email: String
    let token: String
}

struct UserModel: Codable {
    let user: UserFields
}
struct UserFields: Codable {
    let email: String
    let password: String
}
