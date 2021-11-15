//
//  ToDoUserAccessSignupEndToEndTests.swift
//  ToDoUserAccessSignupEndToEndTests
//
//  Created by Deniz Tutuncu on 10/28/21.
//

import XCTest
import ToDoUserAccess

class ToDoUserAccessSignupEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerPOSTSignUpResult_matchesFixedTestAccountData() {
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
    private func getResult(file: StaticString = #file, line: UInt = #line) -> AuthenticationService.Result? {
        let urlRequest = testRequest()
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let signupService = SignupAuthenticationService(client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(signupService, file: file, line: line)
        
        let exp = expectation(description: "Wait For Completion")
        
        var receivedResult: AuthenticationService.Result?
        signupService.perform(urlRequest: urlRequest) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    //MARK: - Helpers
    private func testRequest() -> URLRequest {
        let signUpURL = URL(string: EndPointHelper.signUpEndPoint)!
        var urlRequest = URLRequest(url: signUpURL)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = makeRequestHttpBodyData()
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    //    private struct TestRequest: Requestable {
    //        var baseURL: URL { URL(string: "https://ancient-plateau-22374.herokuapp.com")! }
    //        var path: String { "/user"}
    //        var httpMethod: HTTPMethod { .POST }
    //        var httpBody: Data? = makeRequestData()
    //        var headerField: [String : String] {
    //            ["Content-Type":"application/json"]
    //        }
    //    }
    
    private func makeRequestHttpBodyData() -> Data {
        let json = [
            "email": "email@example.com",
            "password": "my_password",
        ].compactMapValues { $0 }
        
        let data = ["user" : json]
        return try! JSONSerialization.data(withJSONObject: data)
    }
    
}
