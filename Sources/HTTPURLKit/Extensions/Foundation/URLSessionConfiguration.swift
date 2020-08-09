import Foundation

extension URLSessionConfiguration {
    public static var urlk_default: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.urlk_httpAdditionalHeaders = .urlk_default

        return configuration
    }
}
