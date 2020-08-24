import Foundation

public struct RequestInterceptor: RequestInterceptorProtocol {
    private let _adaptor: (inout URLRequest, SessionProtocol) throws -> Void
    private let _retrier: ((RequestProtocol, SessionProtocol, Error) -> RetryResult)?

    public init(
        adaptor: @escaping (inout URLRequest, SessionProtocol) throws -> Void,
        retrier: ((RequestProtocol, SessionProtocol, Error) -> RetryResult)? = nil
    ) {
        _adaptor = adaptor
        _retrier = retrier
    }

    public func adapt(_ urlRequest: inout URLRequest, for session: SessionProtocol) throws {
        try _adaptor(&urlRequest, session)
    }

    public func retry(_ request: RequestProtocol, for session: SessionProtocol, dueTo error: Error) -> RetryResult {
        _retrier?(request, session, error) ?? .doNotRetry
    }
}
