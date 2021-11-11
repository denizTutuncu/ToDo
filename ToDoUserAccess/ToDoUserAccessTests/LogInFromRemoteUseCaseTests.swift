//
//  LogInFromRemoteUseCaseTests.swift
//  ToDoUserAccessTests
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import XCTest
import ToDoUserAccess

class LogInFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT(request: testRequest())
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_logIn_requestsDataFromURL() {
        let request = testRequest()
        
        //system under control
        let (sut, client) = makeSUT(request: request)
        //system under control does something
        sut.auth { _ in }
        //Then we check what we want
        XCTAssertEqual(client.requests, [request])
    }
    
    func test_logInTwice_requestsDataFromURLTwice() {
        let request = testRequest()
        
        let (sut, client) = makeSUT(request: request)
        sut.auth { _ in }
        sut.auth { _ in }
        
        XCTAssertEqual(client.requests, [request, request])
    }
    
    func test_logIn_deliversErrorOnClientError() {
        let request = testRequest()
        
        let (sut, client) = makeSUT(request: request)
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_logIn_deliversErrorOnNon201HTTPResponse() {
        let request = testRequest()
        
        let (sut, client) = makeSUT(request: request)
        let samples = [199, 200, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.badResponse)) {
                let json = makeResponseJSON(.none)
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_logIn_deliversErrorOn201HTTPResponseWithInvalidJSON() {
        let request = testRequest()
        
        let (sut, client) = makeSUT(request: request)
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("InvalidJSON".utf8)
            client.complete(withStatusCode: 201, data: invalidJSON)
        }
    }
    
    func test_logIn_deliversResponseDataOn201HTTPResponseWithValidJSON() {
        let request = testRequest()
        
        let (sut, client) = makeSUT(request: request)
        
        let responseData = makeResponse(token: "CvX9geXFYtLKED2Tre8zKgVT")
        
        expect(sut, toCompleteWith: .success(responseData.model), when: {
            let json = makeResponseJSON(responseData.json)
            client.complete(withStatusCode: 201, data: json)
        })
    }
    
    func test_logIn_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let requestable = testRequest()
        var sut: SignupAuthenticationService? = SignupAuthenticationService(request: requestable, client: client)
        
        
        var capturedResults = [SignupAuthenticationService.Result]()
        sut?.auth() { capturedResults.append($0) }
        
        sut = nil
        let responseData = makeResponse(token: "CvX9geXFYtLKED2Tre8zKgVT")
        client.complete(withStatusCode: 201, data: makeResponseJSON(responseData.json))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK:- helpers
    private func makeSUT(request: URLRequest, file: StaticString = #file, line: UInt = #line) -> (sut: LoginAuthenticationService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = LoginAuthenticationService(request: request, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: LoginAuthenticationService.Error) -> LoginAuthenticationService.Result {
        return .failure(error)
    }
    
    private func makeResponse(token: String) -> (model: AuthenticationResponse, json: [String:Any]) {
        let responseData = AuthenticationResponse(token: token)
        let json = [
            "token": token,
        ].compactMapValues { $0 }
        
        return (responseData, json)
    }
    
    private func makeResponseJSON(_ data: [String:Any]?) -> Data {
        let json = ["data" : data]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: LoginAuthenticationService, toCompleteWith expectedResult: LoginAuthenticationService.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.auth() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError as LoginAuthenticationService.Error), .failure(expectedError as LoginAuthenticationService.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(request: URLRequest, completion: (HTTPClient.Result) -> Void)]()
        
        var requests: [URLRequest] {
            return messages.map { $0.request }
        }
        
        func send(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((request, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requests[index].url!, statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
    
    private func testRequest() -> URLRequest {
        var urlRequest = URLRequest(url: anyURL())
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = anyData()
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}
