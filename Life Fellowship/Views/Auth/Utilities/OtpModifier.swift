//
//  OtpModifier.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import SwiftUI
import Combine

struct OtpModifier: ViewModifier {
    @Binding var pin: String
    
    var textLimit = 1
    
    func limitText(_ upper: Int) {
        if pin.count > upper {
            self.pin = String(pin.prefix(upper))
        }
    }
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .onReceive(Just(pin)) {_ in limitText(textLimit)}
            .frame(width: 45, height: 45)
            .background(Color.white.cornerRadius(5))
    }
}
