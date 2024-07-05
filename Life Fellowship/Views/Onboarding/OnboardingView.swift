//
//  OnboardingView.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import SwiftUI

struct OnboardingView: View {
    var images: [String] = ["welcome", "connected", "message", "support", "get started"]
    var titles: [String] = ["Welcome to Life Fellowship!", "Stay Connected", "Get Involved", "Give and Support", "Get Started"]
    var descriptions: [String] = ["Experience a new way to stay connected with our community!", "Watch or listen to past sermons from anywhere and never miss an event or announcement.", "Join life groups, request prayer, and explore resources to grow in your faith.", "Easily support our mission by giving directly within the app, and learn about volunteer opportunities.", "Ready to explore? Dive into the Life Fellowship App and join us as we Love all, Serve all, and Worship one. Welcome Home."]
    @State private var selectedInfoIndex = 0
    var body: some View {
        VStack {
            Spacer()
            TabView(selection: $selectedInfoIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    InfoView(image: images[index], title: titles[index], description: descriptions[index])
                        .tag(index)
                        .transition(.slide)
                        .animation(.easeInOut, value: selectedInfoIndex)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
//            .indexViewStyle(.page(backgroundDisplayMode: .always))
            Spacer()
            
            if selectedInfoIndex < images.count - 1 {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedInfoIndex = images.count - 1
                        }
                    }, label: {
                        Text("Skip")
                            .foregroundStyle(Color(uiColor: .label))
                    })
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedInfoIndex += 1
                        }
                    }, label: {
                        HStack {
                            Text("Next")
                                .foregroundStyle(Color.white)
                            Image(systemName: "arrow.forward")
                                .foregroundStyle(Color.white)
                        }
                        .fontWeight(.semibold)
                            .padding()
                            .background {
                                Capsule()
                                    .fill(Color.accentColor)
                            }
                    })
                }
            } else {
                NavigationLink(destination: PhoneNumberView().environmentObject(AuthViewModel()), label: {
                    HStack {
                        Spacer()
                        Text("Get Started.")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding()
                        Spacer()
                    }
                    .background(
                        Capsule()
                            .fill(Color.accentColor)
                    )
                    .padding(.horizontal)
                })
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func InfoView(image: String, title: String, description: String) -> some View {
        VStack {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 40)
            
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.vertical)
            
            Text(description)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
}
