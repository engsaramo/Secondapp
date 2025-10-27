import SwiftUI

struct ContentView2: View {
    @State private var sheet = false
    @State private var editing: PlantReminder? = nil
    // ✅ New: when all items get checked we delete them and show the success page
    @State private var showCompletion = false

    @ObservedObject private var vm = PlantViewModel.shared

    init() { UIView.appearance().overrideUserInterfaceStyle = .dark }

    var body: some View {
        NavigationView {
            Group {
                // ✅ Show the success screen right after we auto-delete all rows
                if showCompletion {
                    VStack {
                        // Header
                        VStack(alignment:.leading) {
                            Text("My Plants 🌱")
                                .font(.system(size: 34, weight: .bold))
                                .padding(.leading, -180)
                        }
                        VStack(alignment:.center, spacing: 0) {
                            Divider()
                            Rectangle().frame(width: 413, height: 1).foregroundColor(.gray)
                        }

                        // Success content
                        VStack(spacing: 16) {
                            Image("complete")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220, height: 220)
                                .padding(.top, 24)
                                .transition(.scale)

                            Text("All Done! 🎉")
                                .font(.system(size: 24, weight: .bold))

                            Text("All Reminders Completed")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)

                        Spacer()

                        // Add button like your other pages
                        HStack {
                            Spacer()
                            Button {
                                editing = nil
                                sheet = true
                                // Hide success once user adds again (optional)
                                // showCompletion = false
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Circle().fill(Color.baseGreen))
                            }
                            .padding(.trailing, 24)
                            .padding(.bottom, 12)
                        }
                    }
                    .sheet(isPresented: $sheet, onDismiss: {
                        editing = nil
                        // If they added nothing, you can keep the success screen;
                        // automatically hide it when there are reminders again:
                        if !vm.reminders.isEmpty { showCompletion = false }
                    }) {
                        SetReminder(vm: vm).ignoresSafeArea()
                    }

                } else if vm.reminders.isEmpty {
                    // ===== Your original empty state (unchanged) =====
                    VStack {
                        VStack(alignment:.leading) {
                            Text("My Plants 🌱")
                                .font(.system(size: 34, weight: .bold))
                                .padding(.leading, -180)
                        }

                        VStack(alignment:.center, spacing: 0) {
                            Divider()
                            Rectangle().frame(width: 413, height: 1).foregroundColor(.gray)
                        }

                        VStack(alignment: .center) {
                            Image("Image").resizable().frame(width: 164, height: 200).padding(10)
                            Text("Start your plant journey!")
                                .font(.system(size:25)).fontWeight(.bold).multilineTextAlignment(.center).padding(10)
                            Text("Now all your plants will be in one place and                    we will help you take care of them :)🪴")
                                .font(.system(size: 16)).foregroundColor(.gray).multilineTextAlignment(.center)
                        }
                        .position(x: 200, y: 230)

                        VStack(alignment: .center) {
                            Button {
                                editing = nil
                                sheet = true
                            } label: {
                                Text("Set Plant Reminder")
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .background(Color.baseGreen)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 40)
                                    .glassEffect()
                            }
                            .position(x: 200, y: 160)
                        }
                    }
                    .sheet(isPresented: $sheet, onDismiss: { editing = nil }) {
                        SetReminder(vm: vm).ignoresSafeArea()
                    }

                } else {
                    // ===== Main list page (kept as-is) =====
                    VStack(alignment:.leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("My Plants 🌱")
                                .font(.system(size: 34, weight: .bold))
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 16)

                        VStack(alignment: .center, spacing: 10) {
                            if vm.completedCount == 0 {
                                Text("Your plants are waiting for a sip 💦")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.95))
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("\(vm.completedCount) of your plants feel loved today ✨")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.95))
                                    .multilineTextAlignment(.center)
                            }

                            WideProgressBar(progress: vm.overallProgress)
                                .padding(.horizontal, 16)
                        }
                        .padding(.top, 2)
                        // ✅ Detect when ALL are checked → delete all → show success page
                        .onChange(of: vm.completedCount) { _ in
                            // All checked if completed == total and not empty
                            if !vm.reminders.isEmpty && vm.completedCount == vm.reminders.count {
                                // Delete everything using your existing delete(id:)
                                let ids = vm.reminders.map(\.id)
                                withAnimation(.spring()) {
                                    ids.forEach { vm.delete($0) }
                                    showCompletion = true   // show the success screen
                                }
                            }
                        }

                        ScrollView {
                            VStack(spacing: 0) {
                                // Use a stable id to ensure deletes reflect immediately
                                ForEach(vm.reminders, id: \.id) { r in
                                    PlantRow(
                                        reminder: r,
                                        progress: vm.progressFor(r.id),
                                        onTapBigCircle: {
                                            withAnimation(.easeInOut) {
                                                vm.toggleDone(for: r.id)
                                            }
                                        },
                                        onDelete: {
                                            withAnimation(.spring()) {
                                                vm.delete(r.id)
                                            }
                                        },
                                        onTapRow: { editing = r }
                                    )
                                    Rectangle()
                                        .fill(Color.white.opacity(0.12))
                                        .frame(height: 1)
                                        .padding(.leading, 56)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }

                        Spacer()

                        HStack {
                            Spacer()
                            Button {
                                editing = nil
                                sheet = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Circle().fill(Color.baseGreen))
                            }
                            .padding(.trailing, 24)
                            .padding(.bottom, 12)
                        }
                    }
                    .sheet(isPresented: $sheet, onDismiss: { editing = nil }) {
                        SetReminder(vm: vm).ignoresSafeArea()
                    }
                    .sheet(item: $editing) { item in
                        EditReminder(vm: vm, reminder: item).ignoresSafeArea()
                    }
                }
            }
        }
    }
}

