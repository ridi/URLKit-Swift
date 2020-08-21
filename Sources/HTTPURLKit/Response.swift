import Foundation
import Alamofire
import URLKit

public struct Response<Success, Failure: Swift.Error>: ResponseProtocol {
    public let result: Result<Success, Failure>

    public let underlyingResponse: Alamofire.AFDataResponse<Success>?
    public var response: HTTPURLResponse? { underlyingResponse?.response }
}
