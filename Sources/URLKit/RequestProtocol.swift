import Foundation
import Alamofire

public protocol RequestProtocol {
    var underlyingRequest: Alamofire.DataRequest? { get }
}

public extension RequestProtocol {
    func cancel() {
        underlyingRequest?.cancel()
    }
}
