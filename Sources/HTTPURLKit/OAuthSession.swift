import Foundation
import Alamofire

public struct OAuthCredential: AuthenticationCredential {
    let accessToken: String
    let refreshToken: String
    let userID: String
    let expiration: Date

    // Require refresh if within 5 minutes of expiration
    public var requiresRefresh: Bool { Date(timeIntervalSinceNow: 60 * 5) > expiration }
}

public protocol OAuthCredentialManager {
    func refresh(
        _ credential: OAuthCredential,
        for session: OAuthSession,
        completion: @escaping (Result<OAuthCredential, Error>) -> Void
    )

    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: Error
    ) -> Bool

    func isRequest(
        _ urlRequest: URLRequest,
        authenticatedWith credential: OAuthCredential
    ) -> Bool
}

public extension OAuthCredentialManager {
    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: Error
    ) -> Bool {
        return false
    }

    func isRequest(
        _ urlRequest: URLRequest,
        authenticatedWith credential: OAuthCredential
    ) -> Bool {
        return true
    }
}

open class OAuthSession: Session {
    public typealias Credential = OAuthCredential

    open var credential: OAuthCredential? {
        get {
            _alamofireAuthenticationInterceptor.credential
        }
        set {
            _alamofireAuthenticationInterceptor.credential = newValue
        }
    }

    open var credentialManager: OAuthCredentialManager

    lazy var _alamofireAuthenticationInterceptor = AuthenticationInterceptor(authenticator: self, credential: nil)

    public required init(baseURL: URL? = nil, credential: OAuthCredential? = nil, credentialManager: OAuthCredentialManager) {
        self.credentialManager = credentialManager

        super.init(baseURL: baseURL)

        self.credential = credential
    }

    @available(*, unavailable)
    public required init(baseURL: URL? = nil) {
        fatalError("init(baseURL:) has not been implemented")
    }

    @discardableResult
    open override func request<T: Requestable>(
        request: T,
        completion: @escaping (Response<T.ResponseBody, Error>) -> Void
    ) -> Request<T> {
        let request = Request.init(
            requestable: request,
            {
                do {
                    return .success(
                        try _alamofireSession.request(
                            request.asURLRequest(),
                            interceptor: request.requiresAuthentication ? _alamofireAuthenticationInterceptor : nil
                        )
                    )
                } catch {
                    return .failure(error)
                }
            }()
        )

        mainQueue.async {
            switch request._requestResult {
            case .success(let request):
                request
                    .responseDecodable(completionHandler: { completion(.init(result: $0.result.eraseFailureToError(), response: $0.response)) })
            case .failure(let error):
                completion(.init(result: .failure(error), response: nil))
            }
        }

        return request
    }
}

extension OAuthSession: Authenticator {
    public func apply(_ credential: OAuthCredential, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
    }

    public func refresh(_ credential: OAuthCredential,
                        for session: Alamofire.Session,
                        completion: @escaping (Result<OAuthCredential, Error>) -> Void) {
        credentialManager.refresh(credential, for: self, completion: completion)
    }

    public func didRequest(_ urlRequest: URLRequest,
                           with response: HTTPURLResponse,
                           failDueToAuthenticationError error: Error) -> Bool {
        credentialManager.didRequest(urlRequest, with: response, failDueToAuthenticationError: error)
    }

    public func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuthCredential) -> Bool {
        credentialManager.isRequest(urlRequest, authenticatedWith: credential)
    }
}

