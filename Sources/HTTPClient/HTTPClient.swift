import Foundation

typealias DataTaskResult = (data: Data, response: HTTPResponse)

public protocol HTTPClientRequestDispatcher {
    func execute(request: HTTPRequest) async throws -> HTTPResponse
    func request<ResponseType>(_ request: Request<ResponseType>) async throws -> ResponseType
}

public final class HTTPClient {
    // MARK: Lifecycle

    public init(session: URLSessionProtocol) {
        self.session = session
    }

    // MARK: Internal

    let session: URLSessionProtocol
}

extension HTTPClient: HTTPClientRequestDispatcher {
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
            let url = request.url
        else {
            throw HTTPError(
                code: .invalidRequest,
                request: request,
                response: nil,
                underlyingError: nil
            )
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        for (header, value) in request.headers {
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }

        if request.body.isEmpty == false {
            for (header, value) in request.body.additionalHeaders {
                urlRequest.addValue(value, forHTTPHeaderField: header)
            }

            do {
                urlRequest.httpBody = try request.body.encode()
            } catch {
                throw HTTPError(
                    code: .malformedRequest,
                    request: request,
                    response: nil,
                    underlyingError: nil
                )
            }
        }

        do {
            let (data, response) = try await session.dataTask(with: urlRequest)

            guard
                let response = response as? HTTPURLResponse
            else {
                throw HTTPError(
                    code: .malformedResponse,
                    request: request,
                    response: nil,
                    underlyingError: nil
                )
            }
            let httpResponse = HTTPResponse(
                request: request,
                response: response,
                body: data
            )
            return try processResponse(httpResponse, request: request)
        } catch {
            throw error
        }
    }
}

private extension HTTPClient {
    func processResponse(
        _ httpResponse: HTTPResponse,
        request: HTTPRequest
    ) throws -> HTTPResponse {
        let statusCode = httpResponse.status.code

        switch statusCode {
            case 500 ... 599:
                throw HTTPError(
                    code: .serverError,
                    request: request,
                    response: httpResponse,
                    underlyingError: nil
                )
            case 400 ... 499:
                throw HTTPError(
                    code: .clientError,
                    request: request,
                    response: httpResponse,
                    underlyingError: nil
                )
            default:
                return httpResponse
        }
    }
}
