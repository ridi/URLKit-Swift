import Foundation
import Alamofire

open class Session: SessionProtocol {
    public static var shared: Session = .init()

    open var mainQueue = DispatchQueue(
        label: "\(String(reflecting: Session.self)).main",
        qos: .default
    )

    open var requestQueue = DispatchQueue(
        label: "\(String(reflecting: Session.self)).request",
        qos: .default
    )

    var _alamofireSession: Alamofire.Session

    open private(set) var baseURL: URL?

    open var session: URLSession {
        _alamofireSession.session
    }

    public required init(configuration: URLSessionConfiguration? = nil, baseURL: URL? = nil) {
        self.baseURL = baseURL
        self._alamofireSession = .init(configuration: configuration ?? URLSessionConfiguration.af.default, rootQueue: requestQueue)
    }

    @discardableResult
    open func request<T: Requestable>(
        request: T,
        completion: @escaping (Response<T.ResponseBody, Error>) -> Void
    ) -> Request<T> {
        let request = Request.init(
            requestable: request,
            {
                do {
                    return .success(try _alamofireSession.request(request.asURLRequest(baseURL: baseURL)))
                } catch {
                    return .failure(error)
                }
            }()
        )

        mainQueue.async {
            switch request._requestResult {
            case .success(let alamofireRequest):
                alamofireRequest
                    .validate({ (urlRequest, response, data) -> DataRequest.ValidationResult in
                        do {
                            try request.requestable.validate(request: urlRequest, response: response, data: data)
                        } catch {
                            return .failure(error)
                        }

                        return .success(())
                    })
                    .responseDecodable(completionHandler: { completion(.init(result: $0.result.eraseFailureToError())) })
            case .failure(let error):
                completion(.init(result: .failure(error)))
            }
        }

        return request
    }
}
