//
//  RemoteSignUpReponse.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import Foundation

// MARK: - DataClass
struct RemoteSignUpResponse: Decodable {
    let email, token: String
}
