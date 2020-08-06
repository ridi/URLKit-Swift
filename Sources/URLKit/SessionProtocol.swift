import Foundation
import Alamofire

public protocol SessionProtocol: AnyObject {
    var mainQueue: DispatchQueue { get }
    var requestQueue: DispatchQueue { get }

    var underlyingSession: Alamofire.Session { get }
}
