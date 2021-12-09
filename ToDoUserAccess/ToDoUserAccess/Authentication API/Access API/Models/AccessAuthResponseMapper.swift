//
//  RemoteSignUpResponseMapper.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import Foundation

final class AccessAuthResponseMapper {
    private struct Root: Decodable {
        let data: AccessAuthResponse
    }
    
    private static var OK_Response: Int { return 201 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> AccessAuthResponse {
        guard response.statusCode == OK_Response else {
            throw AccessAuthService.Error.badResponse
        }
        guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw AccessAuthService.Error.invalidData
        }
        return root.data
    }
}
