#if canImport(Combine)
import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, *)
extension Session {
    @discardableResult
    open func request<T: Requestable>(
        _ request: T
    ) -> AnyPublisher<(Response<T.ResponseBody, Error>, T.ResponseBody), RequestError<T.ResponseBody, Error>> {
        var _request: Request<T>?

        return Future { promise in
            _request = self.request(request) { response in
                switch response.result {
                case .success(let data):
                    promise(.success((response, data)))
                case .failure(let error):
                    promise(.failure(.init(underlyingError: error, response: response)))
                }
            }
        }
        .handleEvents(
            receiveSubscription: nil,
            receiveOutput: nil,
            receiveCompletion: nil,
            receiveCancel: {
                _request?.cancel()
            },
            receiveRequest: nil
        )
        .eraseToAnyPublisher()
    }
}

#endif
