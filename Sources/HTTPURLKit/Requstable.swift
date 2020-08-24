import Foundation
import URLKit
import Alamofire

@_exported import struct URLKit.EmptyParameters
@_exported import struct URLKit.EmptyResponse

public protocol Requestable: URLKit.Requestable {
    var httpMethod: URLRequest.HTTPMethod { get }
    var httpHeaders: [URLRequest.HTTPHeaderFieldName: String]? { get }
}

public extension Requestable {
    var httpMethod: URLRequest.HTTPMethod {
        .get
    }

    var httpHeaders: [URLRequest.HTTPHeaderFieldName: String]? {
        nil
    }
}

extension Requestable {
    // swiftlint:disable:next function_default_parameter_at_end
    public func asURLRequest(
        baseURL: URL? = nil,
        parameterEncodingStrategy: ParameterEncodingStrategy
    ) throws -> URLRequest {
        var request = URLRequest(
            url: URL(
                string: url.absoluteString,
                relativeTo: baseURL
            )!
        )
        request.httpMethod = httpMethod.rawValue
        request.urlk_allHTTPHeaderFields = httpHeaders

        try (self.parameterEncodingStrategy ?? parameterEncodingStrategy).encode(parameters, into: &request)

        return request
    }
}
