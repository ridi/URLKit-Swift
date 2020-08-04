import Foundation

extension URLSessionConfiguration {
    var ridi_httpAdditionalHeaders: [URLRequest.HTTPHeaderFieldName: String]? {
        get {
            (httpAdditionalHeaders?
                .map { (key: URLRequest.HTTPHeaderFieldName(rawValue: String(describing: $0)), value: String(describing: $1)) })
                .flatMap {
                    Dictionary(uniqueKeysWithValues: $0)
                }
        }
        set {
            httpAdditionalHeaders = (newValue?.map { (key: $0.rawValue, value: $1) })
                .flatMap {
                    Dictionary(uniqueKeysWithValues: $0)
                }
        }
    }
}
