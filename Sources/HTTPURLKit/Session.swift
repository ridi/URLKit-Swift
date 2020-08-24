import Foundation
import Alamofire
import URLKit

@_exported import protocol URLKit.RequestInterceptorProtocol
@_exported import struct URLKit.RequestInterceptor

open class Session: SessionProtocol {
    public static var shared: Session = .init()

    open var queue = DispatchQueue(
        label: "\(String(reflecting: Session.self))",
        qos: .default
    )

    open private(set) var underlyingSession: Alamofire.Session

    open private(set) var baseURL: URL?
    open private(set) var parameterEncodingStrategy: ParameterEncodingStrategy
    open private(set) var responseBodyDecoder: TopLevelDataDecoder
    open var requestInterceptors = [RequestInterceptorProtocol]()

    public required init(
        configuration: URLSessionConfiguration = .urlk_default,
        baseURL: URL? = nil,
        parameterEncodingStrategy: ParameterEncodingStrategy = .urlEncodedFormParameter,
        responseBodyDecoder: TopLevelDataDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.parameterEncodingStrategy = parameterEncodingStrategy
        self.responseBodyDecoder = responseBodyDecoder
        self.underlyingSession = .init(
            configuration: configuration,
            rootQueue: queue
        )
    }

    @discardableResult
    open func request<T: Requestable>(
        _ request: T,
        completion: @escaping (Response<T.ResponseBody, Error>) -> Void
    ) -> Request<T> {
        let request = Request(requestable: request)

        queue.async {
            do {
                let alamofireRequest = try self.underlyingSession.request(
                    request.requestable.asURLRequest(
                        baseURL: self.baseURL,
                        parameterEncodingStrategy: self.parameterEncodingStrategy
                    ),
                    interceptor: Interceptor(
                        interceptors: self.requestInterceptors.map { requestAdaptor in
                            Adapter {
                                do {
                                    var request = $0
                                    try requestAdaptor.adapt(&request, for: self)
                                    $2(.success(request))
                                } catch {
                                    $2(.failure(error))
                                }
                            }
                        }
                    )
                )
                request.underlyingRequest = alamofireRequest

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
                        queue: self.queue,
                        decoder: request.requestable.responseBodyDecoder ?? self.responseBodyDecoder,
                        completionHandler: {
                            completion(.init(
                                result: $0.result
                                    .mapError { $0.underlyingError ?? $0 },
                                underlyingResponse: $0
                            ))
                        }
                    )
            } catch {
                completion(.init(result: .failure(error), underlyingResponse: nil))
            }
        }

        return request
    }
}
