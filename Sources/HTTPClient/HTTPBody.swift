import Foundation

public protocol HTTPBody {
    var isEmpty: Bool { get }
    var additionalHeaders: [String: String] { get }
    func encode() throws -> Data
}

public extension HTTPBody {
    func encode() throws -> Data { Data() }
}

public struct EmptyBody: HTTPBody {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public let isEmpty = true

    public var additionalHeaders: [String: String] { [:] }
}

public struct JSONBody: HTTPBody {
    // MARK: Lifecycle

    public init<T: Encodable>(
        _ value: T,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        encodeClosure = { try encoder.encode(value) }
    }

    // MARK: Public

    public let isEmpty: Bool = false
    public var additionalHeaders = [
        "Content-Type": "application/json; charset=utf-8",
    ]

    public func encode() throws -> Data { try encodeClosure() }

    // MARK: Private

    private let encodeClosure: () throws -> Data
}

public struct FormBody: HTTPBody {
    public var isEmpty: Bool { values.isEmpty }
    public let additionalHeaders = [
        "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
    ]

    private let values: [URLQueryItem]

    public init(_ values: [URLQueryItem]) {
        self.values = values
    }

    public init(_ values: [String: String]) {
        let queryItems = values.map { URLQueryItem(name: $0.key, value: $0.value) }
        self.init(queryItems)
    }

    public func encode() throws -> Data {
        let pieces = values.map(urlEncode)
        let bodyString = pieces.joined(separator: "&")
        return Data(bodyString.utf8)
    }

    private func urlEncode(_ queryItem: URLQueryItem) -> String {
        let name = urlEncode(queryItem.name)
        let value = urlEncode(queryItem.value ?? "")
        return "\(name)=\(value)"
    }

    private func urlEncode(_ string: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
    }
}
