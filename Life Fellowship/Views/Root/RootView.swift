//
//  RootView.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var userSession = UserSession.shared
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Logged In")
            Button(action: {
                Task {
                    do {
                        try await userSession.logoutUser()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }, label: {
                HStack {
                    Spacer()
                    Text("Logout")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding()
                    Spacer()
                }
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.red)
                }
            })
            .padding()
        }
        .padding()
    }
}

#Preview {
    RootView()
}
