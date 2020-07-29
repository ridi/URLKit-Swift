import Foundation

public protocol SessionProtocol: AnyObject {
    var mainQueue: DispatchQueue { get }
    var requestQueue: DispatchQueue { get }
}
