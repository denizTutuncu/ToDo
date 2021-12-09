//
//  AccessServiceUseCaseTestsUseCaseTests.swift
//  ToDoUserAccessTests
//
//  Created by Deniz Tutuncu on 10/26/21.
//

import XCTest
import ToDoUserAccess

class AccessServiceUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_perform_requestsDataFromURL() {
        //system under control
        let (sut, client) = makeSUT()
        
        let testRequest = testAccessRequest()
        
        //system under control does something
        sut.perform(request: testRequest.0) { _ in }
        //Then we check what we want
        XCTAssertEqual(client.requests.first?.url?.absoluteString, "https://ancient-plateau-22374.herokuapp.com/user")
        XCTAssertEqual(client.requests.first?.url?.path, "/user")
        XCTAssertEqual(client.requests.first?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(client.requests.first?.value(forHTTPHeaderField: "Authorization"), nil)

//        XCTAssertTrue(((client.requests.first?.allHTTPHeaderFields?.keys.contains("Content-Type")) != nil))
//        XCTAssertTrue(((client.requests.first?.value(forHTTPHeaderField: <#T##String#>)?.keys.contains("Authorization")) == nil))
    }
    
    func test_performTwice_requestsDataFromURLOnlyOnceBeforeClientCompletes() {
        let (sut, client) = makeSUT()
        let testRequest = testAccessRequest().0

        sut.perform(request: testRequest) { _ in }
        sut.perform(request: testRequest) { _ in }

        XCTAssertEqual(client.requests.count, 1)
    }

    func test_perform_canRequestDataFromURLAfterClientCompletes() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })

        let testRequest = testAccessRequest().0
        
        sut.perform(request: testRequest) { _ in }
        XCTAssertEqual(client.requests.count, 2)
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
                let data = makeResponseDataFromJSON(.none)
                client.complete(withStatusCode: code, data: data, at: index)
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

        let response = makeResponse(email: "email@example.com", token: "CvX9geXFYtLKED2Tre8zKgVT")

        expect(sut, toCompleteWith: .success(response.model), when: {
            let data = makeResponseDataFromJSON(response.json)
            client.complete(withStatusCode: 201, data: data)
        })
    }

    func test_perform_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let testRequest = testAccessRequest().0
        
        var sut: AccessAuthService? = AccessAuthService(client: client)


        var capturedResults = [AccessAuthService.Result]()
        sut?.perform(request: testRequest) { capturedResults.append($0) }

        sut = nil
        let response = makeResponse(email: "email@example.com", token: "CvX9geXFYtLKED2Tre8zKgVT")
        let data = makeResponseDataFromJSON(response.json)

        client.complete(withStatusCode: 201, data: data)

        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    
    //MARK:- helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: AccessAuthService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = AccessAuthService(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: AccessAuthService.Error) -> AccessAuthService.Result {
        return .failure(error)
    }
    
    private func makeResponse(email: String, token: String) -> (model: AccessResponse, json: [String:Any]) {
        let responseData = AccessResponse(email: email, token: token)
        let json = [
            "email": email,
            "token": token,
        ].compactMapValues { $0 }
        
        return (responseData, json)
    }
    
    private func makeResponseDataFromJSON(_ data: [String:Any]?) -> Data {
        let json = ["data" : data]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: AccessAuthService, toCompleteWith expectedResult: AccessAuthService.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let testAccess = testAccessRequest()
        let testRequest = testAccess.0
        
        let exp = expectation(description: "Wait for perform completion")
        
        sut.perform(request: testRequest) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError as AccessAuthService.Error), .failure(expectedError as AccessAuthService.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testAccessRequest() -> (AccessRequest, Data) {
        let testRequest = AccessRequest(email: "email@example.com", password: "my_password")
        let body = makeRequestHttpBodyData(email: testRequest.email, password: testRequest.password)
        return (testRequest, body)
    }
    
    private func makeRequestHttpBodyData(email: String, password: String) -> Data {
        let json = [
            "email": email,
            "password": password,
        ].compactMapValues { $0 }
        
        let data = ["user" : json]
        return try! JSONSerialization.data(withJSONObject: data)
    }
    
}
