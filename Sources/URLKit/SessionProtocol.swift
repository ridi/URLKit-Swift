import Foundation
import class Alamofire.Session

public protocol SessionProtocol: AnyObject {
    var queue: DispatchQueue { get }

    var underlyingSession: Alamofire.Session { get }

    var baseURL: URL? { get }
    var responseBodyDecoder: TopLevelDataDecoder { get }
    var requestInterceptors: [RequestInterceptorProtocol] { get set }
}
