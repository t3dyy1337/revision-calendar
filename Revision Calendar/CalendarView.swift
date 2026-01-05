//
//  CalendarView.swift
//  Revision Calendar
//
//  Created by Tadeáš Juříček on 04.01.2026.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.horizontalSizeClass) var hSize: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var vSize: UserInterfaceSizeClass?
    
    @State private var selectedEvent: Event? = nil
    @State private var reminderSheetDate: Date? = nil

    @State private var refreshID = UUID()
    
    @State private var baseDate: Date? = nil
    @State private var baseTitle = ""

    @State private var reminderOffsets: [Int] = [1, 3, 7]
    
    @State private var dragOffset: CGFloat = 0



    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.date, ascending: true)],
        animation: .default
    )
    private var events: FetchedResults<Event>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Reminder.date, ascending: true)],
        animation: .default
    )
    private var reminders: FetchedResults<Reminder>

    
    @State private var currentMonthOffset = 0
    
    var body: some View {
        ZStack {
            // solid background under everything
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            VStack {
                monthHeader
                
                GeometryReader { geo in
                    let isPortrait = geo.size.height > geo.size.width

                    Group {
                        if isPortrait {
                            calendarGrid(geo: geo)
                                .simultaneousGesture(
                                    DragGesture()
                                        .onEnded { value in
                                            let horizontal = value.translation.width
                                            let vertical = value.translation.height

                                            // Only react to clearly horizontal swipes
                                            guard abs(horizontal) > abs(vertical),
                                                  abs(horizontal) > 50
                                            else { return }

                                            withAnimation {
                                                if horizontal < 0 {
                                                    currentMonthOffset += 1   // swipe left → next month
                                                } else {
                                                    currentMonthOffset -= 1   // swipe right → previous month
                                                }
                                            }
                                        }
                                )
                                .id(refreshID)
                        } else {
                            ScrollView {
                                calendarGrid(geo: geo)
                                    .simultaneousGesture(
                                        DragGesture()
                                            .onEnded { value in
                                                let horizontal = value.translation.width
                                                let vertical = value.translation.height

                                                // Only react to clearly horizontal swipes
                                                guard abs(horizontal) > abs(vertical),
                                                      abs(horizontal) > 50
                                                else { return }

                                                withAnimation {
                                                    if horizontal < 0 {
                                                        currentMonthOffset += 1   // swipe left → next month
                                                    } else {
                                                        currentMonthOffset -= 1   // swipe right → previous month
                                                    }
                                                }
                                            }
                                    )
                                    .id(refreshID)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Calendar")
        .sheet(item: $selectedEvent) { event in
            DrawingPopup(event: event) {
                refreshID = UUID()
            }
        }
        .sheet(isPresented: Binding(
            get: { reminderSheetDate != nil },
            set: { if !$0 { reminderSheetDate = nil } }
        )) {

            let date = reminderSheetDate ?? Date()

            VStack(spacing: 16) {

                Text("Reminders for \(formatted(date))")
                    .font(.headline)

                // show list of reminders for that day
                List {
                    ForEach(remindersFor(date: date)) { reminder in
                        Text(reminder.text ?? "")
                    }
                }

                // add new reminder row
                AddReminderRow(date: date)

                Button("Close") {
                    reminderSheetDate = nil
                }
                .padding(.top)
            }
            .padding()
        }

        .sheet(isPresented: Binding(
            get: { baseDate != nil },
            set: { if !$0 { baseDate = nil } }
        )) {

            let startDate = baseDate ?? Date()
            let todaysReminders = remindersFor(date: startDate)

            VStack(spacing: 16) {

                // EXISTING REMINDERS (if any)
                if !todaysReminders.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Existing reminders")
                            .font(.subheadline)
                            .bold()

                        List {
                            ForEach(todaysReminders) { reminder in
                                HStack {
                                    Text(reminder.text ?? "")
                                        .lineLimit(1)

                                    Spacer()

                                    // delete menu per reminder
                                    Menu {
                                        Button("Delete only this reminder", role: .destructive) {
                                            deleteSingle(reminder)
                                        }
                                        Button("Delete this and all later reminders", role: .destructive) {
                                            deleteFutureReminders(from: reminder)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .frame(maxHeight: 200)
                    }
                    .padding(.horizontal)
                }

                // BELOW THIS, keep your "Create revision reminders" UI
                Text("Create revision reminders")
                    .font(.headline)

                TextField("What should I remind you about?", text: $baseTitle)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Reminder schedule (days)")
                        .font(.subheadline)
                        .bold()

                    ForEach(reminderOffsets.indices, id: \.self) { index in
                        HStack {
                            TextField("", value: $reminderOffsets[index], formatter: NumberFormatter())
                                .keyboardType(.numberPad)

                            if reminderOffsets.count > 1 {
                                Button(role: .destructive) {
                                    reminderOffsets.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle")
                                }
                            }
                        }
                    }

                    Button {
                        reminderOffsets.append(1)
                    } label: {
                        Label("Add another reminder", systemImage: "plus.circle")
                    }
                }
                .padding(.horizontal)

                Button("Create reminders") {
                    createFollowUps(title: baseTitle, start: startDate)
                    baseTitle = ""
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    baseDate = nil
                }
                .foregroundColor(.secondary)
            }
            .padding()

        }
        .onAppear {
                    if let saved = UserDefaults.standard.array(forKey: "reminderOffsets") as? [Int] {
                        reminderOffsets = saved
                    }
                }
        .onChange(of: reminderOffsets) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "reminderOffsets")
                }

    }

    
    // MARK: - Calendar logic
    
    var monthHeader: some View {
        HStack {
            Button(action: { currentMonthOffset -= 1 }) {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(formattedMonth(currentMonth()))
                .font(.title3)
                .bold()

            Spacer()

            Button(action: { currentMonthOffset += 1 }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()

    }
    
    @ViewBuilder
    func calendarGrid(geo: GeometryProxy) -> some View {
        let width = geo.size.width
        let height = geo.size.height
        let rows = 6
        let isPortrait = height > width
        let isPhone = hSize == .compact

        let targetTileSize: CGFloat = 120
        let preferredColumns = max(4, min(7, Int(width / targetTileSize)))
        
        let columns = isPhone && isPortrait ? 5 : preferredColumns

        let availableHeight = height - 40
        let tileWidth = width / CGFloat(columns)
        let tileHeight = availableHeight / CGFloat(rows)

        let portraitTile = min(tileWidth, tileHeight) * 1.15
        let tileSize = isPortrait ? portraitTile : tileWidth

        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: columns),
            spacing: 4
        ) {
            ForEach(daysInMonth(), id: \.self) { date in
                let isPad = UIDevice.current.userInterfaceIdiom == .pad
                DayCell(
                    date: date,
                    events: eventsFor(date: date),
                    reminders: remindersFor(date: date),
                    onTapReminders: {
                        baseDate = date
                    },
                    onTapDrawing: {
                        let event = eventForDate(date)
                        selectedEvent = event
                    }
                )

                    .frame(height: tileSize)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        baseDate = date
                    }



            }
        }
        .padding()
    }
    
    struct AddReminderRow: View {
        @Environment(\.managedObjectContext) var context
        @State private var text = ""
        let date: Date

        var body: some View {
            HStack {
                TextField("New reminder", text: $text)

                Button("Add") {
                    guard !text.isEmpty else { return }

                    let r = Reminder(context: context)
                    r.id = UUID()
                    r.text = text
                    r.date = date

                    try? context.save()
                    text = ""
                }
            }
        }
    }

    
    func currentMonth() -> Date {
        Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date())!
    }
    
    func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth()))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    func eventsFor(date: Date) -> [Event] {
        events.filter { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date) }
    }
    
    func formattedMonth(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }
    
    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    
    func eventForDate(_ date: Date) -> Event {
        if let existing = eventsFor(date: date).first {
            return existing
        }

        let new = Event(context: context)
        new.id = UUID()
        new.date = date
        new.title = "Reminder"
        return new
    }
    
    func remindersFor(date: Date) -> [Reminder] {
        reminders.filter { reminder in
            guard let reminderDate = reminder.date else { return false }
            return Calendar.current.isDate(reminderDate, inSameDayAs: date)
        }
    }
    
    func createFollowUps(title: String, start: Date) {
        let calendar = Calendar.current

        for offset in reminderOffsets {
            if let date = calendar.date(byAdding: .day, value: offset, to: start) {
                let r = Reminder(context: context)
                r.id = UUID()
                r.text = title
                r.date = date
            }
        }

        try? context.save()
    }
    
    func deleteFutureReminders(from reminder: Reminder) {
        guard let date = reminder.date,
              let text = reminder.text else { return }

        let future = reminders.filter { r in
            guard let rDate = r.date, let rText = r.text else { return false }
            return rText == text && rDate >= date
        }

        future.forEach { context.delete($0) }
        try? context.save()
    }
    
    func deleteSingle(_ reminder: Reminder) {
        context.delete(reminder)
        try? context.save()
    }







}
#Preview {
    ContentView()
        .environment(\.managedObjectContext,
                     PersistenceController.shared.container.viewContext)
}
