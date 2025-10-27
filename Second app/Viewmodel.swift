import Foundation
import Combine

final class PlantViewModel: ObservableObject {
    static let shared = PlantViewModel()

    @Published var reminders: [PlantReminder] = []
    @Published var progress: [UUID: Double] = [:]   // 0.0 ... 1.0

    // Create
    func addReminder(name: String, room: String, light: String, waterAmount: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = PlantReminder(name: trimmed, room: room, light: light, waterAmount: waterAmount)
        reminders.append(item)
        progress[item.id] = 0
    }

    // Update
    func updateReminder(id: UUID, name: String, room: String, light: String, waterAmount: String) {
        guard let i = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[i].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        reminders[i].room = room
        reminders[i].light = light
        reminders[i].waterAmount = waterAmount
    }

    // Progress (tap big circle to toggle done/not-done)
    func toggleDone(for id: UUID) {
        let isDone = (progress[id] ?? 0) >= 1.0
        progress[id] = isDone ? 0.0 : 1.0
    }

    func progressFor(_ id: UUID) -> Double { progress[id] ?? 0 }

    var completedCount: Int {
        reminders.filter { (progress[$0.id] ?? 0) >= 1.0 }.count
    }

    var overallProgress: Double {
        guard !reminders.isEmpty else { return 0 }
        let sum = reminders.reduce(0.0) { $0 + (progress[$1.id] ?? 0) }
        return sum / Double(reminders.count)
    }

    // Delete
    func delete(_ id: UUID) {
        reminders.removeAll { $0.id == id }
        progress[id] = nil
    }
    
    
    
    
    
   
}
