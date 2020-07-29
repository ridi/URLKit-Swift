#if canImport(RxSwift)
import URLKit
import RxSwift

extension Session: ReactiveCompatible {}

extension Reactive where Base: Session {
    @discardableResult
    public func request<T: Requestable>(
        request: T
    ) -> Observable<Response<T.ResponseBody, Error>> {
        Observable.create { observer in
            let request = self.base.request(request: request) { response in
                observer.on(.next(response))
                observer.on(.completed)
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
#endif
