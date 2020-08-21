import Foundation
import Alamofire

public struct Response<Success, Failure: Swift.Error>: ResponseProtocol {
    public let result: Result<Success, Failure>
    public let underlyingResponse: Alamofire.AFDataResponse<Success>?
}
