import Foundation
import Alamofire

public protocol ResponseProtocol {
    associatedtype Success
    associatedtype Failure: Swift.Error

    var result: Result<Success, Failure> { get }
    var underlyingResponse: Alamofire.AFDataResponse<Success>? { get }
}
