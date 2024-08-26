//
//  HomeView.swift
//  CPS Campus (macOS)
//
//  5/29/2021
//  Designed by Rahim Malik in California.
//

import SwiftUI
import Foundation
import GoogleSignIn
import FirebaseAuth

struct HomeViewmacOS: View {
    
    //MARK: Authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @State var selection: String? = nil
    @State var showConfigure = false
    @State var showMap = false
    @State var showCredits = false
    @FocusState private var pointsFieldFocused: Bool
    
    let columns2 = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let columns3 = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    //MARK: Club and Sport Data
    @Binding var clubMeetings: [ClubMeeting]
    @Binding var clubs: [Club]
    
    @Binding var sportGames: [SportGame]
    @Binding var sports: [Sport]
    
    @State var rhfCells = [RHFCell]()
    
    //MARK: Settings
    @AppStorage("ForYouPage", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var arrangement: [ForYouItem] = defaultForYouPage
    @AppStorage("QuickLinks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var quickLinks: [QuickLink] = defaultQuickLinks
    
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("NotificationSettings", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var notificationSettings: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    
    @AppStorage("RHFID", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var rhfID = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                NowView().fixedSize(horizontal: false, vertical: true)
                ForEach(arrangement, id: \.self) { item in
                    if item.id == "Map" && item.visible {
                        Button {
                            if colorScheme == .dark {
                                if let url = Bundle.main.url(forResource: "Map (Dark)", withExtension: "pdf") {
                                    let panel = NSSavePanel()
                                    panel.nameFieldStringValue = "Campus Map (Dark).pdf"
                                    panel.allowedContentTypes = [.pdf]
                                    
                                    panel.begin { response in
                                        if response == .OK, let saveURL = panel.url {
                                            do {
                                                try FileManager.default.copyItem(at: url, to: saveURL)
                                            } catch {
                                                consoleLogger.error("pdf save error > \(error, privacy: .public)")
                                            }
                                        }
                                    }
                                }
                            } else {
                                if let url = Bundle.main.url(forResource: "Map (Light)", withExtension: "pdf") {
                                    let panel = NSSavePanel()
                                    panel.nameFieldStringValue = "Campus Map (Light).pdf"
                                    panel.allowedContentTypes = [.pdf]
                                    
                                    panel.begin { response in
                                        if response == .OK, let saveURL = panel.url {
                                            do {
                                                try FileManager.default.copyItem(at: url, to: saveURL)
                                            } catch {
                                                consoleLogger.error("pdf save error > \(error, privacy: .public)")
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image("Map")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                        }
                        .buttonStyle(.plain)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12.5, style: .continuous)
                                .stroke(Color("SystemGray3"), lineWidth: 1)
                        )
                        .padding(1)
                    }
                    else if item.id == "Clubs" && item.visible && (clubMeetings.filter { Calendar.current.isDateInToday($0.startDate) && $0.endDate > Date() }.filter { getClubfromMeeting(clubs: clubs, meetingName: $0.title) != nil || $0.title.lowercased().contains("bake sale") }.isEmpty == false || clubMeetings.filter { Calendar.current.isDateInTomorrow($0.startDate) && $0.endDate > Date() }.filter { $0.title.lowercased().contains("bake sale") }.isEmpty == false) {
                        if authViewModel.state == .signedIn && !(Auth.auth().currentUser?.isAnonymous ?? false) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Your Clubs")
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("SystemContrast"))
                                        .font(.system(size: 20))
                                    Spacer()
                                }.padding(.horizontal, 5)
                                VStack {
                                    ForEach(clubMeetings.filter { Calendar.current.isDateInToday($0.startDate) && $0.endDate > Date() }.filter { getClubfromMeeting(clubs: clubs, meetingName: $0.title) != nil || $0.title.lowercased().contains("bake sale") }, id: \.self) { meeting in
                                        ClubMeetingCellHome(meeting: meeting, club: getClubfromMeeting(clubs: clubs, meetingName: meeting.title) ?? Club(), tomorrow: false)
                                    }
                                    ForEach(clubMeetings.filter { Calendar.current.isDateInTomorrow($0.startDate) && $0.endDate > Date() }.filter { $0.title.lowercased().contains("bake sale") }, id: \.self) { meeting in
                                        ClubMeetingCellHome(meeting: meeting, club: getClubfromMeeting(clubs: clubs, meetingName: meeting.title) ?? Club(), tomorrow: true)
                                    }
                                }
                            }
                        }
                    }
                    else if item.id == "Sports" && item.visible && (sportGames.filter { Calendar.current.isDateInToday($0.startDate) && $0.endDate > Date() }.isEmpty == false || sportGames.filter { Calendar.current.isDateInTomorrow($0.startDate) && $0.endDate > Date() }.isEmpty == false) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Your Sports")
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color("SystemContrast"))
                                Spacer()
                            }.padding(.horizontal, 5)
                            ForEach(sportGames.filter { Calendar.current.isDateInToday($0.startDate) && $0.endDate > Date() }, id: \.self) { game in
                                SportGameCellHome(game: game, sport: getSportfromGame(sports: sports, gameName: game.title) ?? Sport(), tomorrow: false)
                            }
                            ForEach(sportGames.filter { Calendar.current.isDateInTomorrow($0.startDate) && $0.endDate > Date() }, id: \.self) { game in
                                SportGameCellHome(game: game, sport: getSportfromGame(sports: sports, gameName: game.title) ?? Sport(), tomorrow: true)
                            }
                        }
                    }
                    else if item.id == "RHF" && item.visible {
                        HStack {
                            Text("Your RHF")
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                                .foregroundStyle(Color("SystemContrast"))
                            Spacer()
                        }.padding(.horizontal, 5)
                        LazyVGrid(columns: columns2) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("ID")
                                        .fontWeight(.semibold)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(Color("SystemContrast2"))
                                    TextField("Input ID", text: $rhfID)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(Color("AccentColor"))
                                        .textFieldStyle(.plain)
                                        .frame(width: 100)
                                }.frame(height: 50)
                                Spacer()
                            }.borderedCellStyle()
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Points")
                                        .fontWeight(.semibold)
                                        .font(.system(.body, design: .rounded))
                                        .textCase(.uppercase)
                                        .foregroundStyle(Color("SystemContrast2"))
                                    if let cell = rhfCells.first(where: {$0.id ?? "0" == rhfID}) {
                                        if let points = cell.points {
                                            Text(points)
                                                .font(.system(size: 20, weight: .semibold))
                                        } else {
                                            Text("---")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundStyle(Color("SystemGray2"))
                                        }
                                    } else {
                                        Text("---")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundStyle(Color("SystemGray2"))
                                    }
                                }.frame(height: 50)
                                Spacer()
                            }.borderedCellStyle()
                        }
                        Button(action: {
                            RHFView(rhfCells: $rhfCells).openInWindow(title: "RHF", isClear: false, sender: self)
                        }, label: {
                            HStack {
                                Spacer()
                                Text("See Upcoming Drop-ins")
                                    .fontWeight(.medium)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color("AccentColor"))
                                Spacer()
                            }.borderedCellStyle()
                        }).buttonStyle(.plain)
                            .padding(.top, -7.5)
                    }
                    else if item.id == "Links" && item.visible {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Your Links")
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color("SystemContrast"))
                                Spacer()
                            }.padding(.horizontal, 5)
                            LazyVGrid(columns: columns3) {
                                ForEach(quickLinks.filter { $0.visible }, id: \.self) { quickLink in
                                    Button(action: {
                                        openURL(URL(string: quickLink.id)!)
                                    }, label: {
                                        HStack {
                                            Image(systemName: quickLink.icon)
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color("AccentColor"))
                                                .frame(width: 40, height: 20)
                                            Text(quickLink.name)
                                                .fontWeight(.semibold)
                                                .font(.system(size: 15))
                                                .foregroundStyle(Color("SystemContrast"))
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(2)
                                                .lineSpacing(2)
                                            Spacer()
                                        }.borderedCellStyle()
                                    }).buttonStyle(.plain)
                                        .contextMenu {
                                            Button {
                                                let pasteboard = NSPasteboard.general
                                                pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
                                                pasteboard.setString(quickLink.id, forType: NSPasteboard.PasteboardType.string)
                                            } label: {
                                                Text("Copy Link")
                                            }
                                            Button {
                                                openURL(URL(string: quickLink.id)!)
                                            } label: {
                                                Text("Open Link")
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                VStack(spacing: 5) {
                    Text("Designed by Rahim Malik in California").font(.system(size: 13))
                    HStack(spacing: 0) {
                        Text("With the iTeam • ").font(.system(size: 13))
                        Button {
                            showCredits = true
                        } label: {
                            Text("Acknowledgements").font(.system(size: 13)).foregroundStyle(Color("AccentColor"))
                        }.buttonStyle(.plain)
                            .popover(isPresented: $showCredits) {
                                AcknowledgementsView()
                            }
                    }
                }.padding()
            }
            .padding()
            .navigationTitle("For You")
            .toolbar {
                ToolbarItem(id: "Edit", placement: .primaryAction, showsByDefault: true) {
                    Button(action: {
                        showConfigure = true
                    }, label: {
                        Text("Edit").foregroundStyle(Color("SystemToolbar"))
                    })
                    .popover(isPresented: $showConfigure) {
                        HomeViewConfigure()
                    }
                }
                ToolbarItem(id: "SignedIn", placement: .primaryAction, showsByDefault: true) {
                    Button(action: {
                        openURL(URL(string: "cpscampus://settings/campusID")!)
                    }, label: {
                        if authViewModel.state == .signedIn {
                            Text("Signed In").foregroundStyle(Color("SystemToolbar"))
                        } else {
                            Text("Sign In").foregroundStyle(Color("AccentColor"))
                        }
                    })
                }
            }
        }
        .background(Color("SystemWindow"))
        .onAppear {
            if (arrangement.first(where: {$0.id == "RHF" && $0.visible == true}) != nil) {
                URLSession.shared.dataTask(with: rhfSpreadsheetURL) { data,response,error in
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
                                DispatchQueue.main.async {
                                    do {
                                        let decoder = JSONDecoder()
                                        let decodedLists = try decoder.decode(FailableCodableArray<RHFCell>.self, from: data)
                                        rhfCells = decodedLists.elements
                                    } catch {
                                        databaseLogger.error("rhf decode error > \(error, privacy: .public)")
                                    }
                                }
                            }
                            guard error == nil else {
                                databaseLogger.error("rhf access error > \(error, privacy: .public)")
                                return
                            }
                        }
                    }
                }.resume()
            }
        }
        .onChange(of: arrangement) { _ in
            if (arrangement.first(where: {$0.id == "RHF" && $0.visible == true}) != nil) {
                URLSession.shared.dataTask(with: rhfSpreadsheetURL) { data,response,error in
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
                                DispatchQueue.main.async {
                                    do {
                                        let decoder = JSONDecoder()
                                        let decodedLists = try decoder.decode(FailableCodableArray<RHFCell>.self, from: data)
                                        rhfCells = decodedLists.elements
                                    } catch {
                                        databaseLogger.error("rhf decode error > \(error, privacy: .public)")
                                    }
                                }
                            }
                            guard error == nil else {
                                databaseLogger.error("rhf access error > \(error, privacy: .public)")
                                return
                            }
                        }
                    }
                }.resume()
            }
        }
    }
}
