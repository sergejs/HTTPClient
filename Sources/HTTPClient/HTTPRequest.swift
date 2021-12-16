import Combine
import Foundation

public struct HTTPRequest {
    public init(
        method: HTTPMethod = .get,
        urlComponents: URLComponents,
        headers: [String: String] = [:],
        body: HTTPBody = EmptyBody()
    ) {
        self.method = method
        self.headers = headers
        self.body = body
        self.urlComponents = urlComponents
    }

    public init(
        method: HTTPMethod = .get,
        host: String? = "",
        path: String? = "",
        headers: [String: String] = [:],
        body: HTTPBody = EmptyBody()
    ) {
        self.method = method
        self.headers = headers
        self.body = body

        urlComponents?.scheme = "https"
        urlComponents?.host = host
        if let path = path {
            urlComponents?.path = path
        }
    }

    public var method: HTTPMethod
    public var headers: [String: String]
    public var body: HTTPBody

    var urlComponents: URLComponents? = URLComponents()
}

public extension HTTPRequest {
    var url: URL? { urlComponents?.url }
}

public struct Request<Response> {
    public let underlyingRequest: HTTPRequest
    public let decode: (HTTPResponse) throws -> Response

    public init(underlyingRequest: HTTPRequest, decode: @escaping (HTTPResponse) throws -> Response) {
        self.underlyingRequest = underlyingRequest
        self.decode = decode
    }
}

public extension Request where Response: Decodable {
    // request a value that's decoded using a JSON decoder
    init(underlyingRequest: HTTPRequest) {
        self.init(underlyingRequest: underlyingRequest, decoder: JSONDecoder())
    }

    // request a value that's decoded using the specified decoder
    // requires: import Combine
    init<D: TopLevelDecoder>(underlyingRequest: HTTPRequest, decoder: D) where D.Input == Data {
        self.init(
            underlyingRequest: underlyingRequest,
            decode: { try decoder.decode(Response.self, from: $0.body ?? Data()) }
        )
    }
}
