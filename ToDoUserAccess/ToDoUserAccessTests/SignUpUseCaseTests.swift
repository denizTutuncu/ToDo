//
//  SignUpUseCaseTests.swift
//  ToDoUserAccessTests
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import XCTest
import ToDoUserAccess

class SignUpUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_signUp_requestsDataFromURL() {
        let urlRequest = testRequest()
        
        //system under control
        let (sut, client) = makeSUT()
        //system under control does something
        sut.perform(urlRequest: urlRequest) { _ in }
        //Then we check what we want
        XCTAssertEqual(client.requests, [urlRequest])
    }
    
    func test_signUpTwice_requestsDataFromURLTwice() {
        let urlRequest = testRequest()
        
        let (sut, client) = makeSUT()
        sut.perform(urlRequest: urlRequest) { _ in }
        sut.perform(urlRequest: urlRequest) { _ in }
        
        XCTAssertEqual(client.requests, [urlRequest])
    }
    
    func test_signUp_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_signUp_deliversErrorOnNon201HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 200, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.badResponse)) {
                let json = makeResponseJSON(.none)
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_signUp_deliversErrorOn201HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("InvalidJSON".utf8)
            client.complete(withStatusCode: 201, data: invalidJSON)
        }
    }
    
    func test_signUp_deliversResponseDataOn201HTTPResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        
        let responseData = makeResponse(email: "email@example.com", token: "CvX9geXFYtLKED2Tre8zKgVT")
        
        expect(sut, toCompleteWith: .success(responseData.model), when: {
            let json = makeResponseJSON(responseData.json)
            client.complete(withStatusCode: 201, data: json)
        })
    }
    
    func test_signUp_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let urlRequest = testRequest()
        var sut: SignupAuthenticationService? = SignupAuthenticationService(client: client)
        
        
        var capturedResults = [SignupAuthenticationService.Result]()
        sut?.perform(urlRequest: urlRequest) { capturedResults.append($0) }
        
        sut = nil
        let responseData = makeResponse(email: "email@example.com", token: "CvX9geXFYtLKED2Tre8zKgVT")
        client.complete(withStatusCode: 201, data: makeResponseJSON(responseData.json))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    
    //MARK:- helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: SignupAuthenticationService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = SignupAuthenticationService(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: SignupAuthenticationService.Error) -> SignupAuthenticationService.Result {
        return .failure(error)
    }
    
    private func makeResponse(email: String, token: String) -> (model: AuthenticationResponse, json: [String:Any]) {
        let responseData = AuthenticationResponse(email: email, token: token)
        let json = [
            "email": email,
            "token": token,
        ].compactMapValues { $0 }
        
        return (responseData, json)
    }
    
    private func makeResponseJSON(_ data: [String:Any]?) -> Data {
        let json = ["data" : data]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: SignupAuthenticationService, toCompleteWith expectedResult: SignupAuthenticationService.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let urlRequest = testRequest()
        let exp = expectation(description: "Wait for perform completion")
        
        sut.perform(urlRequest: urlRequest) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError as SignupAuthenticationService.Error), .failure(expectedError as SignupAuthenticationService.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    private func testRequest() -> URLRequest {
        let urlRequest = URLRequest(url: anyURL())
//        urlRequest.httpMethod = "POST"
//        urlRequest.httpBody = anyData()
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}
