import Foundation
import class Alamofire.DataRequest

public class Request<Requstable: Requestable>: RequestProtocol {
    public var requestable: Requstable

    public internal(set) var underlyingRequest: Alamofire.DataRequest?

    init(requestable: Requstable) {
        self.requestable = requestable
    }
}
