//
//  HomeView.swift
//  CPS Campus (iOS)
//
//  5/29/2021
//  Designed by Rahim Malik in California.
//

import SwiftUI
import Foundation
import WidgetKit
import GoogleSignIn
import FirebaseAuth

struct HomeView: View {
    
    //MARK: Authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @State var selection: String? = nil
    @State var showConfigure = false
    @State var showMap = false
    @State var showCredits = false
    @FocusState private var pointsFieldFocused: Bool
    
    let columns2 = [
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
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    VStack(spacing: 15) {
                        //this zstack usage is a hack to avoid the image overlapping the scrollview
                        Spacer().frame(height: 25)
                            .padding(.top, 5)
                            .padding(.bottom)
                        NowView()
                        ForEach(arrangement, id: \.self) { item in
                            if item.id == "Map" && item.visible {
                                Button {
                                    showMap = true
                                } label: {
                                    Image("Map")
                                        .resizable()
                                        .scaleEffect(1.4)
                                        .scaledToFill()
                                        .clipped()
                                        .frame(height: 190)
                                        .clipped()
                                }
                                .sheet(isPresented: $showMap) {
                                    if colorScheme == .dark {
                                        if let url = Bundle.main.url(forResource: "Map (Dark)", withExtension: "pdf") {
                                            PreviewController(url: url).ignoresSafeArea(.all)
                                        }
                                    } else {
                                        if let url = Bundle.main.url(forResource: "Map (Light)", withExtension: "pdf") {
                                            PreviewController(url: url).ignoresSafeArea(.all)
                                        }
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .stroke(Color(.systemGray6), lineWidth: 2)
                                )
                                .padding(2)
                            }
                            else if item.id == "Clubs" && item.visible && (clubMeetings.filter { Calendar.current.isDateInToday($0.startDate) && $0.endDate > Date() }.filter { getClubfromMeeting(clubs: clubs, meetingName: $0.title) != nil || $0.title.lowercased().contains("bake sale") }.isEmpty == false || clubMeetings.filter { Calendar.current.isDateInTomorrow($0.startDate) && $0.endDate > Date() }.filter { $0.title.lowercased().contains("bake sale") }.isEmpty == false) {
                                if authViewModel.state == .signedIn && !(Auth.auth().currentUser?.isAnonymous ?? false) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("Your Clubs")
                                                .fontWeight(.bold)
                                                .font(.system(size: 24))
                                                .foregroundStyle(Color("SystemContrast"))
                                            Spacer()
                                        }.padding(.horizontal, 5)
                                        VStack {
                                            ForEach(clubMeetings.filter { Calendar.current.isDateInToday($0.startDate) && $0.endDate > Date() }.filter { getClubfromMeeting(clubs: clubs, meetingName: $0.title) != nil || $0.title.lowercased().contains("bake sale") }, id: \.self) { meeting in
                                                NavigationLink(
                                                    destination: ClubsView(meetings: $clubMeetings, clubs: clubs, selection: getClubfromMeeting(clubs: clubs, meetingName: meeting.title)?.name ?? ""),
                                                    label: {
                                                        ClubMeetingCellHome(meeting: meeting, club: getClubfromMeeting(clubs: clubs, meetingName: meeting.title) ?? Club(), tomorrow: false)
                                                    }).buttonStyle(ScaleButtonStyle())
                                            }
                                            ForEach(clubMeetings.filter { Calendar.current.isDateInTomorrow($0.startDate) && $0.endDate > Date() }.filter { $0.title.lowercased().contains("bake sale") }, id: \.self) { meeting in
                                                NavigationLink(
                                                    destination: ClubsView(meetings: $clubMeetings, clubs: clubs, selection: getClubfromMeeting(clubs: clubs, meetingName: meeting.title)?.name ?? ""),
                                                    label: {
                                                        ClubMeetingCellHome(meeting: meeting, club: getClubfromMeeting(clubs: clubs, meetingName: meeting.title) ?? Club(), tomorrow: true)
                                                    }).buttonStyle(ScaleButtonStyle())
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
                                            .font(.system(size: 24))
                                            .foregroundStyle(Color("SystemContrast"))
                                        Spacer()
                                    }.padding(.horizontal, 5)
                                    VStack {
                                        ForEach(sportGames.filter { Calendar.current.isDateInToday($0.startDate) && $0.endDate > Date() }, id: \.self) { game in
                                            NavigationLink(
                                                destination: SportsView(games: $sportGames, sports: sports, selection: getSportfromGame(sports: sports, gameName: game.title)?.name ?? ""),
                                                label: {
                                                    SportGameCellHome(game: game, sport: getSportfromGame(sports: sports, gameName: game.title) ?? Sport(), tomorrow: false)
                                                }).buttonStyle(ScaleButtonStyle())
                                        }
                                        ForEach(sportGames.filter { Calendar.current.isDateInTomorrow($0.startDate) && $0.endDate > Date() }, id: \.self) { game in
                                            NavigationLink(
                                                destination: SportsView(games: $sportGames, sports: sports, selection: getSportfromGame(sports: sports, gameName: game.title)?.name ?? ""),
                                                label: {
                                                    SportGameCellHome(game: game, sport: getSportfromGame(sports: sports, gameName: game.title) ?? Sport(), tomorrow: true)
                                                }).buttonStyle(ScaleButtonStyle())
                                        }
                                    }
                                }
                            }
                            else if item.id == "RHF" && item.visible {
                                HStack {
                                    Text("Your RHF")
                                        .fontWeight(.bold)
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color("SystemContrast"))
                                    Spacer()
                                }.padding(.horizontal, 5)
                                LazyVGrid(columns: columns2) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("ID")
                                                .textCase(.uppercase)
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundStyle(Color("SystemContrast2"))
                                            TextField("Input ID", text: $rhfID)
                                                .font(.system(size: 22, weight: .semibold))
                                                .foregroundStyle(Color("AccentColor"))
                                                .textFieldStyle(.plain)
                                                .focused($pointsFieldFocused)
                                                .keyboardType(.numberPad)
                                                .toolbar {
                                                    ToolbarItemGroup(placement: .keyboard) {
                                                        Button(action: {
                                                            pointsFieldFocused = false
                                                        }, label: {
                                                            Text("Done").bold()
                                                        })
                                                    }
                                                }
                                                .frame(width: 100)
                                        }
                                        Spacer()
                                    }.padding([.leading,.vertical])
                                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Points")
                                                .textCase(.uppercase)
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundStyle(Color("SystemContrast2"))
                                            if let cell = rhfCells.first(where: {$0.id ?? "0" == rhfID}) {
                                                if let points = cell.points {
                                                    Text(points)
                                                        .font(.system(size: 22, weight: .semibold))
                                                        .padding(.vertical, 1)
                                                } else {
                                                    Text("---")
                                                        .font(.system(size: 22, weight: .semibold))
                                                        .padding(.vertical, 1)
                                                        .foregroundStyle(Color(.systemGray2))
                                                }
                                            } else {
                                                Text("---")
                                                    .font(.system(size: 22, weight: .semibold))
                                                    .padding(.vertical, 1)
                                                    .foregroundStyle(Color(.systemGray2))
                                            }
                                        }
                                        Spacer()
                                    }.padding([.leading,.vertical])
                                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                                }
                                NavigationLink(destination: RHFView(rhfCells: $rhfCells)) {
                                    HStack {
                                        Spacer()
                                        Text("See Upcoming Drop-ins")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color("AccentColor"))
                                        Spacer()
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                                }
                                .padding(.top, -7.5)
                            }
                            else if item.id == "Links" && item.visible {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Your Links")
                                            .fontWeight(.bold)
                                            .font(.system(size: 24))
                                            .foregroundStyle(Color("SystemContrast"))
                                        Spacer()
                                    }.padding(.horizontal, 5)
                                    LazyVGrid(columns: columns2) {
                                        ForEach(quickLinks.filter { $0.visible }, id: \.self) { quickLink in
                                            Button(action: {
                                                openURL(URL(string: quickLink.id)!)
                                            }, label: {
                                                HStack {
                                                    Image(systemName: quickLink.icon)
                                                        .font(.system(size: 22))
                                                        .foregroundStyle(Color("AccentColor"))
                                                        .frame(width: 40, height: 35)
                                                    Text(quickLink.name)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(Color("SystemContrast"))
                                                        .multilineTextAlignment(.leading)
                                                        .lineLimit(2)
                                                        .lineSpacing(2)
                                                        .dynamicTypeSize(.small ... .large)
                                                    Spacer()
                                                }
                                                .frame(height: 50)
                                                .padding()
                                                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                                            })
                                            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15, style: .continuous))
                                            .contextMenu {
                                                Button {
                                                    let pasteboard = UIPasteboard.general
                                                    pasteboard.string = quickLink.id
                                                } label: {
                                                    Label("Copy Link", systemImage: "doc.on.doc")
                                                }
                                                Button {
                                                    openURL(URL(string: quickLink.id)!)
                                                } label: {
                                                    Label("Open Link", systemImage: "arrow.up.forward.app")
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
                                    Text("Acknowledgements").font(.system(size: 13))
                                }
                            }
                        }.padding()
                    }
                    .padding()
                    VStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Spacer().frame(width: 15)
                                if let anonymous = Auth.auth().currentUser?.isAnonymous {
                                    if anonymous {
                                        Button(action: {
                                            openURL(URL(string: "cpscampus://settings/campusID")!)
                                        }, label: {
                                            TopCell(name: "Directory", symbol: "person.2.fill")
                                        })
                                        Button(action: {
                                            openURL(URL(string: "cpscampus://settings/campusID")!)
                                        }, label: {
                                            TopCell(name: "Clubs", symbol: "theatermask.and.paintbrush.fill")
                                        })
                                    } else {
                                        NavigationLink(
                                            destination: DirectoryView(clubs: clubs), tag: "Directory", selection: $selection,
                                            label: {
                                                TopCell(name: "Directory", symbol: "person.2.fill")
                                            })
                                        NavigationLink(
                                            destination: ClubsView(meetings: $clubMeetings, clubs: clubs), tag: "Clubs", selection: $selection,
                                            label: {
                                                TopCell(name: "Clubs", symbol: "theatermask.and.paintbrush.fill")
                                            })
                                    }
                                } else {
                                    TopCell(name: "Directory", symbol: "person.2")
                                    TopCell(name: "Clubs", symbol: "theatermask.and.paintbrush.fill")
                                }
                                NavigationLink(
                                    destination: SportsView(games: $sportGames, sports: sports), tag: "Sports", selection: $selection,
                                    label: {
                                        TopCell(name: "Sports", symbol: "sportscourt.fill")
                                    })
                                NavigationLink(
                                    destination: RHFView(rhfCells: $rhfCells), tag: "RHF", selection: $selection,
                                    label: {
                                        TopCell(name: "RHF", symbol: "figure.badminton")
                                    })
                                Spacer().frame(width: 15)
                            }
                        }
                        .padding(.top, 5)
                        Spacer()
                    }
                }
            }
            .navigationTitle("For You")
            .background(idiom == .pad ? Color("MultitaskingBackground") : .clear)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showConfigure = true
                    }, label: {
                        Text("Edit")
                            .fontWeight(.medium)
                    })
                }
            }
            .onDisappear {
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onOpenURL { url in
                if url.absoluteString.contains("clubs") {
                    selection = "Clubs"
                } else if url.absoluteString.contains("sports") {
                    selection = "Sports"
                }
            }
            .sheet(isPresented: $showConfigure) {
                HomeViewConfigure()
            }
            .sheet(isPresented: $showCredits) {
                AcknowledgementsView()
            }
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
        .navigationViewStyle(.stack)
    }
}

