//
//  KeyboardInput.swift
//  TouchGame
//
//  Created by Frode Halrynjo on 18/02/2026.
//
import SwiftUI
import UIKit

// --- KEYBOARD HANDLING ---

class InvisibleTextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect { .zero }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool { false }
}

struct KeyboardInputView: UIViewRepresentable {
    var onKeyPress: (String) -> Void
    
    func makeUIView(context: Context) -> InvisibleTextField {
        let textField = InvisibleTextField()
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.spellCheckingType = .no
        textField.inputView = UIView()
        textField.becomeFirstResponder()
        return textField
    }
    
    func updateUIView(_ uiView: InvisibleTextField, context: Context) {
        if !uiView.isFirstResponder { uiView.becomeFirstResponder() }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: KeyboardInputView
        init(parent: KeyboardInputView) { self.parent = parent }
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if !string.isEmpty { parent.onKeyPress(string) }
            return false
        }
    }
}
