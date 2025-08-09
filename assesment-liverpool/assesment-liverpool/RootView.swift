import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationView {
            ProductsView(model: ProductsViewModel(networkClient: NetworkClient()))
                .background(Color(UIColor.systemGray6))
        }
    }
}
