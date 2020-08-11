import Foundation

public struct Validation {
    private var _validation: (URLRequest?, URLResponse?, Data?) throws -> Void

    public static func custom(
        _ validation: @escaping (URLRequest?, URLResponse?, Data?) throws -> Void
    ) -> Validation {
        .init(validation: validation)
    }

    public init(validation: @escaping (URLRequest?, URLResponse?, Data?) throws -> Void) {
        _validation = validation
    }

    public func validate(request: URLRequest?, response: URLResponse?, data: Data?) throws {
        try _validation(request, response, data)
    }
}
