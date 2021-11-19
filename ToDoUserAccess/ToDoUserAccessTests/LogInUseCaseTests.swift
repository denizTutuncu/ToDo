//
//  LogInUseCaseTests.swift
//  ToDoUserAccessTests
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import XCTest
import ToDoUserAccess

class LogInUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_perform_requestsDataFromURL() {
        //system under control
        let (sut, client) = makeSUT()
        
        let urlRequest = testRequest()
        
        //system under control does something
        sut.perform(urlRequest: urlRequest) { _ in }
        //Then we check what we want
        XCTAssertEqual(client.requests, [urlRequest])
    }
    
    func test_performTwice_requestsDataFromURLOnlyOnceBeforeClientCompletes() {
        let urlRequest = testRequest()
        
        let (sut, client) = makeSUT()
        sut.perform(urlRequest: urlRequest) { _ in }
        sut.perform(urlRequest: urlRequest) { _ in }
        
        XCTAssertEqual(client.requests, [urlRequest])
    }
    
    func test_perform_canRequestDataFromURLAfterClientCompletes() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
        
        let urlRequest = testRequest()
        sut.perform(urlRequest: urlRequest) { _ in }
        XCTAssertEqual(client.requests, [urlRequest, urlRequest])
    }
    
    func test_perform_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_perform_deliversErrorOnNon201HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 200, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.badResponse)) {
                let json = makeResponseJSON(.none)
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_perform_deliversErrorOn201HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("InvalidJSON".utf8)
            client.complete(withStatusCode: 201, data: invalidJSON)
        }
    }
    
    func test_perform_deliversResponseDataOn201HTTPResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        
        let responseData = makeResponse(token: "CvX9geXFYtLKED2Tre8zKgVT")
        
        expect(sut, toCompleteWith: .success(responseData.model), when: {
            let json = makeResponseJSON(responseData.json)
            client.complete(withStatusCode: 201, data: json)
        })
    }
    
    func test_perform_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let urlRequest = testRequest()
        
        var sut: SignupAuthenticationService? = SignupAuthenticationService(client: client)
        
        var capturedResults = [SignupAuthenticationService.Result]()
        sut?.perform(urlRequest: urlRequest) { capturedResults.append($0) }
        
        sut = nil
        let responseData = makeResponse(token: "CvX9geXFYtLKED2Tre8zKgVT")
        client.complete(withStatusCode: 201, data: makeResponseJSON(responseData.json))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK:- helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LoginAuthenticationService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = LoginAuthenticationService(client: client)
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
        let urlRequest = testRequest()
        let exp = expectation(description: "Wait for perform completion")
        
        sut.perform(urlRequest: urlRequest) { receivedResult in
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
    
}
