import Alamofire
import Foundation

struct NoBody: Codable {}
struct NoResponse: Codable {}

protocol NetworkCall {
    associatedtype Response: Codable
    associatedtype Body: Codable

    var method: HTTPMethod { get }
    var path: String { get }
    var body: Body { get }
}
