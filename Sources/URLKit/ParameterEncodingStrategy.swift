import Foundation
import Alamofire

public protocol ParameterEncoder {
    func encode<Parameters: Encodable>(_ parameters: Parameters?, into request: inout URLRequest) throws
}

struct CustomParameterEncoder: ParameterEncoder {
    func encode<Parameters: Encodable>(_ parameters: Parameters?, into request: inout URLRequest) throws {
        try _encoder(parameters, &request)
    }

    fileprivate var _encoder: (Encodable?, inout URLRequest) throws -> Void
}

public struct ParameterEncodingStrategy {
    private var _encoder: ParameterEncoder

    public static func custom(
        _ encoder: @escaping (Encodable?, inout URLRequest) throws -> Void
    ) -> ParameterEncodingStrategy {
        .init(encoder: CustomParameterEncoder(_encoder: encoder))
    }

    public init(encoder: ParameterEncoder) {
        _encoder = encoder
    }

    public func encode<Parameters: Encodable>(_ parameters: Parameters?, into request: inout URLRequest) throws {
        try _encoder.encode(parameters, into: &request)
    }
}

extension URLEncodedFormParameterEncoder: ParameterEncoder {
    public func encode<Parameters>(
        _ parameters: Parameters?,
        into request: inout URLRequest
    ) throws where Parameters: Encodable {
        request = try encode(parameters, into: request)
    }
}

extension ParameterEncodingStrategy {
    public enum URLEncodedFormStrategy {
        case deferredToHTTPMethod
        case queryString
        case httpBody
    }

    public static var urlEncodedFormParameter: ParameterEncodingStrategy {
        .urlEncodedFormParameter(urlEncodedFormStrategy: .deferredToHTTPMethod)
    }

    public static func urlEncodedFormParameter(
        encoder: URLEncodedFormEncoder = URLEncodedFormEncoder(),
        urlEncodedFormStrategy: URLEncodedFormStrategy
    ) -> ParameterEncodingStrategy {
        self.init(
            encoder: URLEncodedFormParameterEncoder(
                encoder: encoder,
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
            )
        )
    }
}
