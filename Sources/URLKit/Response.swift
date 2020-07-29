import Foundation

public struct Response<Success, Failure: Swift.Error>: ResponseProtocol {
    public var result: Result<Success, Failure>
}
