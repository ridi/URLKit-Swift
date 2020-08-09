import Foundation
import Alamofire
import URLKit

@_exported import struct URLKit.ParameterEncodingStrategy

extension ParameterEncodingStrategy {
    public static var json: ParameterEncodingStrategy { .json() }

    public static func json(encoder: JSONEncoder = JSONEncoder()) -> ParameterEncodingStrategy {
        .custom { (parameters, request) in
            let newRequest = try JSONParameterEncoder(encoder: encoder).encode(parameters, into: request)

            request = newRequest
        }
    }
}
