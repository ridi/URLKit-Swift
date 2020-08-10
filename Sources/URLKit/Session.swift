import Foundation
import Alamofire

open class Session: SessionProtocol {
    public static var shared: Session = .init()

    open var queue = DispatchQueue(
        label: "\(String(reflecting: Session.self))",
        qos: .default
    )

    open private(set) var underlyingSession: Alamofire.Session

    open private(set) var baseURL: URL?
    open private(set) var responseBodyDecoder: TopLevelDataDecoder

    public required init(
        configuration: URLSessionConfiguration = .default,
        baseURL: URL? = nil,
        responseBodyDecoder: TopLevelDataDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
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
                let alamofireRequest = try self.underlyingSession.request(request.requestable.asURLRequest(baseURL: self.baseURL))
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
                                    .mapError { $0.underlyingError ?? $0 }
                            ))
                        }
                    )
            } catch {
                completion(.init(result: .failure(error)))
            }
        }

        return request
    }
}
