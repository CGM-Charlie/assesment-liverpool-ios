import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationView {
            ProductsView(model: ProductsViewModel())
                .background(Color(UIColor.systemGray6))
        }
    }
}
