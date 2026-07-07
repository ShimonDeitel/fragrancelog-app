import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var purchases: PurchaseManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundStyle(FragrancelogTheme.accentBright)
                Text("Fragrance Log Pro")
                    .font(FragrancelogTheme.titleFont)
                Text("Season/occasion tagging, collection value tracker")
                    .font(FragrancelogTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                Button {
                    Task { await purchases.purchase() }
                } label: {
                    Text(purchases.product != nil ? "Unlock for \(purchases.product!.displayPrice)" : "Unlock Pro ($1.99/mo)")
                        .font(FragrancelogTheme.headlineFont)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(FragrancelogTheme.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityIdentifier("unlockButton")
                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .accessibilityIdentifier("restoreButton")
                Button("Not Now") { dismiss() }
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("dismissPaywallButton")
            }
            .padding()
            .task { await purchases.load() }
        }
    }
}
