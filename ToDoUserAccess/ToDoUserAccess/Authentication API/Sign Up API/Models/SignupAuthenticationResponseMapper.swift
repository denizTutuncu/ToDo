//
//  RemoteSignUpResponseMapper.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import Foundation

final class SignupAuthenticationResponseMapper {
    private struct Root: Decodable {
        let data: SignupAuthenticationResponse
    }
    
    private static var OK_Response: Int { return 201 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> SignupAuthenticationResponse {
        guard response.statusCode == OK_Response else {
            throw SignupAuthenticationService.Error.badResponse
        }
        guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw SignupAuthenticationService.Error.invalidData
        }
        return root.data
    }
}
