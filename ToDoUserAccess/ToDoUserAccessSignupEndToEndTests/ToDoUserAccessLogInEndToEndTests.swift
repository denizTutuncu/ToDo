//
//  ToDoUserAccessLogInEndToEndTests.swift
//  ToDoUserAccessSignupEndToEndTests
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import XCTest
import ToDoUserAccess

class ToDoUserAccessLogInEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerPOSTLogInResult_matchesFixedTestAccountData() {
        switch getResult() {
        case let .success(loginResponse):
            XCTAssertNotNil(loginResponse)
            XCTAssertNil(loginResponse.email)
            XCTAssertNotNil(loginResponse.token)
        case let .failure(error):
            print("ERROR is \(error)")
            XCTFail("Expected successful feed result, got \(error) instead.")
        default:
            XCTFail("Expected successful feed result, got no result instead.")
        }
    }
    
    //MARK:- Helpers
    private func getResult(file: StaticString = #file, line: UInt = #line) -> AuthenticationService.Result? {
        let request = testRequest()
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loginService = LoginAuthenticationService(request: request, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loginService, file: file, line: line)
        
        let exp = expectation(description: "Wait For Completion")
        
        var receivedResult: AuthenticationService.Result?
        loginService.perform { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    private func testRequest() -> URLRequest {
        let logInURL = URL(string: EndPointHelper.logInEndpoint)!
        var urlRequest = URLRequest(url: logInURL)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = makeRequestHttpBodyData()
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}

private func makeRequestHttpBodyData() -> Data {
    let json = [
        "email": "email@example.com",
        "password": "my_password",
    ].compactMapValues { $0 }
    
    let data = ["user" : json]
    return try! JSONSerialization.data(withJSONObject: data)
}
