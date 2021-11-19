//
//  UpdatedAuthResponseMapper.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import Foundation

class UpdatedAuthResponseMapper {
    private struct Root: Decodable {
        let data: UpdatedAuthResponse
    }
        
    private static var OK_Response: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> UpdatedAuthResponse {
        guard response.statusCode == OK_Response else {
            switch response.statusCode {
            case 401:
                throw UpdateAuthenticationService.Error.unauthorized
            case 404:
                throw UpdateAuthenticationService.Error.badResponse
            default:
                throw UpdateAuthenticationService.Error.unexpected
            }
        }
        guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw UpdateAuthenticationService.Error.invalidData
        }
        return root.data
    }
    
}

