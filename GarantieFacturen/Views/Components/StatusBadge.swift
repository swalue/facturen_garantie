import SwiftUI

struct StatusBadge: View {
    let status: GarantieStatus

    var body: some View {
        Text(status.label)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(kleur.opacity(0.18))
            .foregroundStyle(kleur)
            .clipShape(Capsule())
    }

    private var kleur: Color {
        switch status {
        case .actief: return .green
        case .weldra: return .orange
        case .kritiek: return .red
        case .verlopen: return .gray
        }
    }
}
