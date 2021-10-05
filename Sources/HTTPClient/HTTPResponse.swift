import Foundation

public struct HTTPResponse {
    // MARK: Lifecycle

    public init(
        request: HTTPRequest,
        response: HTTPURLResponse,
        body: Data?
    ) {
        self.request = request
        self.body = body
        self.response = response
    }

    // MARK: Public

    public let request: HTTPRequest
    public let body: Data?

    public var status: HTTPStatus {
        HTTPStatus(code: response.statusCode)
    }

    public var message: String {
        HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
    }

    public var headers: [AnyHashable: Any] { response.allHeaderFields }

    // MARK: Private

    private let response: HTTPURLResponse
}
