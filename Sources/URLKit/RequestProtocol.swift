import Foundation

public protocol RequestProtocol {
    associatedtype Requestable: URLKit.Requestable

    var requestable: Requestable { get }

    func cancel()
}
