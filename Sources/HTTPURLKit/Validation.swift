import Foundation
import URLKit

@_exported import struct URLKit.Validation

public enum ValidationError: Error {
    case unacceptableStatusCode(Int)
}

public extension Validation {
    static func statusCodes<S: Sequence>(
        _ statusCodes: S
    ) -> Validation where S.Iterator.Element == Int {
        self.statusCodes(IndexSet(statusCodes))
    }

    static func statusCodes(
        _ statusCodes: IndexSet
    ) -> Validation {
        .init(validation: { _, response, _ in
            guard let httpURLResponse = response as? HTTPURLResponse else {
                return
            }

            guard statusCodes.contains(httpURLResponse.statusCode) else {
                throw ValidationError.unacceptableStatusCode(httpURLResponse.statusCode)
            }
        })
    }
}
