import Testing
@testable import assesment_liverpool

final class MockNetworkClient: Networking {
    var nextResult: Any?

    func execute<Call: NetworkCall>(call: Call) async -> Result<Call.Response?, NetworkError> {
        if let result = nextResult as? Result<Call.Response?, NetworkError> {
            return result
        }

        return .failure(.unknown)
    }
}
