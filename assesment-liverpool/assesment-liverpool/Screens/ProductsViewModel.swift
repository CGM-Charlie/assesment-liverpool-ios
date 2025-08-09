import Foundation
import Combine

struct Product: Identifiable {
    let id: String
    let displayName: String
    let brand: String?
    let displayListPrice: String
    let displayPromoPrice: String
    let imageUrl: String?
    let colors: [String]
}

enum SearchState {
    case loading
    case success
    case noResults
}

@MainActor
class ProductsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var products: [Product]
    @Published private(set) var searchState: SearchState
    private var pageNumber: Int32 = 1

    private let networkClient = NetworkClient()
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.products = []
        self.searchState = .loading

        $searchText
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self = self else { return }

                self.pageNumber = 1
                self.searchState = .loading
                self.products = []

                Task {
                    await self.fetchProducts(params: GetProductsParams(
                        searchTerm: value,
                        sortOption: nil,
                        pageNumber: self.pageNumber
                    ))
                }
            }
            .store(in: &cancellables)
    }

    func paginateIfNeccesary(product: Product) {
        if let lastProduct = products.last, lastProduct.id == product.id {
            loadNextPage()
        }
    }

    func loadNextPage() {
        self.pageNumber += 1

        Task {
            await self.fetchProducts(params: GetProductsParams(
                searchTerm: searchText,
                sortOption: nil,
                pageNumber: self.pageNumber
            ))
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
                        colors: $0.variantsColor?.compactMap { $0.colorHex } ?? []
                    )
                }

                products.append(contentsOf: newProducts)
                searchState = .success
            case .failure:
                searchState = .noResults
        }
    }
}
