import Foundation
import Alamofire

public protocol OAuthCredential: AuthenticationCredential {
    var accessToken: String { get }
    var requiresRefresh: Bool { get }
}

public protocol OAuthCredentialManager {
    associatedtype Credential: OAuthCredential

    var credential: Credential { get }

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
        authenticatedWith credential: Credential
    ) -> Bool {
        return true
    }
}

open class OAuthSession<CredentialManager: OAuthCredentialManager>: Session {
    public typealias Credential = CredentialManager.Credential

    open var credentialManager: CredentialManager

    lazy var _alamofireAuthenticationInterceptor = AuthenticationInterceptor(authenticator: self, credential: credentialManager.credential)

    public required init(configuration: URLSessionConfiguration? = nil, baseURL: URL? = nil, credentialManager: CredentialManager) {
        self.credentialManager = credentialManager

        super.init(configuration: configuration, baseURL: baseURL)
    }

    @available(*, unavailable)
    public required init(configuration: URLSessionConfiguration? = nil, baseURL: URL? = nil) {
        fatalError("init(configuration:baseURL:) has not been implemented")
    }

    @discardableResult
    open override func request<T: Requestable>(
        _ request: T,
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
    public func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
    }

    public func refresh(_ credential: Credential,
                        for session: Alamofire.Session,
                        completion: @escaping (Result<Credential, Error>) -> Void) {
        credentialManager.refresh(credential, for: self, completion: completion)
    }

    public func didRequest(_ urlRequest: URLRequest,
                           with response: HTTPURLResponse,
                           failDueToAuthenticationError error: Error) -> Bool {
        credentialManager.didRequest(urlRequest, with: response, failDueToAuthenticationError: error)
    }

    public func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool {
        credentialManager.isRequest(urlRequest, authenticatedWith: credential)
    }
}

