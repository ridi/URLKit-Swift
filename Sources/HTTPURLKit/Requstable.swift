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
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.ridi_allHTTPHeaderFields = httpHeaders

        return try parameters.map { try URLEncodedFormParameterEncoder().encode($0, into: request) } ?? request
    }
}
