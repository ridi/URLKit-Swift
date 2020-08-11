import Foundation
import URLKit

public struct Response<Success, Failure: Swift.Error>: ResponseProtocol {
    public var result: Result<Success, Failure>
    public var response: HTTPURLResponse?
}
