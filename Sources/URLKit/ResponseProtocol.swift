import Foundation
import typealias Alamofire.AFDataResponse

public protocol ResponseProtocol {
    associatedtype Success
    associatedtype Failure: Error

    var result: Result<Success, Failure> { get }
    var underlyingResponse: Alamofire.AFDataResponse<Success>? { get }
}
