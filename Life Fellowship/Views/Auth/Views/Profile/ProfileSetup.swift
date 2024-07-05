//
//  ProfileSetup.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import SwiftUI

struct ProfileSetup: View {
    @EnvironmentObject var viewModel: AuthViewModel
    enum FocusedField {
        case firstName, lastName, email, number, password, confirmPassword
    }
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: FocusedField?
    var body: some View {
        VStack {
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
                
                NavigationLink(destination: PhoneNumberView().environmentObject(viewModel), label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .padding(8)
                        .foregroundStyle(Color(uiColor: .label))
                        .padding(.horizontal, 4)
                        .background{
                            Capsule()
                                .stroke(Color.gray.opacity(0.25), lineWidth: 2)
                        }
                })
            }
            .padding()
            
            
            ScrollView {
            VStack(alignment: .leading) {
                Text("Set up your profile ✍️")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter your information below to create your account.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
                VStack(spacing: 16) {
                    CustomSignUpTextField(text: $viewModel.firstName, placeholder: "First Name*", focusedField: $focusedField, field: .firstName, nextField: .lastName)
                    
                        CustomSignUpTextField(text: $viewModel.lastName, placeholder: "Last Name*", focusedField: $focusedField, field: .lastName, nextField: .email)
                        
                    CustomSignUpTextField(text: $viewModel.email, placeholder: "Email*", focusedField: $focusedField, field: .email, nextField: .password).textInputAutocapitalization(.never)
                        
                        CustomSignUpTextField(text: $viewModel.password, placeholder: "Password*", isSecure: true, showing: $viewModel.isPasswordShowing, focusedField: $focusedField, field: .password, nextField: .confirmPassword)
                        
                        CustomSignUpTextField(text: $viewModel.confirmPassword, placeholder: "Confirm Password*", isSecure: true, showing: $viewModel.isConfirmPasswordShowing, focusedField: $focusedField, field: .confirmPassword, nextField: nil)
                        
//                        Text("By clicking continue you agree to recieve communications from life fellowship, and understand that you can opt out of this at any time.")
//                            .foregroundStyle(.secondary)
//                            .padding()
                    
                }
                .padding(.top, 8)
            }
        
            Button(action: {
                viewModel.isLoading = true
                Task {
                    do {
                        await viewModel.createUserProfile()
                    }
                }
            }, label: {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Text("Continue")
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
            .disabled(viewModel.firstName.isEmpty || viewModel.lastName.isEmpty || viewModel.isLoading)
            .padding()
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private func CustomSignUpTextField(
        text: Binding<String>,
        placeholder: String,
        isSecure: Bool = false,
        showing: Binding<Bool>? = nil,
        focusedField: FocusState<FocusedField?>.Binding,
        field: FocusedField,
        nextField: FocusedField?
    ) -> some View {
        HStack {
            if isSecure, let showing = showing {
                Group {
                    if showing.wrappedValue {
                        TextField(placeholder, text: text)
                            .padding()
                            .textContentType(.password)
                            .focused(focusedField, equals: field)
                            .submitLabel(nextField == nil ? .done : .next)
                            .onSubmit {
                                if let next = nextField {
                                    focusedField.wrappedValue = next
                                } else {
                                    focusedField.wrappedValue = nil
                                }
                            }
                    } else {
                        SecureField(placeholder, text: text)
                            .padding()
                            .textContentType(.password)
                            .focused(focusedField, equals: field)
                            .submitLabel(nextField == nil ? .done : .next)
                            .onSubmit {
                                if let next = nextField {
                                    focusedField.wrappedValue = next
                                } else {
                                    focusedField.wrappedValue = nil
                                }
                            }
                    }
                }
                
                Button(action: {
                    showing.wrappedValue.toggle()
                }, label: {
                    Image(systemName: showing.wrappedValue ? "eye.slash" : "eye")
                })
                .padding(.horizontal)
                .foregroundStyle(.secondary)
            } else {
                TextField(placeholder, text: text)
                    .padding()
                    .textContentType(field == .firstName ? .givenName : field == .lastName ? .familyName : .emailAddress)
                    .focused(focusedField, equals: field)
                    .submitLabel(nextField == nil ? .done : .next)
                    .onSubmit {
                        if let next = nextField {
                            focusedField.wrappedValue = next
                        } else {
                            focusedField.wrappedValue = nil
                        }
                    }
            }
        }
        .disabled(viewModel.isLoading)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .stroke(focusedField.wrappedValue == field ? Color.accentColor : Color.secondary, lineWidth: 2)
        }
        .padding(.horizontal)
    }
    
    
}

#Preview {
    ProfileSetup()
        .environmentObject(AuthViewModel())
}
