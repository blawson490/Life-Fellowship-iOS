//
//  ContentView.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userSession = UserSession.shared
    var body: some View {
        VStack {
            if userSession.isLoading {
                ProgressView()
            } else {
                if userSession.user != nil {
                    RootView()
                } else {
                    NavigationStack {
                        OnboardingView()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}


// TODO:
// Autofocus first OTP
// Get Setup Profile if auth exists but user does not (Invalid Creds Error)
// Profile Image?
