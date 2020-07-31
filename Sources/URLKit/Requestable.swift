import Foundation
import Alamofire

public struct EmptyParameters: Encodable {}
public struct EmptyResponse: Decodable {}

public enum ParameterEncodingStrategy {
    public enum URLEncodedFormStrategy {
        case deferredToHTTPMethod
        case queryString
        case httpBody
    }

    case urlEncodedFormParameter(URLEncodedFormStrategy)
    case json

    static var urlEncodedFormParameter: ParameterEncodingStrategy { .urlEncodedFormParameter(.deferredToHTTPMethod) }
}

public protocol Requestable {
    associatedtype Parameters: Encodable
    associatedtype ResponseBody: Decodable

    var parameters: Parameters? { get }
    var parameterEncodingStrategy: ParameterEncodingStrategy { get }

    static var responseBodyType: ResponseBody.Type? { get }

    static var baseURL: URL? { get }
    var url: URL { get }

    var requiresAuthentication: Bool { get }
}

public extension Requestable {
    var parameters: Parameters? { nil }
    var parameterEncodingStrategy: ParameterEncodingStrategy { .urlEncodedFormParameter }

    static var responseBodyType: ResponseBody.Type? { nil }

    static var baseURL: URL? { nil }

    var requiresAuthentication: Bool { false }
}

public extension Requestable where Self: Encodable {
    var parameters: Self { self }
}

public extension Requestable where Self: Decodable {
    static var responseType: Self.Type { self.self }
}

extension Requestable {
    func asURLRequest(baseURL: URL? = nil) throws -> URLRequest {
        var request = URLRequest(
            url: URL(string: URL(string: url.absoluteString, relativeTo: Self.baseURL)!.absoluteString, relativeTo: baseURL)!
        )

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
