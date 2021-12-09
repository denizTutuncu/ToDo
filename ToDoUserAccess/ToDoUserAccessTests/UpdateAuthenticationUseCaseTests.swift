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
        //system under control
        let (sut, client) = makeSUT()

        let request = testUpdateAuthRequest().0
        let requestBody = testUpdateAuthRequest().1

        //system under control does something
        sut.perform(request: request) { _ in }
        //Then we check what we want
        XCTAssertEqual(client.requests.first?.url?.absoluteString, "https://ancient-plateau-22374.herokuapp.com/user")
        XCTAssertEqual(client.requests.first?.url?.path, "/user")
        XCTAssertEqual(client.requests.first?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(client.requests.first?.value(forHTTPHeaderField: "Authorization"), "Mpkz8ZC7Ghq9vKzS5WfAjoVy")
        XCTAssertEqual(client.requests.first?.httpBody, requestBody)
    }

    func test_performTwice_requestsDataFromURLOnlyOnceBeforeClientCompletes() {
        let request = testUpdateAuthRequest().0

        let (sut, client) = makeSUT()
        sut.perform(request: request) { _ in }
        sut.perform(request: request) { _ in }

        XCTAssertEqual(client.requests.count, 1)
    }

    func test_perform_canRequestDataFromURLAfterClientCompletes() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })

        let request = testUpdateAuthRequest().0
        sut.perform(request: request) { _ in }
        XCTAssertEqual(client.requests.count, 2)
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
            let data = makeResponseDataFromJSON(.none)
            client.complete(withStatusCode: errorCode, data: data)
        }
    }

    func test_perform_deliversBadResponseErrorOn404HTTPResponse() {
        let (sut, client) = makeSUT()
        let errorCode = 404

        expect(sut, toCompleteWith: failure(.badResponse)) {
            let data = makeResponseDataFromJSON(.none)
            client.complete(withStatusCode: errorCode, data: data)
        }
    }

    func test_perform_deliversUnexpectedErrorOnNonDefinedHTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.unexpected)) {
                let data = makeResponseDataFromJSON(.none)
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }

    func test_perform_deliversErrorOn201HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidData = Data("InvalidJSON".utf8)
            client.complete(withStatusCode: 200, data: invalidData)
        }
    }

    func test_perform_deliversResponseDataOn201HTTPResponseWithValidJSON() {
        let (sut, client) = makeSUT()

        let response = makeResponse(email: "updated@example.com")
        let model = response.model

        expect(sut, toCompleteWith: .success(model), when: {
            let validData = makeResponseDataFromJSON(response.json)
            client.complete(withStatusCode: 200, data: validData)
        })
    }

    func test_perform_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let fakeToken = "Mpkz8ZC7Ghq9vKzS5WfAjoVy"
        let authHTTPClient = AuthenticatedHTTPClient(decoratee: client, token: fakeToken)
        let request = testUpdateAuthRequest().0

        var sut: UpdateAuthenticationService? = UpdateAuthenticationService(client: authHTTPClient)

        var capturedResults = [UpdateAuthenticationService.Result]()
        sut?.perform(request: request) { capturedResults.append($0) }

        sut = nil
        let response = makeResponse(email: "updated@example.com")
        let validData = makeResponseDataFromJSON(response.json)

        client.complete(withStatusCode: 200, data: validData)

        XCTAssertTrue(capturedResults.isEmpty)
    }

    //MARK:- helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: UpdateAuthenticationService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let fakeToken = "Mpkz8ZC7Ghq9vKzS5WfAjoVy"
        let authClient = AuthenticatedHTTPClient(decoratee: client, token: fakeToken)
        let sut = UpdateAuthenticationService(client: authClient)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: UpdateAuthenticationService.Error) -> UpdateAuthenticationService.Result {
        return .failure(error)
    }

    private func makeResponse(email: String) -> (model: UpdateAuthResponse, json: [String:Any]) {
        let responseData = UpdateAuthResponse(email: email)
        let json = [
            "email": email,
        ].compactMapValues { $0 }

        return (responseData, json)
    }

    private func makeResponseDataFromJSON(_ data: [String:Any]?) -> Data {
        let json = ["data" : data]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(_ sut: UpdateAuthenticationService, toCompleteWith expectedResult: UpdateAuthenticationService.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let testUpdateAuthRequest = testUpdateAuthRequest()
        let urlRequest = testUpdateAuthRequest.0
        let exp = expectation(description: "Wait for perform completion")

        sut.perform(request: urlRequest) { receivedResult in
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
    
    private func testUpdateAuthRequest() -> (UpdateAuthRequest, Data) {
        let testRequest = UpdateAuthRequest(email: "email@example.com", password: "myNew_password")
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


