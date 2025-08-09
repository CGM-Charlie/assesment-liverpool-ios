import Foundation

struct Product: Identifiable {
    let id: String
    let displayName: String
    let brand: String
    let displayListPrice: String
    let displayPromoPrice: String
    let imageUrl: String?
    let colors: [String]
}

@MainActor
class ProductsViewModel: ObservableObject {
    @Published private(set) var products: [Product]
    private let networkClient = NetworkClient()

    init() {
        self.products = []

        Task {
            await fetchProducts(params: GetProductsParams(searchTerm: nil, sortOption: nil))
        }
    }

    func fetchProducts(params: GetProductsParams) async {
        let result = await Task.detached { [networkClient] in
            await networkClient.execute(call: GetProductsCall(params: params))
        }.value

        switch result {
            case .success(let response):
                let newProducts = (response?.plpResults.records ?? []).map {
                    Product(
                        id: $0.productId,
                        displayName: $0.productDisplayName,
                        brand: $0.brand,
                        displayListPrice: $0.listPrice.currencyFormatted,
                        displayPromoPrice: $0.promoPrice.currencyFormatted,
                        imageUrl: $0.lgImage,
                        colors: $0.variantsColor.map { $0.colorHex }
                    )
                }
                products.append(contentsOf: newProducts)
            case .failure(let error):
                debugPrint(error)
        }
    }
}
