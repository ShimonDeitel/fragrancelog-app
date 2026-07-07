import Foundation

struct Fragrance: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var brand: String
    var scentNotes: String
    var longevity: String
    var rating: Int

    init(id: UUID = UUID(), date: Date = Date(), brand: String, scentNotes: String, longevity: String, rating: Int = 3) {
        self.id = id
        self.date = date
        self.brand = brand
        self.scentNotes = scentNotes
        self.longevity = longevity
        self.rating = rating
    }
}
