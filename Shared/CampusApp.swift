//
//  CampusApp.swift
//  CPS Campus (Shared)
//
//  6/13/2021
//  Designed by Rahim Malik in California.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseDatabase
import GoogleSignIn

@main
struct CampusApp: App {
    
    @Environment(\.openURL) var openURL
    @StateObject var authViewModel = AuthenticationViewModel()
    @State var expirationDate = Date()
    
    init() {
        ResetStores()
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = false
#if canImport(UIKit)
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color("AccentColor"))
#endif
    }
    
    var body: some Scene {
#if os(iOS)
        WindowGroup {
            if expirationDate > createAllDayDate(weekday: 1, weekOfYear: 23, year: 2024) {
                Text("This version of Campus is no longer supported. Install the latest version available on iOS 16.0+ through the [App Store](https://apps.apple.com/us/app/cps-campus/id1526211585)")
                    .multilineTextAlignment(.center)
                    .padding(20)
            } else {
                iOSArchView()
                    .environmentObject(authViewModel)
            }
        }
#elseif os(macOS)
        WindowGroup {
            if expirationDate > createAllDayDate(weekday: 1, weekOfYear: 23, year: 2024) {
                Text("This version of Campus is no longer supported. Install the latest version available on macOS 13.0+ through the [App Store](https://apps.apple.com/us/app/cps-campus/id1526211585)")
                    .multilineTextAlignment(.center)
                    .padding(20)
            } else {
                macOSView()
                    .handlesExternalEvents(preferring: Set(arrayLiteral: "{path of URL?}"), allowing: Set(arrayLiteral: "*"))
                    .environmentObject(authViewModel)
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
            }
        }
        .commands {
            CommandGroup(replacing: .systemServices) {
            }
            CommandGroup(replacing: .appSettings) {
                Button(action: {
                    openURL(URL(string: "cpscampus://settings")!)
                }, label: {
                    Text("Preferences...")
                })
                .keyboardShortcut(KeyEquivalent(","), modifiers: .command)
            }
            CommandGroup(replacing: .help) {
                Button(action: {
                    openURL(URL(string: "https://forms.gle/VSV2u4X2LoTBd49U6")!)
                }, label: {
                    Text("Feedback")
                })
            }
        }
#endif
    }
}

#if os(iOS)
struct iOSArchView: View {
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    var body: some View {
        if vSizeClass == .regular && hSizeClass == .regular {
            if #available(iOS 16.0, *) {
                iPadOSView16()
            } else {
                iPadOSView()
            }
        } else {
            iOSView()
        }
    }
    
}
#endif

#if os(macOS)
extension View {
    
    @discardableResult
    func openInWindow(title: String, isClear: Bool, sender: Any?) -> NSWindow {
        let controller = NSHostingController(rootView: self)
        let window = NSWindow(contentViewController: controller)
        window.contentViewController = controller
        window.title = title
        window.titleVisibility = .hidden
        window.titlebarSeparatorStyle = .line
        window.makeKeyAndOrderFront(sender)
        return window
    }
}
#endif
