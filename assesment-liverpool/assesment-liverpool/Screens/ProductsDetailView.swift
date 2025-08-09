import SwiftUI

struct ProductDetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Product Detail")
                .font(.title)

//            NavigationLink("Back to Products", destination: ProductsView())
        }
        .navigationTitle("Detail")
    }
}
