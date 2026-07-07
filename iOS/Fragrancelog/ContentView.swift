import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Fragrance?

    var body: some View {
        NavigationStack {
            ZStack {
                FragrancelogTheme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Fragrance Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if store.canAddMore || purchases.isPro {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            EntryFormView(itemToEdit: nil) { newItem in
                store.add(newItem)
            }
        }
        .sheet(item: $editingItem) { item in
            EntryFormView(itemToEdit: item) { updated in
                store.update(updated)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(FragrancelogTheme.accentBright)
            Text("No fragrances yet")
                .font(FragrancelogTheme.headlineFont)
                .foregroundStyle(.white)
            Text("Tap + to log your first one.")
                .font(FragrancelogTheme.captionFont)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var list: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    editingItem = item
                } label: {
                    row(for: item)
                }
                .accessibilityIdentifier("row_\(item.id.uuidString)")
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(for item: Fragrance) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.brand).font(FragrancelogTheme.headlineFont).foregroundStyle(FragrancelogTheme.ink)
            Text(item.scentNotes).font(FragrancelogTheme.bodyFont).foregroundStyle(FragrancelogTheme.secondaryInk)
            Text(item.longevity).font(FragrancelogTheme.captionFont).foregroundStyle(FragrancelogTheme.secondaryInk)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= item.rating ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundStyle(FragrancelogTheme.accent)
                }
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(FragrancelogTheme.cardBackground)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: Store
    let itemToEdit: Fragrance?
    let onSave: (Fragrance) -> Void

    @State private var brand: String
    @State private var scentNotes: String
    @State private var longevity: String
    @State private var rating: Int
    @FocusState private var focusedField: Bool

    init(itemToEdit: Fragrance?, onSave: @escaping (Fragrance) -> Void) {
        self.itemToEdit = itemToEdit
        self.onSave = onSave
        _brand = State(initialValue: itemToEdit?.brand ?? "")
        _scentNotes = State(initialValue: itemToEdit?.scentNotes ?? "")
        _longevity = State(initialValue: itemToEdit?.longevity ?? "")
        _rating = State(initialValue: itemToEdit?.rating ?? 3)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Brand") {
                    TextField("Brand", text: $\brand)
                        .focused($focusedField)
                        .accessibilityIdentifier("field_brand")
                }
                Section("Scent Notes") {
                    TextField("Scent Notes", text: $\scentNotes)
                        .accessibilityIdentifier("field_scentNotes")
                }
                Section("Longevity") {
                    TextField("Longevity", text: $\longevity, axis: .vertical)
                        .accessibilityIdentifier("field_longevity")
                }
                Section("Rating") {
                    Picker("Rating", selection: $rating) {
                        ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = false
            }
            .navigationTitle(itemToEdit == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let base = itemToEdit ?? Fragrance(brand: brand, scentNotes: scentNotes, longevity: longevity)
                        var updated = base
                        updated.brand = brand
                        updated.scentNotes = scentNotes
                        updated.longevity = longevity
                        updated.rating = rating
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(brand.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
