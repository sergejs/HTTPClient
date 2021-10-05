@testable import HTTPClient
import Mocker
import XCTest

final class HTTPClientTests: XCTestCase {
    let sut = HTTPClient(session: URLSession.shared)

    override class func setUp() {
        super.setUp()

        Mock(
            url: URL(string: "https://www.google.com/100")!,
            dataType: .json,
            statusCode: 100,
            data: [.get: Data()]
        ).register()
        Mock(
            url: URL(string: "https://www.google.com/404")!,
            dataType: .json,
            statusCode: 404,
            data: [.get: Data()],
            requestError: HTTPClientSpecError.error
        ).register()
        Mock(
            url: URL(string: "https://www.google.com/200")!,
            dataType: .json,
            statusCode: 200,
            data: [.get: Data()]
        ).register()
        Mock(
            url: URL(string: "https://www.google.com/300")!,
            dataType: .json,
            statusCode: 300,
            data: [.get: Data()]
        ).register()
        Mock(
            url: URL(string: "https://www.google.com/400")!,
            dataType: .json,
            statusCode: 400,
            data: [.get: Data()]
        ).register()
        Mock(
            url: URL(string: "https://www.google.com/500")!,
            dataType: .json,
            statusCode: 500,
            data: [.get: Data()]
        ).register()
        let data = try! JSONEncoder().encode(TestCodable(value: "Test Value"))
        Mock(
            url: URL(string: "https://www.google.com/codable")!,
            dataType: .json,
            statusCode: 200,
            data: [.get: data]
        ).register()
    }

    func testBasic100() async throws {
        let request = HTTPRequest(
            method: .get,
            host: "www.google.com",
            path: "/100"
        )
        let result = try await sut.execute(request: request)
        XCTAssertEqual(result.status.isInformational, true)
    }

    func testBasic200() async throws {
        let request = HTTPRequest(
            method: .get,
            host: "www.google.com",
            path: "/200"
        )
        let result = try await sut.execute(request: request)
        XCTAssertEqual(result.status.isSuccessful, true)
    }

    func testBasic300() async throws {
        let request = HTTPRequest(
            method: .get,
            host: "www.google.com",
            path: "/300"
        )
        let result = try await sut.execute(request: request)
        XCTAssertEqual(result.status.isRedirection, true)
    }

    func testBasic4xx() async throws {
        let request = HTTPRequest(
            method: .get,
            host: "www.google.com",
            path: "/400"
        )
        do {
            _ = try await sut.execute(request: request)
        } catch {
            guard
                let error = error as? HTTPError
            else {
                XCTFail("Unexpected error")
                return
            }
            XCTAssertEqual(error.response?.status.isClientError, true)
            XCTAssertEqual(error.response?.body?.isEmpty, true)
        }
    }

    func testBasic500() async throws {
        let request = HTTPRequest(
            method: .get,
            host: "www.google.com",
            path: "/500"
        )
        do {
            _ = try await sut.execute(request: request)
        } catch {
            guard
                let error = error as? HTTPError
            else {
                XCTFail("Unexpected error")
                return
            }
            XCTAssertEqual(HTTPError.Code.serverError, error.code)
            XCTAssertEqual(error.response?.status.isServerError, true)
            XCTAssertEqual(error.response?.body?.isEmpty, true)
            XCTAssertEqual(error.response?.message, "internal server error")
        }
    }

    func testBasicWrongRequest() async throws {
        let body = JSONBody(EncodeWillFail())
        let request = HTTPRequest(
            method: .post,
            urlComponents: URLComponents(string: "https://www.google.com/500")!,
            headers: ["header": "value"],
            body: body
        )
        do {
            _ = try await sut.execute(request: request)
        } catch {
            guard
                let error = error as? HTTPError
            else {
                XCTFail("Unexpected error")
                return
            }
            XCTAssertEqual(HTTPError.Code.malformedRequest, error.code)
        }
    }

    func testBasicDecoding() async throws {
        let model = TestCodable(value: "Test Value")

        let httpRequest = HTTPRequest(
            method: .get,
            host: "www.google.com",
            path: "/codable"
        )

        let request: Request<TestCodable> = Request(underlyingRequest: httpRequest)

        do {
            let resultModel = try await sut.request(request)
            XCTAssertEqual(resultModel, model)
        } catch {
            XCTFail("Unexpected error")
        }
    }
}

enum HTTPClientSpecError: Error {
    case error
}

struct EncodeWillFail: Encodable {
    enum EncodeWillFailError: Error {
        case error
    }

    func encode(to encoder: Encoder) throws {
        throw EncodeWillFailError.error
    }
}

struct TestCodable: Codable, Equatable {
    let value: String
}
