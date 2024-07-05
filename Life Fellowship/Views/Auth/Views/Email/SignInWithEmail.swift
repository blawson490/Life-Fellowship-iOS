//
//  SignInWithEmail.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import SwiftUI

struct SignInWithEmail: View {
    @EnvironmentObject var viewModel: AuthViewModel
    enum FocusedField {
        case email, password
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
                Text("Sign in with email 📧")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter your email and password to sign into your account.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            VStack(alignment: .leading, spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .padding()
                    .textContentType(.password)
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
                            .submitLabel(.go)
                            .onSubmit {
                                focusedField = nil
                            }
                    } else {
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                focusedField = nil
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
            }
            .padding()
            HStack {
                Spacer()
                Text("Don't have an account?")
                NavigationLink(destination: SignUpWithEmail().environmentObject(viewModel), label: {
                    Text("Sign up")
                })
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                viewModel.isLoading = true
                Task {
                    do {
                        await viewModel.login()
                    }
                }
            }, label: {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Text("Sign in")
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
            .disabled(viewModel.email == "" || viewModel.password == "" || viewModel.isLoading)
            .padding()
        }
        .navigationBarBackButtonHidden()
    }
    
}


#Preview {
    SignInWithEmail()
        .environmentObject(AuthViewModel())
}
