import SwiftUI
import SDWebImageSwiftUI

struct ProductsView: View {
    @ObservedObject var model: ProductsViewModel

    init(model: ProductsViewModel) {
        self.model = model
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(model.products.enumerated()), id: \.element.id) { index, product in
                    HStack(alignment: .top, spacing: 2) {
                        WebImage(
                            url: URL(string: product.imageUrl ?? ""),
                            options: SDWebImageOptions.handleCookies,
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 128, height: 128)
                            },
                            placeholder: { Text("No Image") }
                        )

                        VStack(alignment: .leading, spacing: 6) {
                            Text(product.displayName)

                            if product.displayListPrice == product.displayPromoPrice {
                                Text(product.displayPromoPrice)
                                    .foregroundStyle(.red)
                            } else {
                                Text(product.displayListPrice)
                                    .strikethrough()

                                Text(product.displayPromoPrice)
                                    .foregroundStyle(.red)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(product.colors.chunked(into: 5).enumerated()), id: \.offset) { colors in
                                    HStack {
                                        ForEach(Array(colors.element.enumerated()), id: \.offset) { hexColor in
                                            if let color = Color(hex: hexColor.element) {
                                                Circle()
                                                    .strokeBorder(.gray, lineWidth: 1)
                                                    .background(Circle().fill(color))
                                                    .frame(width: 24, height: 24)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.all, 12)

                    if index != model.products.count - 1 {
                        Divider()
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .navigationTitle("Productos")
    }
}
