//
//  RemoteSignUpReponse.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import Foundation

struct SignupAuthenticationResponse: Decodable {
    let email, token: String
}
