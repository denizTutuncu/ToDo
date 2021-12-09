//
//  AccessEndToEndTests.swift
//  AccessEndToEndTests
//
//  Created by Deniz Tutuncu on 10/28/21.
//

import XCTest
import ToDoUserAccess

class AccessEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerPOSTSignUpResult_returnsExpectedResponse() {
        switch getResult() {
        case let .success(signupResponse):
            XCTAssertNotNil(signupResponse)
            XCTAssertNotNil(signupResponse.email)
            XCTAssertNotNil(signupResponse.token)
            
        case let .failure(error):
            print("ERROR is \(error)")
            XCTFail("Expected successful feed result, got \(error) instead.")
        default:
            XCTFail("Expected successful feed result, got no result instead.")
        }
    }
    
    //MARK:- Helpers
    private func getResult(file: StaticString = #file, line: UInt = #line) -> AccessAuthService.Result? {
        let urlRequest = testRequest()
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let accessService = AccessAuthService(client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(accessService, file: file, line: line)
        
        let exp = expectation(description: "Wait For Completion")
        
        var receivedResult: AccessAuthService.Result?
        accessService.perform(request: urlRequest) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    //MARK: - Helpers
    private func testRequest() -> AccessRequest {
        let request = AccessRequest(email: "email@example.com", password: "my_password")
        return request
    }
    
}
