import Alamofire
import Foundation

struct GetProductsParams: Codable {
    let searchTerm: String?
    let sortOption: String?
}

struct GetProductsResponse: Codable {
    let status: Status
    let plpResults: PlpResults
}

struct Status: Codable {
    let status: String
    let statusCode: Int
}

struct PlpResults: Codable {
    let label: String
    let records: [Record]
}

struct Record: Codable {
    let productId: String
    let productDisplayName: String
    let brand: String
    let listPrice: Double
    let promoPrice: Double
    let lgImage: String?
    let variantsColor: [VariantColor]
}

struct VariantColor: Codable {
    let skuId: String
    let colorHex: String
}

final class GetProductsCall: NetworkCall {
    typealias Response = GetProductsResponse

    let method: HTTPMethod = .get
    let path: String
    let body: NoBody = .init()

    init(params: GetProductsParams) {
        self.path = "/appclienteservices/services/v8/plp/sf?page-number=1&search-string=\(params.searchTerm ?? "")&sort-option=\(params.sortOption ?? "predefined")&force-plp=false&number-of-items-per-page=40&cleanProductName=false"
    }
}
