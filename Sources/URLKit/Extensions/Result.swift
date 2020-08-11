import Foundation

public extension Result {
    func eraseFailureToError() -> Result<Success, Error> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(error)
        }
    }

    func eraseSuccessToVoid() -> Result<Void, Failure> {
        switch self {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
