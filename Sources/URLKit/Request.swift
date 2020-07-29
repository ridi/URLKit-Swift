import Foundation
import Alamofire

public struct Request<Requstable: Requestable>: RequestProtocol {
    public var requestable: Requstable

    var _requestResult: Result<Alamofire.DataRequest, Swift.Error>

    init(requestable: Requstable, _ _requestResult: Result<Alamofire.DataRequest, Swift.Error>) {
        self.requestable = requestable
        self._requestResult = _requestResult
    }

    public func cancel() {
        switch _requestResult {
        case .success(let request):
            request.cancel()
        case .failure:
            break
        }
    }
}
