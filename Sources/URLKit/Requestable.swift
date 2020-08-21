import Foundation
import Alamofire

public struct EmptyParameters: Encodable {}
public struct EmptyResponse: Decodable {}

extension EmptyResponse: Alamofire.EmptyResponse {
    public static func emptyValue() -> EmptyResponse {
        .init()
    }
}

public protocol Requestable {
    associatedtype Parameters: Encodable
    associatedtype ResponseBody: Decodable

    var parameters: Parameters? { get }
    var parameterEncodingStrategy: ParameterEncodingStrategy? { get }

    static var responseBodyType: ResponseBody.Type? { get }
    var responseBodyDecoder: TopLevelDataDecoder? { get }

    var url: URL { get }

    var requiresAuthentication: Bool { get }

    var validations: [Validation] { get }
}

public extension Requestable {
    var parameters: Parameters? { self as? Parameters }
    var parameterEncodingStrategy: ParameterEncodingStrategy? { nil }

    static var responseBodyType: ResponseBody.Type? { nil }
    var responseBodyDecoder: TopLevelDataDecoder? { nil }

    var requiresAuthentication: Bool { false }

    var validations: [Validation] { [] }
}

public extension Requestable where Self: Decodable {
    static var responseType: Self.Type { self.self }
}

extension Requestable {
    public func asURLRequest(baseURL: URL? = nil, parameterEncodingStrategy: ParameterEncodingStrategy) throws -> URLRequest {
        var request = URLRequest(
            url: URL(
                string: url.absoluteString,
                relativeTo: baseURL
            )!
        )

        try (self.parameterEncodingStrategy ?? parameterEncodingStrategy).encode(parameters, into: &request)
        
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
