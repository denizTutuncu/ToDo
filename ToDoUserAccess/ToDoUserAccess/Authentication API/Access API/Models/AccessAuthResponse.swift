//
//  RemoteSignUpReponse.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import Foundation

struct AccessAuthResponse: Decodable {
    let email, token: String
}