struct HomeViewiPadOS: View {
    
    //MARK: Authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
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
    @State var settingsPresented = false
    
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("NotificationSettings", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var notificationSettings: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    
    @AppStorage("RHFID", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var rhfID = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                NowView()
                ForEach(arrangement, id: \.self) { item in
                    if item.id == "Map" && item.visible {
                        Button {
                            showMap = true
                        } label: {
                            Image("Map")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                        }.sheet(isPresented: $showMap) {
                            if colorScheme == .dark {
                                if let url = Bundle.main.url(forResource: "Map (Dark)", withExtension: "pdf") {
                                    PreviewController(url: url).ignoresSafeArea(.all)
                                }
                            } else {
                                if let url = Bundle.main.url(forResource: "Map (Light)", withExtension: "pdf") {
                                    PreviewController(url: url).ignoresSafeArea(.all)
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(Color(.systemGray6), lineWidth: 2)
                        )
                        .padding(2)
                    }
                    else if item.id == "Clubs" && item.visible && (clubMeetings.filter { Calendar.current.isDateInToday($0.startDate) && $0.endDate > Date() }.filter { getClubfromMeeting(clubs: clubs, meetingName: $0.title) != nil || $0.title.lowercased().contains("bake sale") }.isEmpty == false || clubMeetings.filter { Calendar.current.isDateInTomorrow($0.startDate) && $0.endDate > Date() }.filter { $0.title.lowercased().contains("bake sale") }.isEmpty == false) {
                        if authViewModel.state == .signedIn && !(Auth.auth().currentUser?.isAnonymous ?? false) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Your Clubs")
                                        .fontWeight(.bold)
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color("SystemContrast"))
                                    Spacer()
                                }.padding(.horizontal, 5)
                                VStack {
                                    ForEach(clubMeetings.filter { Calendar.current.isDateInToday($0.startDate) && $0.endDate > Date() }.filter { getClubfromMeeting(clubs: clubs, meetingName: $0.title) != nil || $0.title.lowercased().contains("bake sale") }, id: \.self) { meeting in
                                        Button(action: {
                                            openURL(URL(string: "cpscampus://clubs/\(getClubfromMeeting(clubs: clubs, meetingName: meeting.title)?.name.replacingOccurrences(of: " ", with: "+") ?? "")")!)
                                        }, label: {
                                            ClubMeetingCellHome(meeting: meeting, club: getClubfromMeeting(clubs: clubs, meetingName: meeting.title) ?? Club(), tomorrow: false)
                                        }).buttonStyle(ScaleButtonStyle())
                                    }
                                    ForEach(clubMeetings.filter { Calendar.current.isDateInTomorrow($0.startDate) && $0.endDate > Date() }.filter { $0.title.lowercased().contains("bake sale") }, id: \.self) { meeting in
                                        Button(action: {
                                            openURL(URL(string: "cpscampus://clubs/\(getClubfromMeeting(clubs: clubs, meetingName: meeting.title)?.name.replacingOccurrences(of: " ", with: "+") ?? "")")!)
                                        }, label: {
                                            ClubMeetingCellHome(meeting: meeting, club: getClubfromMeeting(clubs: clubs, meetingName: meeting.title) ?? Club(), tomorrow: true)
                                        }).buttonStyle(ScaleButtonStyle())
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
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color("SystemContrast"))
                                Spacer()
                            }.padding(.horizontal, 5)
                            VStack {
                                ForEach(sportGames.filter { Calendar.current.isDateInToday($0.startDate) && $0.endDate > Date() }, id: \.self) { game in
                                    Button(action: {
                                        openURL(URL(string: "cpscampus://sports/\(getSportfromGame(sports: sports, gameName: game.title)?.name.replacingOccurrences(of: " ", with: "+") ?? "")")!)
                                    }, label: {
                                        SportGameCellHome(game: game, sport: getSportfromGame(sports: sports, gameName: game.title) ?? Sport(), tomorrow: false)
                                    }).buttonStyle(ScaleButtonStyle())
                                }
                                ForEach(sportGames.filter { Calendar.current.isDateInTomorrow($0.startDate) && $0.endDate > Date() }, id: \.self) { game in
                                    Button(action: {
                                        openURL(URL(string: "cpscampus://sports/\(getSportfromGame(sports: sports, gameName: game.title)?.name.replacingOccurrences(of: " ", with: "+") ?? "")")!)
                                    }, label: {
                                        SportGameCellHome(game: game, sport: getSportfromGame(sports: sports, gameName: game.title) ?? Sport(), tomorrow: true)
                                    }).buttonStyle(ScaleButtonStyle())
                                }
                            }
                        }
                    }
                    else if item.id == "RHF" && item.visible {
                        HStack {
                            Text("Your RHF")
                                .fontWeight(.bold)
                                .font(.system(size: 24))
                                .foregroundStyle(Color("SystemContrast"))
                            Spacer()
                        }.padding(.horizontal, 5)
                        LazyVGrid(columns: columns2) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("ID")
                                        .textCase(.uppercase)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color("SystemContrast2"))
                                    TextField("Input ID", text: $rhfID)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(Color("AccentColor"))
                                        .textFieldStyle(.plain)
                                        .focused($pointsFieldFocused)
                                        .keyboardType(.numberPad)
                                        .toolbar {
                                            ToolbarItemGroup(placement: .keyboard) {
                                                Button(action: {
                                                    pointsFieldFocused = false
                                                }, label: {
                                                    Text("Done").bold()
                                                })
                                            }
                                        }
                                        .frame(width: 100)
                                }
                                Spacer()
                            }.padding([.leading,.vertical])
                                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Points")
                                        .textCase(.uppercase)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color("SystemContrast2"))
                                    if let cell = rhfCells.first(where: {$0.id ?? "0" == rhfID}) {
                                        if let points = cell.points {
                                            Text(points)
                                                .font(.system(size: 22, weight: .semibold))
                                                .padding(.vertical, 1)
                                        } else {
                                            Text("---")
                                                .font(.system(size: 22, weight: .semibold))
                                                .padding(.vertical, 1)
                                                .foregroundStyle(Color(.systemGray2))
                                        }
                                    } else {
                                        Text("---")
                                            .font(.system(size: 22, weight: .semibold))
                                            .padding(.vertical, 1)
                                            .foregroundStyle(Color(.systemGray2))
                                    }
                                }
                                Spacer()
                            }.padding([.leading,.vertical])
                                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                        }
                        NavigationLink(destination: RHFView(rhfCells: $rhfCells)) {
                            HStack {
                                Spacer()
                                Text("See Upcoming Drop-ins")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color("AccentColor"))
                                Spacer()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                        }
                        .padding(.top, -7.5)
                    }
                    else if item.id == "Links" && item.visible {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Your Links")
                                    .fontWeight(.bold)
                                    .font(.system(size: 24))
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
                                                .font(.system(size: 22))
                                                .foregroundStyle(Color("AccentColor"))
                                                .frame(width: 40, height: 35)
                                            Text(quickLink.name)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color("SystemContrast"))
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(2)
                                                .lineSpacing(2)
                                                .dynamicTypeSize(.small ... .large)
                                            Spacer()
                                        }.padding()
                                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                                    })
                                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15, style: .continuous))
                                    .contextMenu {
                                        Button {
                                            let pasteboard = UIPasteboard.general
                                            pasteboard.string = quickLink.id
                                        } label: {
                                            Label("Copy Link", systemImage: "doc.on.doc")
                                        }
                                        Button {
                                            openURL(URL(string: quickLink.id)!)
                                        } label: {
                                            Label("Open Link", systemImage: "arrow.up.forward.app")
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
                            Text("Acknowledgements").font(.system(size: 13))
                        }
                    }
                }.padding()
            }
            .padding()
        }
        .navigationTitle("For You")
        .background(Color("MultitaskingBackground"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showConfigure = true
                }, label: {
                    Text("Edit")
                        .fontWeight(.medium)
                })
                .popover(isPresented: $showConfigure, arrowEdge: .top) {
                    HomeViewConfigure().frame(width: 400, height: 500)
                }
            }
            ToolbarItem(id: "SignedIn", placement: .primaryAction, showsByDefault: true) {
                Button(action: {
                    settingsPresented = true
                }, label: {
                    if authViewModel.state == .signedIn {
                        Text("Signed In").fontWeight(.medium)
                    } else {
                        Text("Sign In").fontWeight(.medium)
                    }
                })
            }
        }
        .sheet(isPresented: $settingsPresented, content: {
            SettingsPane(clubs: clubs, clubMeetings: clubMeetings, sports: sports, sportGames: sportGames)
        })
        .onDisappear {
            WidgetCenter.shared.reloadAllTimelines()
        }
        .sheet(isPresented: $showCredits) {
            AcknowledgementsView()
        }
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
