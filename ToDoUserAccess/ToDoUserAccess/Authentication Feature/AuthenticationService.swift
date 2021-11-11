//
//  UserSignUpSessioner.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import Foundation

public protocol AuthenticationService {
    typealias Result = Swift.Result<AuthenticationResponse, Error>
    func perform(completion: @escaping (Result) -> Void)
}
