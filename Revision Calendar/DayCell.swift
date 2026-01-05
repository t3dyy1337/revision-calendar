//
//  DayCell.swift
//  Revision Calendar
//
//  Created by Tadeáš Juříček on 04.01.2026.
//

//
//  DayCell.swift
//  Revision Calendar
//
//  Created by Tadeáš Juříček on 04.01.2026.
//

import SwiftUI
import PencilKit
import UIKit

struct DayCell: View {
    let date: Date
    let events: [Event]
    let reminders: [Reminder]
    let onTapReminders: (() -> Void)?
    let onTapDrawing: (() -> Void)?
    
    var body: some View {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        VStack(spacing: 4) {
            // Day number
            Text(dayNumber(date))
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 4) {
                // Reminders
                remindersPreview
                
                // Drawing preview only on iPad
                if isPad {
                    Spacer(minLength: 2)
                    GeometryReader { geo in
                        drawingThumbnail
                            .frame(width: geo.size.width, height: geo.size.height)
                            .contentShape(Rectangle())
                            .onTapGesture { onTapDrawing?() }   // 👈 draw
                    }
                }

            }
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Reminders
    
    @ViewBuilder
    var remindersPreview: some View {
        Group {
            if reminders.isEmpty {
                Text("No reminders")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                let first = reminders.first!
                let extra = reminders.count - 1

                HStack(spacing: 4) {
                    Text(first.text ?? "")
                        .font(.caption2)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    if extra > 0 {
                        Text("+\(extra) more")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize()
                            .layoutPriority(1)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture { onTapReminders?() }
    }




    
    // MARK: - Drawing thumbnail
    
    @ViewBuilder
    var drawingThumbnail: some View {
        if let data = events.first?.drawingData,
           let drawing = try? PKDrawing(data: data) {

            GeometryReader { geo in
                
                // Use the drawing's real bounds
                let drawingBounds = drawing.bounds
                            
                            
                let padding: CGFloat = 40
                let bounds = drawingBounds.insetBy(dx: -padding, dy: -padding)
                            
                let image = drawing.image(from: bounds, scale: 1)

                ZStack {
                    Color.white
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                )
            }

        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                )
        }
    }


    // MARK: - Helpers
    
    func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }
}
