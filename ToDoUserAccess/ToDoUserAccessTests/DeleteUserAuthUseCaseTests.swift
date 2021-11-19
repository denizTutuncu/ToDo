//
//  DeleteUserAuthUseCaseTests.swift
//  DeleteUserAuthUseCaseTests
//
//  Created by Deniz Tutuncu on 11/18/21.
//

import XCTest
import ToDoUserAccess

class DeleteUserAuthUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_perform_requestsDataFromURL() {
        //system under control
        let (sut, client) = makeSUT()
        
        let request = testRequest()
        
        //system under control does something
        sut.perform(urlRequest: request) { _ in }
        //Then we check what we want
        XCTAssertEqual(client.requests, [request])
    }
    
    func test_performTwice_requestsDataFromURLOnlyOnceBeforeClientCompletes() {
        let request = testRequest()
        
        let (sut, client) = makeSUT()
        sut.perform(urlRequest: request) { _ in }
        sut.perform(urlRequest: request) { _ in }
        
        XCTAssertEqual(client.requests, [request])
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
    
    func test_perform_deliversUnauthorizedErrorOn401HTTPResponse() {
        let (sut, client) = makeSUT()
        let errorCode = 401
    
        expect(sut, toCompleteWith: failure(.unauthorized)) {
            let responseAsEmptyData = emptyData()
            client.complete(withStatusCode: errorCode, data: responseAsEmptyData)
        }
    }
    
    func test_perform_deliversBadResponseErrorOn404HTTPResponse() {
        let (sut, client) = makeSUT()
        let errorCode = 404
    
        expect(sut, toCompleteWith: failure(.badResponse)) {
            let responseAsEmptyData = emptyData()
            client.complete(withStatusCode: errorCode, data: responseAsEmptyData)
        }
    }
    
    func test_perform_deliversUnexpectedErrorOnNonDefinedHTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 200, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.unexpected)) {
                let responseAsEmptyData = emptyData()
                client.complete(withStatusCode: code, data: responseAsEmptyData, at: index)
            }
        }
    }
    
    func test_perform_deliversResponseDataOn204HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let responseData = emptyResponseModel()
        
        expect(sut, toCompleteWith: .success(responseData), when: {
            let responseAsEmptyData = emptyData()
            client.complete(withStatusCode: 204, data: responseAsEmptyData)
        })
    }
    
    func test_perform_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let request = testRequest()
        
        var sut: DeleteAuthenticationService? = DeleteAuthenticationService(client: client)
        
        var capturedResults = [DeleteAuthenticationService.Result]()
        sut?.perform(urlRequest: request) { capturedResults.append($0) }
        
        sut = nil
        let responseAsEmptyData = emptyData()
        client.complete(withStatusCode: 204, data: responseAsEmptyData)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    
    //MARK:- helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: DeleteAuthenticationService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = DeleteAuthenticationService(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: DeleteAuthenticationService.Error) -> DeleteAuthenticationService.Result {
        return .failure(error)
    }
    
    private func emptyResponseModel() -> AuthenticationResponse {
        let responseData = AuthenticationResponse(email: nil, token: nil)
        return responseData
    }
    
    private func emptyData() -> Data {
        return Data()
    }
    
    private func expect(_ sut: DeleteAuthenticationService, toCompleteWith expectedResult: DeleteAuthenticationService.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let testURLRequest = testRequest()
        let exp = expectation(description: "Wait for perform completion")
        
        sut.perform(urlRequest: testURLRequest) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError as DeleteAuthenticationService.Error), .failure(expectedError as DeleteAuthenticationService.Error)):
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
