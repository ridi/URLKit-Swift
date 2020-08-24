import Foundation

/// Outcome of determination whether retry is necessary.
public enum RetryResult {
    /// Retry should be attempted immediately.
    case retry
    /// Retry should be attempted after the associated `TimeInterval`.
    case retryWithDelay(TimeInterval)
    /// Do not retry.
    case doNotRetry
    /// Do not retry due to the associated `Error`.
    case doNotRetryWithError(Error)
}

public protocol RequestInterceptorProtocol {
    func adapt(_ urlRequest: inout URLRequest, for session: SessionProtocol) throws
    func retry(_ request: RequestProtocol, for session: SessionProtocol, dueTo error: Error) -> RetryResult
}

extension RequestInterceptorProtocol {
    public func adapt(_ urlRequest: inout URLRequest, for session: SessionProtocol) throws {}

    public func retry(_ request: RequestProtocol, for session: SessionProtocol, dueTo error: Error) -> RetryResult {
        .doNotRetry
    }
}
