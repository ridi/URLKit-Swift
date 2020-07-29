import Foundation
import Alamofire

public struct EmptyParameters: Encodable {}
public struct EmptyResponse: Decodable {}

public protocol Requestable {
    associatedtype Parameters: Encodable
    associatedtype ResponseBody: Decodable

    var parameters: Parameters? { get }
    static var responseBodyType: ResponseBody.Type? { get }

    var url: URL { get }

    var requiresAuthentication: Bool { get }
}

public extension Requestable {
    var parameters: Parameters? {
        return nil
    }

    static var responseBodyType: ResponseBody.Type? {
        return nil
    }

    var requiresAuthentication: Bool {
        return false
    }
}

public extension Requestable where Self: Encodable {
    var parameters: Self {
        self
    }
}

public extension Requestable where Self: Decodable {
    static var responseType: Self.Type {
        self.self
    }
}

extension Requestable {
    func asURLRequest() throws -> URLRequest {
        let request = URLRequest(url: url)

        return try parameters.map { try URLEncodedFormParameterEncoder().encode($0, into: request) } ?? request
    }
}
