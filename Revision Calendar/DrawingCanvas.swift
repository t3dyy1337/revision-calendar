//
//  DrawingCanvas.swift
//  Revision Calendar
//
//  Created by Tadeáš Juříček on 05.01.2026.
//

import SwiftUI
import PencilKit

struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var data: Data?
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        
        if let data = data,
           let drawing = try? PKDrawing(data: data) {
            canvasView.drawing = drawing
        }

        // === Apple Tool Picker ===
        if #available(iOS 17.0, *) {
            let toolPicker = PKToolPicker()
            toolPicker.addObserver(canvasView)
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        } else {
            if let window = UIApplication.shared.windows.first,
               let toolPicker = PKToolPicker.shared(for: window) {

                toolPicker.addObserver(canvasView)
                toolPicker.setVisible(true, forFirstResponder: canvasView)
                canvasView.becomeFirstResponder()
            }
        }
        
        canvasView.alwaysBounceVertical = false
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
