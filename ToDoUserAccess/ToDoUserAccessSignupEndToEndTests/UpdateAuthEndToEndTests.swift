//
//  UpdateAuthEndToEndTests.swift
//  UpdateAuthEndToEndTests
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import XCTest
import ToDoUserAccess

class UpdateAuthEndToEndTests: XCTestCase {
    
//    func test_endToEndTestServerUpdateAuthResult_returnsExpectedResponse() {
//        switch getResult() {
//        case let .success(updatedAuthResponse):
//            XCTAssertNotNil(updatedAuthResponse)
//            XCTAssertNotNil(updatedAuthResponse.email)
//            XCTAssertNil(updatedAuthResponse.token)
//
//        case let .failure(error):
//            print("ERROR is \(error)")
//            XCTFail("Expected successful feed result, got \(error) instead.")
//        default:
//            XCTFail("Expected successful feed result, got no result instead.")
//        }
//    }
    
    //MARK:- Helpers
    private func getResult(file: StaticString = #file, line: UInt = #line) -> AuthenticationService.Result? {
        let urlRequest = testRequest()
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let updateAuthService = UpdateAuthenticationService(client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(updateAuthService, file: file, line: line)
        
        let exp = expectation(description: "Wait For Completion")
        
        var receivedResult: AuthenticationService.Result?
        updateAuthService.perform(urlRequest: urlRequest) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    private func testRequest() -> URLRequest {
        let updateAuthRequest = URL(string: EndPointHelper.userEndPoint)!
        var urlRequest = URLRequest(url: updateAuthRequest)
        urlRequest.httpMethod = "PUT"
        urlRequest.httpBody = makeRequestHttpBodyData()
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("RrQMPdQRP85oL1hX9jNKyR5v", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
    private func makeRequestHttpBodyData() -> Data {
        let json = [
            "email": "updated@example.com",
            "password": "my_password",
        ].compactMapValues { $0 }
        
        let data = ["user" : json]
        return try! JSONSerialization.data(withJSONObject: data)
    }
}
