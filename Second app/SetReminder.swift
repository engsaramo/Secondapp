import SwiftUI

struct SetReminder: View {
    @ObservedObject var vm: PlantViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var plantName: String = ""
    @State private var selectedRoom: String = "Kitchen"
    @State private var selectedLight: String = "Full sun"
    @State private var selectedWatering: String = "Every day"
    @State private var selectedWaterAmount: String = "20–50 ml"

    private let roomOptions = ["Kitchen", "Bedroom", "Living Room", "Balcony", "Bathroom"]
    private let lightOptions = ["Full sun", "Partial sun", "Low light"]
    private let wateringOptions = ["Every day","Every 2 days","Every 3 days","Once a week","Every 10 days","Every 2 weeks"]
    private let waterAmountOptions = ["20–50 ml", "50–100 ml", "100–200 ml", "200-300 ml"]

    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground))
    }

    init(vm: PlantViewModel) {
        self._vm = ObservedObject(initialValue: vm)
        UIView.appearance().overrideUserInterfaceStyle = .dark
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 24) {
                    // Top bar
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.black))
                                .glassEffect(.clear.interactive().tint(.baseGreen))
                                
                        }.buttonStyle(.plain)
                        Spacer()
                        Text("Set Reminder").font(.headline)
                        Spacer()
                        Button {
                            vm.addReminder(
                                name: plantName,
                                room: selectedRoom,
                                light: selectedLight,
                                waterAmount: selectedWaterAmount
                            )
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.baseGreen))
                                .glassEffect(.clear.interactive().tint(.baseGreen))

                        }.buttonStyle(.plain)
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

                    Spacer()
                }
            }
        }
    }
}

private extension SetReminder {
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
