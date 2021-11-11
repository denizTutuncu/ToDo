//
//  RemoteLogInResponseMapper.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import Foundation

class RemoteLogInResponseMapper {
    private struct Root: Decodable {
        let data: RemoteLogInResponse
    }
    
    private static var OK_Response: Int { return 201 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteLogInResponse {
        guard response.statusCode == OK_Response else {
            throw RemoteLogInService.Error.badResponse
        }
        guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteLogInService.Error.invalidData
        }
        return root.data
    }
}
