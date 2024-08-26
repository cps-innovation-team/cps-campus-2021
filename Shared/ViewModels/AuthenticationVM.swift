//
//  AuthenticationViewModel.swift
//  CPS Campus (Shared)
//
//  6/7/2022
//  Designed by Rahim Malik in California.
//

import Foundation
import GoogleSignIn
import Firebase
import FirebaseAuth

#if os(iOS)

class AuthenticationViewModel: ObservableObject {
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published var state: SignInState = .signedOut
    
    func signIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let configuration = GIDConfiguration(clientID: clientID)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.configuration = configuration
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] user, error in
                authenticateUser(for: user?.user, with: error)
            }
        }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        if let error = error {
            authLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
            return
        }
        
        if let userWrapped = user {
            let credential = GoogleAuthProvider.credential(withIDToken: userWrapped.idToken!.tokenString, accessToken: userWrapped.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
                if let error = error {
                    authLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
                } else {
                    state = .signedIn
                }
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            state = .signedOut
        } catch {
            authLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
        }
    }
}

#endif

#if os(macOS)

class AuthenticationViewModel: ObservableObject {
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published var state: SignInState = .signedOut
    
    func signIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let configuration = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.configuration = configuration
            GIDSignIn.sharedInstance.signIn(withPresenting: NSApp.windows.first!) { [unowned self] user, error in
                authenticateUser(for: user?.user, with: error)
            }
        }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        if let error = error {
            authLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
            return
        }
        
        if let userWrapped = user {
            let credential = GoogleAuthProvider.credential(withIDToken: userWrapped.idToken!.tokenString, accessToken: userWrapped.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
                if let error = error {
                    authLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
                } else {
                    state = .signedIn
                }
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            state = .signedOut
        } catch {
            authLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
        }
    }
}

#endif
