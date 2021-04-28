import URLKit
import RxSwift

extension Session: ReactiveCompatible {}

extension Reactive where Base: Session {
    @discardableResult
    public func request<T: Requestable>(
        _ request: T
    ) -> Single<T.ResponseBody> {
        Single.create { single in
            let request = self.base.request(request) { response in
                switch response.result {
                case .success(let response):
                    single(.success(response))
                case .failure(let error):
                    single(.failure(error))
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
