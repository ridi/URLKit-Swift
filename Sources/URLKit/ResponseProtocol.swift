import Foundation

public protocol ResponseProtocol {
    associatedtype Success
    associatedtype Failure: Swift.Error

    var result: Result<Success, Failure> { get }
}
