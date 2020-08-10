import Foundation
import Alamofire

public struct EmptyParameters: Encodable {}
public struct EmptyResponse: Decodable {}

public protocol Requestable {
    associatedtype Parameters: Encodable
    associatedtype ResponseBody: Decodable

    var parameters: Parameters? { get }
    var parameterEncodingStrategy: ParameterEncodingStrategy<Parameters> { get }

    static var responseBodyType: ResponseBody.Type? { get }

    static var baseURL: URL? { get }
    var url: URL { get }

    var requiresAuthentication: Bool { get }

    var validations: [Validation] { get }
}

public extension Requestable {
    var parameters: Parameters? { self as? Parameters }
    var parameterEncodingStrategy: ParameterEncodingStrategy<Parameters> { .urlEncodedFormParameter }

    static var responseBodyType: ResponseBody.Type? { nil }

    static var baseURL: URL? { nil }

    var requiresAuthentication: Bool { false }

    var validations: [Validation] { [] }
}

public extension Requestable where Self: Decodable {
    static var responseType: Self.Type { self.self }
}

extension Requestable {
    func asURLRequest(baseURL: URL? = nil) throws -> URLRequest {
        var request = URLRequest(
            url: URL(
                string: URL(string: url.absoluteString, relativeTo: Self.baseURL)!.absoluteString,
                relativeTo: baseURL
            )!
        )

        try parameterEncodingStrategy.encode(parameters, into: &request)
        
        return request
    }

    public func validate(request: URLRequest?, response: URLResponse?, data: Data?) throws {
        try validations
            .map { $0.validate }
            .forEach {
                try $0(request, response, data)
            }
    }
}
