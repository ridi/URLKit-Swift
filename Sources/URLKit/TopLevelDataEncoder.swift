import Foundation
import Alamofire

public protocol TopLevelDataEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

extension JSONEncoder: TopLevelDataEncoder {}
extension PropertyListEncoder: TopLevelDataEncoder {}
