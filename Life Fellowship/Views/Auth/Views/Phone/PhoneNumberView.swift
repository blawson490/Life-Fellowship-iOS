//
//  PhoneNumberView.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import SwiftUI

struct PhoneNumberView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    enum FocusedField {
        case number
    }
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: FocusedField?
    @State private var isSignUp = true
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
                    Text("Use Email")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(uiColor: .label))
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
                Text("Enter phone number ☎️")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("We will send an OTP Verification to you.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            VStack(alignment: .leading) {
                PhoneNumberTextBox(number: $viewModel.phoneNumber)
            }
            .padding()
            
            Spacer()
            
            NavigationLink(destination:
                            OTPVerificationView().environmentObject(viewModel),
                           label: {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Text("Send me the code")
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
            .disabled(viewModel.phoneNumber.count < 10 || viewModel.isLoading)
            .padding()
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            focusedField = .number
        }
    }
    
    @ViewBuilder
    private func PhoneNumberTextBox(number: Binding<String>) -> some View {
        HStack {
            Text("+1")
                .foregroundStyle(.secondary)
                .padding(.leading)
            TextField("Phone Number", text: number)
                .padding([.vertical, .trailing])
                .focused($focusedField, equals: .number)
                .textContentType(.telephoneNumber)
                .keyboardType(.numberPad)
                .disabled(viewModel.isLoading)
        }
        .background {
            RoundedRectangle(cornerRadius: 6)
                .stroke(focusedField == .number ? Color.accentColor : Color.secondary, lineWidth: 2)
        }
    }
    
}

#Preview {
    NavigationStack {
        PhoneNumberView().environmentObject(AuthViewModel())
    }
}
