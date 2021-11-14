//
//  MockHTTPClient.swift
//
//
//  Created by Sergejs Smirnovs on 14.11.21.
//

import Foundation

public class MockHTTPClient: HTTPClientRequestDispatcher {
    public init() {}

    public func request<ResponseType>(_ request: Request<ResponseType>) async throws -> ResponseType {
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

    public func execute(request: HTTPRequest) async throws -> HTTPResponse {
        guard
            !nextHandlers.isEmpty
        else {
            throw HTTPError(code: .invalidRequest, request: request)
        }

        let nextHandler = nextHandlers.removeFirst()
        let result = nextHandler(request)
        switch result {
            case let .success(result):
                return result
            case let .failure(error):
                throw error
        }
    }

    // MARK: Internal

    public typealias HTTPResult = Result<HTTPResponse, HTTPError>
    public typealias MockHandler = (HTTPRequest) -> HTTPResult

    func then(_ handler: @escaping MockHandler) {
        nextHandlers.append(handler)
    }

    // MARK: Private

    private var nextHandlers = [MockHandler]()
}
