#if canImport(Combine)
import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, *)
extension Session {
    @discardableResult
    open func request<T: Requestable>(
        request: T
    ) -> AnyPublisher<Response<T.ResponseBody, Error>, Never> {
        var _request: Request<T>?

        return Future() { promise in
            _request = self.request(request: request) { response in
                promise(.success(response))
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
