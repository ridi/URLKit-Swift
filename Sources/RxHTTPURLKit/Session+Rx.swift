import HTTPURLKit
import RxSwift

extension Session: ReactiveCompatible {}

public extension Reactive where Base: Session {
    @discardableResult
    func request<T: Requestable>(
        _ request: T
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
