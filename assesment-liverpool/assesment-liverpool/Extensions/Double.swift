import Foundation

extension Double {
    var currencyFormatted: String {
        let formatter = NumberFormatter()

        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2

        return formatter.string(from: self as NSNumber) ?? "$0.00"
    }
}
