//
//  LogInFromRemoteUseCaseTests.swift
//  ToDoUserAccessTests
//
//  Created by Deniz Tutuncu on 11/10/21.
//

import XCTest
import ToDoUserAccess

class RemoteLogInService: AuthenticationService {
    private let request: URLRequest
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case badResponse
    }
    
    public typealias Result = AuthenticationService.Result
    
    public init(request: URLRequest, client: HTTPClient) {
        self.request = request
        self.client = client
    }
    
    func auth(completion: @escaping (Result) -> Void) {
        client.send(request) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteLogInService.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let signUpResponseData = try RemoteLogInResponseMapper
                .map(data, from: response)
            return .success(AuthenticationResponse(token: signUpResponseData.token))
        } catch {
            return .failure(error)
        }
    }
    
    
}

class RemoteLogInResponseMapper {
    private struct Root: Decodable {
        let data: RemoteLogInResponse
    }
    
    private static var OK_Response: Int { return 201 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteLogInResponse {
        guard response.statusCode == OK_Response else {
            throw RemoteLogInService.Error.badResponse
        }
        guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteLogInService.Error.invalidData
        }
        return root.data
    }
}

struct RemoteLogInResponse: Decodable {
    let token: String
}

class LogInFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT(request: testRequest())
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_signUp_requestsDataFromURL() {
        let request = testRequest()
        
        //system under control
        let (sut, client) = makeSUT(request: request)
        //system under control does something
        sut.auth { _ in }
        //Then we check what we want
        XCTAssertEqual(client.requests, [request])
    }
    
    func test_signUpTwice_requestsDataFromURLTwice() {
        let request = testRequest()
        
        let (sut, client) = makeSUT(request: request)
        sut.auth { _ in }
        sut.auth { _ in }
        
        XCTAssertEqual(client.requests, [request, request])
    }
    
    func test_signUp_deliversErrorOnClientError() {
        let request = testRequest()
        
        let (sut, client) = makeSUT(request: request)
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_signUp_deliversErrorOnNon201HTTPResponse() {
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
    
    func test_signUp_deliversErrorOn201HTTPResponseWithInvalidJSON() {
        let request = testRequest()
        
        let (sut, client) = makeSUT(request: request)
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("InvalidJSON".utf8)
            client.complete(withStatusCode: 201, data: invalidJSON)
        }
    }
    
    func test_signUp_deliversResponseDataOn201HTTPResponseWithValidJSON() {
        let request = testRequest()
        
        let (sut, client) = makeSUT(request: request)
        
        let responseData = makeResponse(token: "CvX9geXFYtLKED2Tre8zKgVT")
        
        expect(sut, toCompleteWith: .success(responseData.model), when: {
            let json = makeResponseJSON(responseData.json)
            client.complete(withStatusCode: 201, data: json)
        })
    }
    
    func test_signUp_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let requestable = testRequest()
        var sut: RemoteSignupService? = RemoteSignupService(request: requestable, client: client)
        
        
        var capturedResults = [RemoteSignupService.Result]()
        sut?.auth() { capturedResults.append($0) }
        
        sut = nil
        let responseData = makeResponse(token: "CvX9geXFYtLKED2Tre8zKgVT")
        client.complete(withStatusCode: 201, data: makeResponseJSON(responseData.json))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK:- helpers
    private func makeSUT(request: URLRequest, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteLogInService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLogInService(request: request, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteLogInService.Error) -> RemoteLogInService.Result {
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
    
    private func expect(_ sut: RemoteLogInService, toCompleteWith expectedResult: RemoteLogInService.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.auth() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError as RemoteLogInService.Error), .failure(expectedError as RemoteLogInService.Error)):
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
