//
//  HTTPClient.swift
//  ToDoUserAccess
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    /// The completion handler can be invoked in any tread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func send(_ request: URLRequest, completion: @escaping (Result) -> Void)
}
