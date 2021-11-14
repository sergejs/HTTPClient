//
//  MockHTTPClient.swift
//
//
//  Created by Sergejs Smirnovs on 14.11.21.
//

import Foundation

class MockHTTPClient: HTTPClientRequestDispatcher {
    func request<ResponseType>(_ request: Request<ResponseType>) async throws -> ResponseType {
        let result = try await execute(request: request.underlyingRequest)
        do {
            return try request.decode(result)
        } catch {
            throw HTTPError(
                code: .undableToDecode,
                request: request.underlyingRequest,
                response: result,
                underlyingError: error
            )
        }
    }

    func execute(request: HTTPRequest) async throws -> HTTPResponse {
        guard
            !nextHandlers.isEmpty
        else {
            throw HTTPError(code: .invalidRequest, request: request)
        }

        let nextHandler = nextHandlers.removeFirst()
        let result = nextHandler(request)
        switch result {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    // MARK: Internal

    typealias HTTPResult = Result<HTTPResponse, HTTPError>
    typealias MockHandler = (HTTPRequest) -> HTTPResult

    func then(_ handler: @escaping MockHandler) {
        nextHandlers.append(handler)
    }

    // MARK: Private

    private var nextHandlers = [MockHandler]()
}
