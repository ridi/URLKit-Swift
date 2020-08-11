import Foundation
import Alamofire

public protocol SessionProtocol: AnyObject {
    var queue: DispatchQueue { get }

    var underlyingSession: Alamofire.Session { get }

    var baseURL: URL? { get }
    var responseBodyDecoder: TopLevelDataDecoder { get }
}
