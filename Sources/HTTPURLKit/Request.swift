import Foundation
import URLKit
import Alamofire

public class Request<Requstable: Requestable>: RequestProtocol {
    public var requestable: Requstable

    public internal(set) var underlyingRequest: Alamofire.DataRequest?

    init(requestable: Requstable) {
        self.requestable = requestable
    }
}
