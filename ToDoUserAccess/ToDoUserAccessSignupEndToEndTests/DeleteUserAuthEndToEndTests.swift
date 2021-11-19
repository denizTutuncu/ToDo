//
//  DeleteUserAuthEndToEndTests.swift
//  DeleteUserAuthEndToEndTests
//
//  Created by Deniz Tutuncu on 11/18/21.
//


import XCTest
import ToDoUserAccess

class DeleteUserAuthEndToEndTests: XCTestCase {
    
//    func test_endToEndTestServerDELETEAuthResult_returnsExpectedResponse() {
//        switch getResult() {
//        case let .success(deletedAuthResponse):
//            XCTAssertNil(deletedAuthResponse)
//            XCTAssertNil(deletedAuthResponse.email)
//            XCTAssertNil(deletedAuthResponse.token)
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
        let deleteAuthenticationService = DeleteAuthenticationService(client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(deleteAuthenticationService, file: file, line: line)
        
        let exp = expectation(description: "Wait For Completion")
        
        var receivedResult: AuthenticationService.Result?
        deleteAuthenticationService.perform(urlRequest: urlRequest) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    private func testRequest() -> URLRequest {
        let deleteAuthRequest = URL(string: EndPointHelper.userEndPoint)!
        var urlRequest = URLRequest(url: deleteAuthRequest)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("RrQMPdQRP85oL1hX9jNKyR5v", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
    
}
