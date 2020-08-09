import Foundation
import Alamofire

public struct ParameterEncodingStrategy<Parameters: Encodable> {
    private var _encoder: (Parameters?, inout URLRequest) throws -> Void

    public static func custom(
        _ encoder: @escaping (Parameters?, inout URLRequest) throws -> Void
    ) -> ParameterEncodingStrategy {
        .init(encoder: encoder)
    }

    private init(encoder: @escaping (Parameters?, inout URLRequest) throws -> Void) {
        _encoder = encoder
    }

    public func encode(_ parameters: Parameters?, into request: inout URLRequest) throws -> Void {
        try _encoder(parameters, &request)
    }
}

extension ParameterEncodingStrategy {
    public enum URLEncodedFormStrategy {
        case deferredToHTTPMethod
        case queryString
        case httpBody
    }

    public static var urlEncodedFormParameter: ParameterEncodingStrategy { .urlEncodedFormParameter(.deferredToHTTPMethod) }

    public static func urlEncodedFormParameter(_ urlEncodedFormStrategy: URLEncodedFormStrategy) -> ParameterEncodingStrategy {
        .custom { (parameters, request) in
            let newRequest = try URLEncodedFormParameterEncoder(
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
            ).encode(parameters, into: request)

            request = newRequest
        }
    }
}
