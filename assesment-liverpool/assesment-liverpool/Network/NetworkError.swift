import Foundation

enum NetworkError: Error, Equatable {
    case authentication
    case offline
    case unknown

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        guard type(of: lhs) == type(of: rhs) else { return false }
        let error1 = lhs as NSError
        let error2 = rhs as NSError
        return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
    }
}
