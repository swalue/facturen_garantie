import Foundation

enum Formatters {
    static let datum: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let valuta: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "nl_NL")
        return formatter
    }()

    static func bedrag(_ waarde: Double) -> String {
        valuta.string(from: NSNumber(value: waarde)) ?? String(format: "%.2f", waarde)
    }

    static func dagen(_ aantal: Int) -> String {
        if aantal == 1 { return "1 dag" }
        if aantal < 0 { return "\(-aantal) dagen geleden" }
        return "\(aantal) dagen"
    }
}
