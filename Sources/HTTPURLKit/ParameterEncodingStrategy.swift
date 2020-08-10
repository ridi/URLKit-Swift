import Foundation
import Alamofire
import URLKit

@_exported import protocol URLKit.ParameterEncoder
@_exported import struct URLKit.ParameterEncodingStrategy

extension JSONParameterEncoder: ParameterEncoder {
    public func encode<Parameters>(_ parameters: Parameters?, into request: inout URLRequest) throws where Parameters : Encodable {
        request = try encode(parameters, into: request)
    }
}

extension ParameterEncodingStrategy {
    public static var json: ParameterEncodingStrategy { .json() }

    public static func json(encoder: JSONEncoder = JSONEncoder()) -> ParameterEncodingStrategy {
        self.init(encoder: JSONParameterEncoder(encoder: encoder))
    }
}
