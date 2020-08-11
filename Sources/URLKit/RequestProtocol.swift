import Foundation
import Alamofire

public protocol RequestProtocol {
    associatedtype Requestable: URLKit.Requestable

    var requestable: Requestable { get }
    var underlyingRequest: Alamofire.DataRequest? { get }
}

public extension RequestProtocol {
    func cancel() {
        underlyingRequest?.cancel()
    }
}