private struct WideProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.16))
                Capsule()
                    .fill(Color.baseGreen)
                    .frame(width: max(0, min(1, progress)) * width)
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
    }
}

private struct PlantRow: View {
    let reminder: PlantReminder
    let progress: Double
    let onTapBigCircle: () -> Void
    let onDelete: () -> Void
    let onTapRow: () -> Void

    @State private var offsetX: CGFloat = 0
    @State private var isHorizontalDrag = false

    var body: some View {
        ZStack {
            // 1) The row content that slides left
            content
                .offset(x: offsetX)
                // When the delete button is showing, prevent the row from eating taps
                .allowsHitTesting(offsetX >= -60)
                .contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture(minimumDistance: 6, coordinateSpace: .local)
                        .onChanged { value in
                            if !isHorizontalDrag {
                                isHorizontalDrag = abs(value.translation.width) > abs(value.translation.height)
                            }
                            guard isHorizontalDrag else { return }

                            let dx = value.translation.width
                            if dx < 0 {
                                offsetX = max(dx, -90)   // reveal up to 90pt
                            } else {
                                offsetX = min(0, dx)     // close
                            }
                        }
                        .onEnded { _ in
                            guard isHorizontalDrag else { return }
                            withAnimation(.spring()) {
                                offsetX = (offsetX < -60) ? -90 : 0
                            }
                            isHorizontalDrag = false
                        }
                )
                .onTapGesture {
                    if offsetX == 0 { onTapRow() }
                    else { withAnimation(.spring()) { offsetX = 0 } }
                }

            // 2) The trailing delete button ABOVE the content (so it’s tappable)
            HStack {
                Spacer()
                Button(role: .destructive) {
                    withAnimation(.spring()) {
                        onDelete()   // removes the item from vm.reminders
                        offsetX = 0  // cosmetic reset
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red)
                        )
                }
                .padding(.trailing, 16)
                .opacity(offsetX < -5 ? 1 : 0)
                // Only allow hits when revealed
                .allowsHitTesting(offsetX < -5)
            }
        }
        .clipped()
        .padding(.vertical, 6)
        .animation(.easeInOut, value: offsetX)
    }

    private var content: some View {
        HStack(spacing: 12) {
            Button(action: onTapBigCircle) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if progress >= 1.0 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.baseGreen)
                            .font(.system(size: 28))
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "paperplane")
                    Text("in \(reminder.room)")
                    Spacer()
                }
                .font(.caption)
                .foregroundColor(.gray)

                Text(reminder.name)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "sun.max").foregroundColor(.yellowSun)
                        Text(reminder.light).foregroundColor(.yellowSun)
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                    )

                    HStack(spacing: 6) {
                        Image(systemName: "drop").foregroundColor(.blueDrop)
                        Text(reminder.waterAmount).foregroundColor(.blueDrop)
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                    )
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color.clear)
    }
}

extension View  { func glassEffect() -> some View { self } }

#Preview {
    ContentView2()
        .preferredColorScheme(.dark)
}
