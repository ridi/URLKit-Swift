import Foundation
import Alamofire
import URLKit

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

    open private(set) var underlyingSession: Alamofire.Session

    open private(set) var baseURL: URL?
    open private(set) var responseBodyDecoder: TopLevelDataDecoder

    public required init(
        configuration: URLSessionConfiguration = .urlk_default,
        baseURL: URL? = nil,
        responseBodyDecoder: TopLevelDataDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.responseBodyDecoder = responseBodyDecoder
        self.underlyingSession = .init(
            configuration: configuration,
            rootQueue: requestQueue
        )
    }

    @discardableResult
    open func request<T: Requestable>(
        _ request: T,
        completion: @escaping (Response<T.ResponseBody, Error>) -> Void
    ) -> Request<T> {
        let request = Request(
            requestable: request,
            {
                do {
                    return .success(try underlyingSession.request(request.asURLRequest(baseURL: baseURL)))
                } catch {
                    return .failure(error)
                }
            }()
        )

        mainQueue.async {
            switch request._requestResult {
            case .success(let alamofireRequest):
                alamofireRequest
                    .validate({ urlRequest, response, data in
                        do {
                            try request.requestable.validate(request: urlRequest, response: response, data: data)
                        } catch {
                            return .failure(error)
                        }

                        return .success(())
                    })
                    .responseDecodable(
                        decoder: request.requestable.responseBodyDecoder ?? self.responseBodyDecoder,
                        completionHandler: {
                            completion(.init(
                                result: $0.result
                                    .mapError { $0.underlyingError ?? $0 },
                                response: $0.response
                            ))
                        }
                    )
            case .failure(let error):
                completion(.init(result: .failure(error)))
            }
        }

        return request
    }
}
