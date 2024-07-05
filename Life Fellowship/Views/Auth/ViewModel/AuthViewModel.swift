//
//  AuthViewModel.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import Foundation

class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    
    @Published var phoneNumber = ""
    @Published var codeSent = false
    @Published var otpText: String = ""
    @Published var isValid = false
    
    var userSession = UserSession.shared
    
    @Published var userId = ""
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var showProfileSetup = false
    @Published var errorText = ""
    
    @Published var isPasswordShowing = false
    @Published var isConfirmPasswordShowing = false
    
    func validatePhoneNumber() -> String {
        let strippedNumber = stripPhoneNumber()
//        if strippedNumber.count == 10 {
//            isValid = true
//        } else {
//            isValid = false
//        }
        return strippedNumber
    }
    
    func stripPhoneNumber() -> String {
        var strippedPhoneNumber =
        phoneNumber
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        if strippedPhoneNumber.starts(with: "+1") {
            strippedPhoneNumber.removeFirst(2)
        } else if phoneNumber.starts(with: "1") {
            strippedPhoneNumber.removeFirst(1)
        }
        
        return strippedPhoneNumber
    }
    
    func sendPhoneCode() async {
        let validNumber = validatePhoneNumber()
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            print("phone \(validNumber)")
            let phoneNumber = "+1" + validNumber
            print(phoneNumber)
            let userId = try await userSession.getUserId(phone: phoneNumber)
            // Ensure state updates are performed on the main thread
            DispatchQueue.main.async {
                self.userId = userId
                self.isLoading = false
            }
        } catch {
            print("Error: \(error)")
            // Handle the error appropriately, possibly updating the state
            DispatchQueue.main.async {
                self.errorText = "\(error)"
                self.isLoading = false
            }
        }
    }
    
    func verifyCode() async {
        do {
            try await userSession.loginWithPhone(userId: userId, code: otpText)
        } catch {
            let errorMessage = "\(error)"
            print("\(error)")
            DispatchQueue.main.async {
                if errorMessage.contains("Invalid token") {
                    self.errorText = "The code you entered is incorrect. Please try again."
                } else if errorMessage.contains("Document with the requested ID could not be found") {
                    self.errorText = "" // Clear any previous error
                    self.showProfileSetup = true // Flag to navigate to ProfileSetup view
                } else {
                    self.errorText = "An unexpected error occurred. Please try again."
                }
            }
        }
    }
    
    func endingFourNumbers() -> String {
        return String(phoneNumber.suffix(4))
    }
    
    func createUserProfile() async {
        do {
            try await userSession.updateNewPhoneUser(firstName: firstName, lastName: lastName, email: email, password: password)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                print("Error: \(error)")
                self.errorText = "\(error)"
            }
        }
    }
    
    func login() async {
        do {
            try await userSession.loginUserWithEmail(email: email, password: password)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            print("Login failed: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func register() async {
        do {
            try await userSession.registerUserWithEmail(firstName: firstName, lastName: lastName, role: "user", email: email, password: password)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            print("Login failed: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
