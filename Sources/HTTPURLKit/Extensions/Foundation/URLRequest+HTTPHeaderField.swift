import Foundation
import Alamofire

extension URLRequest {
    public struct HTTPHeaderFieldName: RawRepresentable, Hashable {
        public typealias RawValue = String

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public var rawValue: RawValue
    }

    /// A dictionary containing all the HTTP header fields of the
    /// receiver.
    public var urlk_allHTTPHeaderFields: [HTTPHeaderFieldName: String]? {
        get {
            (allHTTPHeaderFields?
                .map { (key: HTTPHeaderFieldName(rawValue: $0), value: $1) })
                .flatMap {
                    Dictionary(uniqueKeysWithValues: $0)
                }
        }
        set {
            allHTTPHeaderFields = (newValue?.map { (key: $0.rawValue, value: $1) })
                .flatMap {
                    Dictionary(uniqueKeysWithValues: $0)
                }
        }
    }

    /// The value which corresponds to the given header
    /// field. Note that, in keeping with the HTTP RFC, HTTP header field
    /// names are case-insensitive.
    /// - parameter: field the header field name to use for the lookup (case-insensitive).
    public func value(forHTTPHeaderField field: HTTPHeaderFieldName) -> String? {
        value(forHTTPHeaderField: field.rawValue)
    }

    /// If a value was previously set for the given header
    /// field, that value is replaced with the given value. Note that, in
    /// keeping with the HTTP RFC, HTTP header field names are
    /// case-insensitive.
    public mutating func setValue(_ value: String?, forHTTPHeaderField field: HTTPHeaderFieldName) {
        setValue(value, forHTTPHeaderField: field.rawValue)
    }

    /// This method provides a way to add values to header
    /// fields incrementally. If a value was previously set for the given
    /// header field, the given value is appended to the previously-existing
    /// value. The appropriate field delimiter, a comma in the case of HTTP,
    /// is added by the implementation, and should not be added to the given
    /// value by the caller. Note that, in keeping with the HTTP RFC, HTTP
    /// header field names are case-insensitive.
    public mutating func addValue(_ value: String, forHTTPHeaderField field: HTTPHeaderFieldName) {
        setValue(value, forHTTPHeaderField: field.rawValue)
    }
}

extension Dictionary where Key == URLRequest.HTTPHeaderFieldName, Value == String {
    public static var urlk_default: Self {
        self.init(
            HTTPHeaders.default.map {
                (key: URLRequest.HTTPHeaderFieldName.init(rawValue: $0.name), value: $0.value)

            },
            uniquingKeysWith: { $1 }
        )
    }
}
