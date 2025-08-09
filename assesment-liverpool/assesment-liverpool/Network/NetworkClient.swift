import Foundation
import Alamofire

protocol Networking {
    func execute<Call: NetworkCall>(call: Call) async -> Result<Call.Response?, NetworkError>
}

extension NetworkClient: Networking {}

final class NetworkClient {
    let apiURL = "https://shoppapp.liverpool.com.mx"

    func execute<Call: NetworkCall>(call: Call) async -> Result<Call.Response?, NetworkError> {
        let url = "\(apiURL)\(call.path)"
        let method = call.method
        let params = call.body
        let encoder: ParameterEncoder = (method == .get)
            ? URLEncodedFormParameterEncoder.default
            : JSONParameterEncoder.default

        return await withCheckedContinuation { continuation in
            AF.request(
                url,
                method: method,
                parameters: params,
                encoder: encoder,
                headers: nil,
                interceptor: nil
            )
            .responseData { response in
                continuation.resume(returning: Self.handleResponse(call: call, response: response))
            }
        }
    }

    private static func handleResponse<Call: NetworkCall>(
        call: Call,
        response: AFDataResponse<Data>
    ) -> Result<Call.Response?, NetworkError> {
        if response.error != nil {
            return .failure(.unknown)
        }

        guard let statusCode = response.response?.statusCode else {
            return .failure(.unknown)
        }

        if statusCode == 204 { return .success(nil) }
        if statusCode == 502 { return .failure(.unknown) }
        if statusCode == 504 { return .failure(.unknown) }
        if statusCode == 401 { return .failure(.authentication) }
        if statusCode >= 400 && statusCode != 422 { return .failure(.unknown) }

        guard let data = response.data else {
            return .failure(.unknown)
        }

        do {
            let parsedResponse = try JSONDecoder().decode(Call.Response.self, from: data)
            return .success(parsedResponse)
        } catch {
            return .failure(.unknown)
        }
    }
}
