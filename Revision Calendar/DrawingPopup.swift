//
//  DrawingPopup.swift
//  Revision Calendar
//
//  Created by Tadeáš Juříček on 05.01.2026.
//

import SwiftUI
import PencilKit

struct DrawingPopup: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var event: Event
    var onSave: () -> Void
    @State private var canvasView = PKCanvasView()
    
    @State private var newReminderText = ""


    let colors: [UIColor] = [.black, .red, .orange, .green, .blue, .purple]
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Reminder.date, ascending: true)],
        animation: .default
    )
    private var allReminders: FetchedResults<Reminder>

    
    var body: some View {
        VStack(spacing: 16) {
            Text(event.title ?? "Reminder")
                .font(.headline)
            

            DrawingCanvas(
                canvasView: $canvasView,
                data: event.drawingData
            )
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                )
            
            Button("Done") {
                saveDrawing()
                onSave()
                dismiss()
            }
            .buttonStyle(.borderedProminent)

        }
        .padding()
        .onDisappear {
            saveDrawing()
        }
    }
    
    func saveDrawing() {
        let data = canvasView.drawing.dataRepresentation()
        event.drawingData = data
        try? context.save()
    }
    
    func remindersForDay() -> [Reminder] {
        allReminders.filter { reminder in
            guard let reminderDate = reminder.date else { return false }
            return Calendar.current.isDate(reminderDate, inSameDayAs: event.date ?? Date())
        }
    }

}
