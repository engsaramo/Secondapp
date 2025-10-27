import SwiftUI

struct EditReminder: View {
    @ObservedObject var vm: PlantViewModel
    let reminderID: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var plantName: String
    @State private var selectedRoom: String
    @State private var selectedLight: String
    @State private var selectedWatering: String = "Every day"
    @State private var selectedWaterAmount: String

    private let roomOptions = ["Kitchen", "Bedroom", "Living Room", "Balcony", "Bathroom"]
    private let lightOptions = ["Full sun", "Partial sun", "Low light"]
    private let wateringOptions = ["Every day","Every 2 days","Every 3 days","Once a week","Every 10 days","Every 2 weeks"]
    private let waterAmountOptions = ["20–50 ml", "50–100 ml", "100–200 ml", "200-200 ml"]

    private var cardBG: some View { RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground)) }

    init(vm: PlantViewModel, reminder: PlantReminder) {
        self._vm = ObservedObject(wrappedValue: vm)
        self.reminderID = reminder.id
        _plantName = State(initialValue: reminder.name)
        _selectedRoom = State(initialValue: reminder.room)
        _selectedLight = State(initialValue: reminder.light)
        _selectedWaterAmount = State(initialValue: reminder.waterAmount)
        UIView.appearance().overrideUserInterfaceStyle = .dark
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 24) {
                    // Top bar (X only; no checkmark)
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.black))
                        }
                        Spacer()
                        Text("Set Reminder").font(.headline)
                        Spacer()
                        Color.clear.frame(width: 44, height: 44).clipShape(Circle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Plant Name
                    HStack {
                        Text("Plant Name").foregroundColor(.gray)
                        Spacer()
                        TextField("Pothos", text: $plantName)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                    }
                    .frame(minHeight: 56)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(cardBG)
                    .padding(.horizontal, 20)

                    // Room & Light
                    VStack(spacing: 0) {
                        row(label: "Room", systemImage: "paperplane") {
                            Menu { ForEach(roomOptions, id: \.self) { r in Button(r){ selectedRoom = r } } }
                            label: { trailingPickerText(selectedRoom) }
                        }
                        Divider().background(Color.white.opacity(0.08))
                        row(label: "Light", systemImage: "sun.max") {
                            Menu { ForEach(lightOptions, id: \.self) { l in Button(l){ selectedLight = l } } }
                            label: { trailingPickerText(selectedLight) }
                        }
                    }
                    .background(cardBG)
                    .padding(.horizontal, 20)

                    // Watering Days & Water
                    VStack(spacing: 0) {
                        row(label: "Watering Days", systemImage: "drop") {
                            Menu { ForEach(wateringOptions, id: \.self) { w in Button(w){ selectedWatering = w } } }
                            label: { trailingPickerText(selectedWatering) }
                        }
                        Divider().background(Color.white.opacity(0.08))
                        row(label: "Water", systemImage: "drop") {
                            Menu { ForEach(waterAmountOptions, id: \.self) { v in Button(v){ selectedWaterAmount = v } } }
                            label: { trailingPickerText(selectedWaterAmount) }
                        }
                    }
                    .background(cardBG)
                    .padding(.horizontal, 20)

                    // Delete
                    Button(role: .destructive) {
                        vm.delete(reminderID)
                        dismiss()
                    } label: {
                        Text("Delete Reminder")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(RoundedRectangle(cornerRadius: 18).fill(Color.red.opacity(0.18)))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)

                    Spacer()
                }
            }
        }
        .onDisappear {
            vm.updateReminder(id: reminderID,
                              name: plantName,
                              room: selectedRoom,
                              light: selectedLight,
                              waterAmount: selectedWaterAmount)
        }
    }
}

private extension EditReminder {
    @ViewBuilder
    func row<Content: View>(
        label: String,
        systemImage: String,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack {
            Label(label, systemImage: systemImage).foregroundColor(.white)
            Spacer()
            trailing()
        }
        .frame(minHeight: 56)
        .padding(.horizontal, 16)
    }

    func trailingPickerText(_ text: String) -> some View {
        HStack(spacing: 6) {
            Text(text).foregroundColor(.gray)
            Image(systemName: "chevron.up.chevron.down").font(.footnote)
        }
    }
}
