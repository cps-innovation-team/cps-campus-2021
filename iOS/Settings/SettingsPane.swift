//
//  SettingsPane.swift
//  CPS Campus (iPadOS)
//
//  9/11/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import GoogleSignIn

struct SettingsPane: View {
    
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @State var campusID: User? = nil
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    
    let clubs: [Club]
    let clubMeetings: [ClubMeeting]
    let sports: [Sport]
    let sportGames: [SportGame]
    
    @State var selection: String = "campusID"
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Settings", selection: $selection) {
                Text("Campus ID").tag("campusID")
                Text("Notifications").tag("notifications")
                Text("Palettes").tag("palettes")
            }.pickerStyle(.segmented)
                .labelsHidden()
                .padding().padding()
            switch selection {
            case "campusID":
                ProfileView(campusID: $campusID)
            case "notifications":
                NotificationsView()
            case "palettes":
                PaletteView(negativePadding: 0)
            default:
                EmptyView()
            }
        }
        .onOpenURL { url in
            if url.absoluteString.contains("campusID") {
                selection = "campusID"
            } else if url.absoluteString.contains("palettes") {
                selection = "palettes"
            } else if url.absoluteString.contains("notifications") {
                selection = "notifications"
            }
        }
    }
}

