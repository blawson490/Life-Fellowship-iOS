//
//  OTPVerificationView.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import SwiftUI

struct OTPVerificationView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isKeyboardShowing: Bool
    
    @State private var isLoading = false
    
    @State private var codeSent = false
    @State private var remainingTime = 30
    @State private var timer: Timer?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "arrow.left")
                        .font(.largeTitle)
                        .foregroundStyle(Color(uiColor: .label))
                })
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
                
                NavigationLink(destination: SignInWithEmail().environmentObject(viewModel), label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .padding(8)
                        .padding(.horizontal, 4)
                        .background{
                            Capsule()
                                .stroke(Color.gray.opacity(0.25), lineWidth: 2)
                        }
                })
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text("Confirm number ☎️")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter the code we sent to the number ending in **\(viewModel.endingFourNumbers())**.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            HStack(spacing: 0){
                ForEach(0..<6,id: \.self){index in
                    OTPTextBox(index)
                }
            }
            .background(content: {
                TextField("", text: $viewModel.otpText.limit(6))
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .frame(width: 1, height: 1)
                    .opacity(0.001)
                    .blendMode(.screen)
                    .focused($isKeyboardShowing)
            })
            .contentShape(Rectangle())
            .onTapGesture {
                isKeyboardShowing = true
            }
            .padding(.bottom,20)
            .padding(.top,10)
            
            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        Text("Didn't recieve the code?")
                            .fontWeight(.light)
                        Button(action: {
                            sendCode()
                        }, label: {
                            Text("Send again")
                                .fontWeight(.semibold)
                        })
                        .disabled(codeSent)
                        
                        if codeSent {
                            Text("\(remainingTime)s")
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                                .font(.caption)
                        }
                    }
                    Spacer()
                }
                .disabled(isLoading)
                .padding(.leading)
                
                Text("\(viewModel.errorText)")
                    .padding(.leading)
                    .padding(.top, 4)
                    .font(.caption)
                    .foregroundStyle(.red)

            }
            
            Spacer()
            
//            NavigationLink(destination: ProfileSetup(), label: {
            Button(action: {
                Task {
                    isLoading = true
                    await viewModel.verifyCode()
                    isLoading = false
                }
            }, label: {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Text("Verify")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding()
                    }
                    Spacer()
                }
                .background {
                    Capsule()
                        .fill(Color.accentColor)
                }
            })
            .disabled(viewModel.otpText.count != 6 || viewModel.isLoading)
            .padding()
            
            NavigationLink(destination: ProfileSetup().environmentObject(viewModel), isActive: $viewModel.showProfileSetup) {
                EmptyView()
            }
        }
        .onAppear {
             sendCode()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .navigationBarBackButtonHidden()
        
    }
    
    func startTimer() {
        codeSent = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                codeSent = false
                timer.invalidate()
            }
        }
    }
    
    func sendCode() {
        viewModel.isLoading = true
        Task {
            do {
                await viewModel.sendPhoneCode()
            }
        }
        remainingTime = 30
        
        timer?.invalidate()
        startTimer()
    }
    
    @ViewBuilder
    func OTPTextBox(_ index: Int)->some View{
        ZStack{
            if viewModel.otpText.count > index{
                let startIndex = viewModel.otpText.startIndex
                let charIndex = viewModel.otpText.index(startIndex, offsetBy: index)
                let charToString = String(viewModel.otpText[charIndex])
                Text(charToString)
            }else{
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .background {
            let status = (isKeyboardShowing && viewModel.otpText.count == index)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(status ? Color.accentColor : Color.gray, lineWidth: status ? 2 : 1)
                .animation(.easeInOut(duration: 0.2), value: isKeyboardShowing)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OTPVerificationView()
        .environmentObject(AuthViewModel())
}
