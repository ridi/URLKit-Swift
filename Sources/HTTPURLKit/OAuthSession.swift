// swiftlint:disable function_default_parameter_at_end
import Foundation
import Alamofire
import URLKit

public protocol OAuthCredential: AuthenticationCredential {
    var accessToken: String { get }
    var requiresRefresh: Bool { get }
}

public protocol OAuthAuthenticator {
    associatedtype Credential: OAuthCredential

    func apply(
        _ credential: Credential,
        to urlRequest: inout URLRequest
    )

    func refresh(
        _ credential: Credential,
        for session: OAuthSession<Self>,
        completion: @escaping (Result<Credential, Error>) -> Void
    )

    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: Error
    ) -> Bool

    func isRequest(
        _ urlRequest: URLRequest,
        authenticatedWith credential: Credential
    ) -> Bool
}

public extension OAuthAuthenticator {
    func apply(
        _ credential: Credential,
        to urlRequest: inout URLRequest
    ) {
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
    }

    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: Error
    ) -> Bool {
        return response.statusCode == 401
    }

    func isRequest(
        _ urlRequest: URLRequest,
        authenticatedWith credential: Credential
    ) -> Bool {
        return urlRequest.headers.contains(.authorization(bearerToken: credential.accessToken))
    }
}

open class OAuthSession<Authenticator: OAuthAuthenticator>: Session {
    public typealias Credential = Authenticator.Credential

    open var credential: Credential? {
        get {
            authenticationInterceptor.credential
        }
        set {
            authenticationInterceptor.credential = newValue
        }
    }
    open private(set) var authenticator: Authenticator

    open private(set) lazy var authenticationInterceptor = AuthenticationInterceptor(
        authenticator: self,
        credential: nil
    )

    public required init(
        configuration: URLSessionConfiguration = .urlk_default,
        baseURL: URL? = nil,
        responseBodyDecoder: TopLevelDataDecoder = JSONDecoder(),
        authenticator: Authenticator,
        credential: Credential? = nil
    ) {
        self.authenticator = authenticator

        super.init(configuration: configuration, baseURL: baseURL, responseBodyDecoder: responseBodyDecoder)

        authenticationInterceptor.credential = credential
    }

    @available(*, unavailable)
    public required init(
        configuration: URLSessionConfiguration = .urlk_default,
        baseURL: URL? = nil,
        responseBodyDecoder: TopLevelDataDecoder = JSONDecoder()
    ) {
        fatalError("init(configuration:baseURL:responseBodyDecoder:) has not been implemented")
    }

    @discardableResult
    open override func request<T: Requestable>(
        _ request: T,
        completion: @escaping (Response<T.ResponseBody, Error>) -> Void
    ) -> Request<T> {
        let request = Request(requestable: request)

        queue.async {
            do {
                let alamofireRequest = try self.underlyingSession.request(
                    request.requestable.asURLRequest(baseURL: self.baseURL),
                    interceptor: request.requestable.requiresAuthentication ? self.authenticationInterceptor : nil
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
                                response: $0.response
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

extension OAuthSession: Alamofire.Authenticator {
    public func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        authenticator.apply(credential, to: &urlRequest)
    }

    public func refresh(_ credential: Credential,
                        for session: Alamofire.Session,
                        completion: @escaping (Result<Credential, Error>) -> Void) {
        authenticator.refresh(credential, for: self, completion: completion)
    }

    public func didRequest(_ urlRequest: URLRequest,
                           with response: HTTPURLResponse,
                           failDueToAuthenticationError error: Error) -> Bool {
        authenticator.didRequest(urlRequest, with: response, failDueToAuthenticationError: error)
    }

    public func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool {
        authenticator.isRequest(urlRequest, authenticatedWith: credential)
    }
}
