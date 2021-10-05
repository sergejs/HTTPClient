import Foundation

public struct HTTPStatus {
    public var code: Int
}

public extension HTTPStatus {
    enum Category: String {
        case informational
        case successful
        case redirection
        case clientError
        case serverError

        // MARK: Internal

        var range: ClosedRange<Int> {
            switch self {
                case .informational: return 100 ... 199
                case .successful: return 200 ... 299
                case .redirection: return 300 ... 399
                case .clientError: return 400 ... 499
                case .serverError: return 500 ... 599
            }
        }
    }

    var family: Category {
        switch code {
            case Category.informational.range:
                return .informational
            case Category.successful.range:
                return .successful
            case Category.redirection.range:
                return .redirection
            case Category.clientError.range:
                return .clientError
            case Category.serverError.range:
                return .serverError
            default:
                return .serverError
        }
    }

    var isInformational: Bool { family == .informational }
    var isSuccessful: Bool { family == .successful }
    var isRedirection: Bool { family == .redirection }
    var isClientError: Bool { family == .clientError }
    var isServerError: Bool { family == .serverError }
}
