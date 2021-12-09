//
//  UpdateAuthEndToEndTests.swift
//  UpdateAuthEndToEndTests
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import XCTest
import ToDoUserAccess

class UpdateAuthEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerUpdateAuthResult_returnsExpectedResponse() {
        switch getResult() {
        case let .success(updatedAuthResponse):
            XCTAssertNotNil(updatedAuthResponse)
            XCTAssertNotNil(updatedAuthResponse.email)

        case let .failure(error):
            print("ERROR is \(error)")
            XCTFail("Expected successful feed result, got \(error) instead.")
        default:
            XCTFail("Expected successful feed result, got no result instead.")
        }
    }
    
    //MARK:- Helpers
    private func getResult(file: StaticString = #file, line: UInt = #line) -> UpdateAuthenticationService.Result? {
        let urlRequest = testRequest()
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))

        let fakeToken = "Mpkz8ZC7Ghq9vKzS5WfAjoVy"
        let authHTTPClient = AuthenticatedHTTPClient(decoratee: client, token: fakeToken)
        
        let updateAuthService = UpdateAuthenticationService(client: authHTTPClient)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(updateAuthService, file: file, line: line)
        
        let exp = expectation(description: "Wait For Completion")
        
        var receivedResult: UpdateAuthenticationService.Result?
        updateAuthService.perform(request: urlRequest) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    private func testRequest() -> (UpdateAuthRequest) {
        let testRequest = UpdateAuthRequest(email: "email@example.com", password: "myNew_password")
        return testRequest
    }

}
