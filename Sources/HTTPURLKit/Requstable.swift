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
    func asURLRequest(baseURL: URL? = nil) throws -> URLRequest {
        var request = URLRequest(
            url: URL(string: URL(string: url.absoluteString, relativeTo: Self.baseURL)!.absoluteString, relativeTo: baseURL)!
        )
        request.httpMethod = httpMethod.rawValue
        request.ridi_allHTTPHeaderFields = httpHeaders

        switch parameterEncodingStrategy {
        case .urlEncodedFormParameter(let urlEncodedFormStrategy):
            request = try parameters.map {
                try URLEncodedFormParameterEncoder(
                    destination: {
                        switch urlEncodedFormStrategy {
                        case .deferredToHTTPMethod:
                            return .methodDependent
                        case .queryString:
                            return .queryString
                        case .httpBody:
                            return .httpBody
                        }
                    }()
                ).encode($0, into: request)
            } ?? request
        case .json:
            request = try parameters.map {
                try JSONParameterEncoder().encode($0, into: request)
            } ?? request
        }

        return request
    }
}
