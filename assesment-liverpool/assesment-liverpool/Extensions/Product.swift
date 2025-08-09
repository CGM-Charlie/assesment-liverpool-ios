extension Product: Equatable {
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id &&
        lhs.displayName == rhs.displayName &&
        lhs.brand == rhs.brand &&
        lhs.displayListPrice == rhs.displayListPrice &&
        lhs.displayPromoPrice == rhs.displayPromoPrice &&
        lhs.imageUrl == rhs.imageUrl &&
        lhs.colors == rhs.colors
    }
}
