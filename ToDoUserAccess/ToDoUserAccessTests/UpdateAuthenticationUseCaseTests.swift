//
//  UpdateAuthenticationUseCaseTests.swift
//  ToDoUserAccessTests
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import XCTest
import ToDoUserAccess

class UpdateAuthenticationUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_perform_requestsDataFromURL() {
        let request = testRequest()
        
        //system under control
        let (sut, client) = makeSUT()
        //system under control does something
        sut.perform(urlRequest: request) { _ in }
        //Then we check what we want
        XCTAssertEqual(client.requests, [request])
    }
    
    func test_performTwice_requestsDataFromURLOnce() {
        let request = testRequest()
        
        let (sut, client) = makeSUT()
        sut.perform(urlRequest: request) { _ in }
        sut.perform(urlRequest: request) { _ in }
        
        XCTAssertEqual(client.requests, [request])
    }
    

    func test_perform_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_perform_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

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
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }

    func test_perform_deliversResponseDataOn201HTTPResponseWithValidJSON() {
        let (sut, client) = makeSUT()

        let responseData = makeResponse(email: "updated@example.com")

        expect(sut, toCompleteWith: .success(responseData.model), when: {
            let json = makeResponseJSON(responseData.json)
            client.complete(withStatusCode: 200, data: json)
        })
    }

    func test_performh_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let request = testRequest()
        var sut: UpdateAuthenticationService? = UpdateAuthenticationService(client: client)


        var capturedResults = [UpdateAuthenticationService.Result]()
        sut?.perform(urlRequest: request) { capturedResults.append($0) }

        sut = nil
        let responseData = makeResponse(email: "updated@example.com")
        client.complete(withStatusCode: 200, data: makeResponseJSON(responseData.json))

        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK:- helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: UpdateAuthenticationService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = UpdateAuthenticationService(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: UpdateAuthenticationService.Error) -> UpdateAuthenticationService.Result {
        return .failure(error)
    }
    
    private func makeResponse(email: String) -> (model: AuthenticationResponse, json: [String:Any]) {
        let responseData = AuthenticationResponse(email: email)
        let json = [
            "email": email,
        ].compactMapValues { $0 }
        
        return (responseData, json)
    }
    
    private func makeResponseJSON(_ data: [String:Any]?) -> Data {
        let json = ["data" : data]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: UpdateAuthenticationService, toCompleteWith expectedResult: UpdateAuthenticationService.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let testURLRequest = testRequest()
        let exp = expectation(description: "Wait for perform completion")
        
        sut.perform(urlRequest: testURLRequest) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError as UpdateAuthenticationService.Error), .failure(expectedError as UpdateAuthenticationService.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testRequest() -> URLRequest {
        let urlRequest = URLRequest(url: anyURL())
        //        urlRequest.httpMethod = "PUT"
        //        urlRequest.httpBody = anyData()
        //        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //        urlRequest.setValue("RrQMPdQRP85oL1hX9jNKyR5v", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}


