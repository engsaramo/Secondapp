import Foundation

// Model
struct PlantReminder: Identifiable, Codable, Equatable {
    let id: UUID                // keep it stable!
    var name: String
    var room: String
    var light: String
    var waterAmount: String
    var isDone: Bool

    init(id: UUID = UUID(),
         name: String,
         room: String,
         light: String,
         waterAmount: String,
         isDone: Bool = false) {
        self.id = id
        self.name = name
        self.room = room
        self.light = light
        self.waterAmount = waterAmount
        self.isDone = isDone
    }
}
