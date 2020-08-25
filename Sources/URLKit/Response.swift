import Foundation
import typealias Alamofire.AFDataResponse

public struct Response<Success, Failure: Error>: ResponseProtocol {
    public let result: Result<Success, Failure>
    public let underlyingResponse: Alamofire.AFDataResponse<Success>?
}
