import URLKit
import RxSwift

extension Session: ReactiveCompatible {}

extension Reactive where Base: Session {
    @discardableResult
    public func request<T: Requestable>(
        request: T
    ) -> Single<Response<T.ResponseBody, Error>> {
        Single.create { single in
            let request = self.base.request(request) { response in
                single(.success(response))
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
