//
//  DeleteAuthenticationMapper.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 11/18/21.
//

import Foundation


class DeleteAuthenticationMapper {
    private static var OK_Response: Int { return 204 }
    
    static func map(_ response: HTTPURLResponse) throws {
        guard response.statusCode == OK_Response else {
            switch response.statusCode {
            case 401:
                throw DeleteAuthenticationService.Error.unauthorized
            case 404:
                throw DeleteAuthenticationService.Error.badResponse
            default:
                throw DeleteAuthenticationService.Error.unexpected
            }
        }
    }
    
}
