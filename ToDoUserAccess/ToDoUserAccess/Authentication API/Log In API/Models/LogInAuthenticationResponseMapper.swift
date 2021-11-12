//
//  RemoteLogInResponseMapper.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import Foundation

class LogInAuthenticationResponseMapper {
    private struct Root: Decodable {
        let data: LogInAuthenticationResponse
    }
    
    private static var OK_Response: Int { return 201 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> LogInAuthenticationResponse {
        guard response.statusCode == OK_Response else {
            throw LoginAuthenticationService.Error.badResponse
        }
        guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw LoginAuthenticationService.Error.invalidData
        }
        return root.data
    }
}
