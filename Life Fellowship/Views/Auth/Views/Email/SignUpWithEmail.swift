//
//  SignUpWithEmail.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import SwiftUI

struct SignUpWithEmail: View {
    @EnvironmentObject var viewModel: AuthViewModel
    enum FocusedField {
        case firstName, lastName, email, password, confirmPassword
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
                
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Use Phone")
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
                Text("Sign up with email 📧")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Create an account by entering your email and confirming your password.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            VStack(alignment: .leading, spacing: 16) {
                TextField("First Name", text: $viewModel.firstName)
                    .padding()
                    .textContentType(.givenName)
                    .focused($focusedField, equals: .firstName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .lastName
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(focusedField == .firstName ? Color.accentColor : Color.secondary, lineWidth: 2)
                    }
                TextField("Last Name", text: $viewModel.lastName)
                    .padding()
                    .textContentType(.familyName)
                    .focused($focusedField, equals: .lastName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .email
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(focusedField == .lastName ? Color.accentColor : Color.secondary, lineWidth: 2)
                    }
                
                TextField("Email", text: $viewModel.email)
                    .padding()
                    .textContentType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(focusedField == .email ? Color.accentColor : Color.secondary, lineWidth: 2)
                    }
                
                
                HStack {
                    if viewModel.isPasswordShowing {
                        TextField("Password", text: $viewModel.password)
                            .padding()
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .confirmPassword
                            }
                    } else {
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .confirmPassword
                            }
                    }
                    
                    Button(action: {
                        viewModel.isPasswordShowing.toggle()
                    }, label: {
                        Image(systemName: viewModel.isPasswordShowing ? "eye.slash" : "eye")
                    })
                    .padding(.horizontal)
                    .foregroundStyle(.secondary)
                }
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(focusedField == .password ? Color.accentColor : Color.secondary, lineWidth: 2)
                }
                
                
                HStack {
                    if viewModel.isConfirmPasswordShowing {
                        TextField("Confirm Password", text: $viewModel.confirmPassword)
                            .padding()
                            .textContentType(.password)
                            .focused($focusedField, equals: .confirmPassword)
                            .submitLabel(.go)
                            .onSubmit {
                                focusedField = nil
                            }
                    } else {
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            .padding()
                            .textContentType(.password)
                            .focused($focusedField, equals: .confirmPassword)
                            .submitLabel(.go)
                            .onSubmit {
                                focusedField = nil
                            }
                    }
                    
                    Button(action: {
                        viewModel.isConfirmPasswordShowing.toggle()
                    }, label: {
                        Image(systemName: viewModel.isConfirmPasswordShowing ? "eye.slash" : "eye")
                    })
                    .padding(.horizontal)
                    .foregroundStyle(.secondary)
                }
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(focusedField == .password ? Color.accentColor : Color.secondary, lineWidth: 2)
                }
            }
            .padding()
            
            
            Spacer()
            
            Button(action: {
                viewModel.isLoading = true
                Task {
                    do {
                        await viewModel.register()
                    }
                }
            }, label: {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Text("Sign up")
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
            .disabled(viewModel.firstName == "" || viewModel.lastName == "" || viewModel.email == "" || viewModel.password == "" || viewModel.confirmPassword == "" || viewModel.isLoading)
            .padding()
        }
        .navigationBarBackButtonHidden()
    }
    
}

#Preview {
    SignUpWithEmail().environmentObject(AuthViewModel())
}
