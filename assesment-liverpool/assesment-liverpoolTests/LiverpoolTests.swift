import Testing
import XCTest
@testable import assesment_liverpool

struct LiverpoolTests {
    @MainActor @Test func test_fetch_products_success() async throws {
        let mockNetworkClient = MockNetworkClient()

        let response = GetProductsResponse(
            plpResults: PlpResults(
                records: [
                    Record(
                        productId: "p1",
                        productDisplayName: "Product 1",
                        brand: "Brand A",
                        listPrice: 99.95,
                        promoPrice: 49.99,
                        lgImage: "https://picsum.photos/200/300",
                        variantsColor: [
                            VariantColor(
                                skuId: "foo",
                                colorHex: "#FFFFFF"
                            ),
                            VariantColor(
                                skuId: "bar",
                                colorHex: "#000000"
                            )
                        ]
                    )
                ]
            )
        )

        mockNetworkClient.nextResult = Result<GetProductsResponse?, NetworkError>.success(response)

        let viewModel = ProductsViewModel(networkClient: mockNetworkClient)
        await viewModel.fetchProducts(params: .init(searchTerm: "", sortOption: nil, pageNumber: 1))

        XCTAssertEqual(viewModel.searchState, .success)
        XCTAssertEqual(viewModel.products.count, 1)
        XCTAssertEqual(viewModel.products.first, Product(
            id: "p1",
            displayName: "Product 1",
            brand: "Brand A",
            displayListPrice: "$99.95",
            displayPromoPrice: "$49.99",
            imageUrl: "https://picsum.photos/200/300",
            colors: ["#FFFFFF", "#000000"]
        ))
    }

    @MainActor @Test func test_fetch_products_failure() async throws {
        let mockNetworkClient = MockNetworkClient()
        mockNetworkClient.nextResult = Result<GetProductsResponse?, NetworkError>.failure(.unknown)
        let viewModel = ProductsViewModel(networkClient: mockNetworkClient)

        await viewModel.fetchProducts(params: .init(searchTerm: "oops", sortOption: nil, pageNumber: 1))

        XCTAssertEqual(viewModel.searchState, .noResults)
        XCTAssertTrue(viewModel.products.isEmpty)
    }

    @MainActor @Test func test_pagination() async throws {
        let mockNetworkClient = MockNetworkClient()

        let page1 = GetProductsResponse(
            plpResults: PlpResults(
                records: [
                    Record(
                        productId: "p1",
                        productDisplayName: "Product 1",
                        brand: "Brand A",
                        listPrice: 99.95,
                        promoPrice: 49.99,
                        lgImage: "https://picsum.photos/200/300",
                        variantsColor: [
                            VariantColor(
                                skuId: "foo",
                                colorHex: "#FFFFFF"
                            ),
                            VariantColor(
                                skuId: "bar",
                                colorHex: "#000000"
                            )
                        ]
                    )
                ]
            )
        )

        let page2 = GetProductsResponse(
            plpResults: PlpResults(
                records: [
                    Record(
                        productId: "p2",
                        productDisplayName: "Product 2",
                        brand: "Brand B",
                        listPrice: 99.95,
                        promoPrice: 49.99,
                        lgImage: "https://picsum.photos/200/300",
                        variantsColor: [
                            VariantColor(
                                skuId: "foo",
                                colorHex: "#FFFFFF"
                            ),
                            VariantColor(
                                skuId: "bar",
                                colorHex: "#000000"
                            )
                        ]
                    )
                ]
            )
        )

        let viewModel = ProductsViewModel(networkClient: mockNetworkClient)

        mockNetworkClient.nextResult = Result<GetProductsResponse?, NetworkError>.success(page1)
        await viewModel.fetchProducts(params: .init(searchTerm: "x", sortOption: nil, pageNumber: 1))
        XCTAssertEqual(viewModel.products.map(\.id), ["p1"])

        mockNetworkClient.nextResult = Result<GetProductsResponse?, NetworkError>.success(page2)
        viewModel.loadNextPage()
        await Task.yield()

        XCTAssertEqual(viewModel.products.map(\.id), ["p1", "p2"])
        XCTAssertEqual(viewModel.searchState, .success)
    }

    @MainActor @Test func test_paginate_when_neccesary() async throws {
        let mock = MockNetworkClient()

        let response = GetProductsResponse(
            plpResults: PlpResults(
                records: [
                    Record(
                        productId: "p1",
                        productDisplayName: "Product 1",
                        brand: "Brand A",
                        listPrice: 99.95,
                        promoPrice: 49.99,
                        lgImage: "https://picsum.photos/200/300",
                        variantsColor: [
                            VariantColor(
                                skuId: "foo",
                                colorHex: "#FFFFFF"
                            ),
                            VariantColor(
                                skuId: "bar",
                                colorHex: "#000000"
                            )
                        ]
                    ),
                    Record(
                        productId: "p2",
                        productDisplayName: "Product 2",
                        brand: "Brand B",
                        listPrice: 99.95,
                        promoPrice: 49.99,
                        lgImage: "https://picsum.photos/200/300",
                        variantsColor: [
                            VariantColor(
                                skuId: "foo",
                                colorHex: "#FFFFFF"
                            ),
                            VariantColor(
                                skuId: "bar",
                                colorHex: "#000000"
                            )
                        ]
                    )
                ]
            )
        )

        mock.nextResult = Result<GetProductsResponse?, NetworkError>.success(response)
        let vm = ProductsViewModel(networkClient: mock)
        await vm.fetchProducts(params: .init(searchTerm: "", sortOption: nil, pageNumber: 1))

        // Not last item -> should NOT paginate
        vm.paginateIfNeccesary(product: vm.products[0])
        await Task.yield()
        XCTAssertEqual(vm.products.map(\.id), ["p1", "p2"])

        let paginatedResponse = GetProductsResponse(
            plpResults: PlpResults(
                records: [
                    Record(
                        productId: "p3",
                        productDisplayName: "Product 3",
                        brand: "Brand C",
                        listPrice: 99.95,
                        promoPrice: 49.99,
                        lgImage: "https://picsum.photos/200/300",
                        variantsColor: [
                            VariantColor(
                                skuId: "foo",
                                colorHex: "#FFFFFF"
                            ),
                            VariantColor(
                                skuId: "bar",
                                colorHex: "#000000"
                            )
                        ]
                    )
                ]
            )
        )

        mock.nextResult = Result<GetProductsResponse?, NetworkError>.success(paginatedResponse)

        // Last item -> should paginate
        vm.paginateIfNeccesary(product: vm.products[1])
        await Task.yield()
        XCTAssertEqual(vm.products.map(\.id), ["p1", "p2", "p3"])
    }
}
