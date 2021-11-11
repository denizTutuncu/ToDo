//
//  ToDoUserAccessLogInEndToEndTests.swift
//  ToDoUserAccessSignupEndToEndTests
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import XCTest
import ToDoUserAccess

class ToDoUserAccessLogInEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getResult() {
        case let .success(signupResponse):
            XCTAssertNotNil(signupResponse)
            XCTAssertNil(signupResponse.email)
            XCTAssertNotNil(signupResponse.token)
        case let .failure(error):
            print("ERROR is \(error)")
            XCTFail("Expected successful feed result, got \(error) instead.")
        default:
            XCTFail("Expected successful feed result, got no result instead.")
        }
    }
    
    //MARK:- Helpers
    private func getResult(file: StaticString = #file, line: UInt = #line) -> AuthenticationService.Result? {
        let requestable = testRequest()
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let signupService = RemoteLogInService(request: requestable, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(signupService, file: file, line: line)
        
        let exp = expectation(description: "Wait For Completion")
        
        var receivedResult: AuthenticationService.Result?
        signupService.auth { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    private func testRequest() -> URLRequest {
        let logInURL = URL(string: "https://ancient-plateau-22374.herokuapp.com/session")!
        var urlRequest = URLRequest(url: logInURL)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = makeRequestData()
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}

private func makeRequestData() -> Data {
    let json = [
        "email": "email@example.com",
        "password": "my_password",
    ].compactMapValues { $0 }
    
    let data = ["user" : json]
    return try! JSONSerialization.data(withJSONObject: data)
}
