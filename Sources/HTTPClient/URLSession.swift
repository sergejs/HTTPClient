import Foundation

public protocol URLSessionProtocol {
    func dataTask(with request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
    public func dataTask(with request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
}

public protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
