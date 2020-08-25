import Foundation
import class Alamofire.DataRequest

public protocol RequestProtocol {
    var underlyingRequest: Alamofire.DataRequest? { get }
}

public extension RequestProtocol {
    func cancel() {
        underlyingRequest?.cancel()
    }
}
