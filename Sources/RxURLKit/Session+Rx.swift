import URLKit
import RxSwift

extension Session: ReactiveCompatible {}

public extension Reactive where Base: Session {
    @discardableResult
    func request<T: Requestable>(
        _ request: T
    ) -> Single<(Response<T.ResponseBody, Error>, T.ResponseBody)> {
        Single.create { single in
            let request = self.base.request(request) { response in
                switch response.result {
                case .success(let data):
                    single(.success((response, data)))
                case .failure(let error):
                    single(.error(RequestError(underlyingError: error, response: response)))
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
