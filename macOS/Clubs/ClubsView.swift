//
//  ClubsView.swift
//  CPS Campus (macOS)
//
//  6/7/2021
//  Designed by Rahim Malik in California.
//

import SwiftUI
import Foundation
import DynamicColor
import GoogleSignIn

struct ClubsView: View {
    
    //MARK: Authentication and Campus ID
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var campusID: User? = nil
    
    //MARK: Club Data
    @AppStorage("JoinedClubs", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var joinedClubs = [String: Bool]()
    @Binding var meetings: [ClubMeeting]
    let clubs: [Club]
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    
    @State var selection: String? = ""
    @State var search: String = ""
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { mainValue in
                    if search == "" {
                        VStack(spacing: 10) {
                            SectionHeader(name: "Your Clubs")
                                .padding(.leading, 15)
                                .padding(.top, 10)
                                .id("top")
                            ScrollViewReader { scrollView in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 0) {
                                        Spacer()
                                            .frame(width: 15)
                                            .padding(.trailing, 5)
                                        if !joinedClubs.keys.map({$0}).contains(cleanFirebaseKey(input: selection ?? "NilSelection")) && ((getClubfromMeeting(clubs: clubs, meetingName: selection ?? "NilSelection") ?? Club()).leaders?.contains(campusID?.id ?? "NilEmail") ?? false) == false && selection != "" && selection != "Add Club" {
                                            ClubIcon(club: getClubfromMeeting(clubs: clubs, meetingName: selection ?? "NilSelection") ?? Club(), meetings: meetings, selection: $selection, search: $search)
                                                .id(selection)
                                                .padding(.trailing, 5)
                                        }
                                        ForEach(clubs.filter { club in club.leaders?.contains(campusID?.id ?? "NilEmail") ?? false }.sorted { $0.name < $1.name }, id: \.name) { club in
                                            ClubIcon(club: club, meetings: meetings.filter { $0.endDate > Date() && getClubfromMeeting(clubs: clubs, meetingName: $0.title) != nil }.sorted { $0.startDate < $1.startDate }, selection: $selection, search: $search)
                                                .id(club.name)
                                                .padding(.trailing, 5)
                                        }
                                        ForEach(clubs.filter { club in joinedClubs.keys.map({$0}).contains(cleanFirebaseKey(input: club.name)) && (club.leaders?.contains(campusID?.id ?? "NilEmail") ?? false) == false }.sorted { $0.name < $1.name }, id: \.name) { club in
                                            ClubIcon(club: club, meetings: meetings.filter { $0.endDate > Date() && getClubfromMeeting(clubs: clubs, meetingName: $0.title) != nil }.sorted { $0.startDate < $1.startDate }, selection: $selection, search: $search)
                                                .id(club.name)
                                                .padding(.trailing, 5)
                                        }
                                        AddClubButton(selection: $selection)
                                            .padding(.trailing, 5)
                                        Spacer().frame(width: 15)
                                    }
                                }
                                .onChange(of: selection) { _ in
                                    withAnimation {
                                        scrollView.scrollTo(selection, anchor: .center)
                                    }
                                }
                                .onAppear {
                                    withAnimation {
                                        scrollView.scrollTo(selection, anchor: .center)
                                    }
                                }
                                .padding(.top, 5)
                            }
                            if selection == "" {
                                VStack {
                                    if let meetingArray = Optional(meetings.filter({ getClubfromMeeting(clubs: clubs, meetingName: $0.title) != nil || $0.title.lowercased().contains("bake sale") }).filter({ $0.endDate > Date() }).sorted { $0.startDate < $1.startDate }) {
                                        ForEach(meetingArray.indices, id: \.self) { index in
                                            if index == 0 {
                                                HStack { Text(convertDatetoString(date: meetingArray[index].startDate, format: "EEEE, MMMM d")).fontWeight(.medium).font(.system(.body, design: .rounded)).textCase(.uppercase).foregroundStyle(Calendar.current.isDateInToday(meetingArray[index].startDate) == true ? Color("AccentColor") : Color("SystemContrast2"));Spacer() }.padding(.leading, 10)
                                            }
                                            if index != 0 {
                                                if Calendar.current.isDate(meetingArray[index-1].startDate, inSameDayAs: meetingArray[index].startDate) == false {
                                                    Spacer().frame(height: 20)
                                                    HStack { Text(convertDatetoString(date: meetingArray[index].startDate, format: "EEEE, MMMM d")).fontWeight(.medium).font(.system(.body, design: .rounded)).textCase(.uppercase).foregroundStyle(Calendar.current.isDateInToday(meetingArray[index].startDate) == true ? Color("AccentColor") : Color("SystemContrast2"));Spacer() }.padding(.leading, 10)
                                                }
                                            }
                                            ClubMeetingCell(meeting: meetingArray[index], club: getClubfromMeeting(clubs: clubs, meetingName: meetingArray[index].title) ?? Club(), meetings: meetingArray, selection: $selection, campusID: $campusID)
                                        }
                                    }
                                }.padding()
                            } else if selection == "Add Club" {
                                LazyVStack {
                                    Button(action: {
                                        openURL(URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSdPm26IyjuHZSyQ9gtHubMMoKRKAaVfdy70zDK9vrGTPEU6pA/viewform")!)
                                    }, label: {
                                        HStack(spacing: 5) {
                                            Spacer()
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundStyle(Color("AccentColor"))
                                            Text("Create a Club")
                                                .fontWeight(.semibold)
                                                .font(.system(size: 15))
                                                .foregroundStyle(Color("AccentColor"))
                                            Spacer()
                                        }.tintedCellStyle(color: Color("AccentColor"))
                                    }).buttonStyle(.plain)
                                    Spacer().frame(height: 20)
                                    ForEach(clubCategories, id: \.self) { category in
                                        Section(header: SectionHeader(name: category)) {
                                            ForEach(clubs.filter { category.lowercased().contains($0.category) }.sorted { $0.name < $1.name }, id: \.name) { club in
                                                ClubCell(club: club, selection: $selection, search: $search)
                                            }
                                        }
                                        Spacer().frame(height: 20)
                                    }
                                }.padding()
                            } else {
                                ClubPage(club: getClubfromMeeting(clubs: clubs, meetingName: selection ?? "NilSelection") ?? Club(), clubMeetings: meetings, selection: $selection)
                                    .id(getClubfromMeeting(clubs: clubs, meetingName: selection ?? "NilSelection")?.name ?? "")
                            }
                            Spacer().frame(height: 10)
                        }
                    } else {
                        VStack(spacing: 10) {
                            LazyVStack {
                                Section(header: SectionHeader(name: "Clubs")) {
                                    ForEach(clubs.filter { club in club.name.lowercased().components(separatedBy: " ").first(where: {$0.starts(with: search.lowercased())}) != nil || club.name.lowercased().starts(with: search.lowercased()) || club.nickname.lowercased().starts(with: search.lowercased()) }.sorted { $0.name < $1.name }, id: \.name) { club in
                                        ClubCell(club: club, selection: $selection, search: $search)
                                    }
                                }
                            }.padding()
                            LazyVStack {
                                Section(header: SectionHeader(name: "Meetings")) {
                                    ForEach(meetings.filter { (getClubfromMeeting(clubs: clubs, meetingName: $0.title)?.name ?? "").lowercased().components(separatedBy: " ").first(where: {$0.starts(with: search.lowercased())}) != nil || (getClubfromMeeting(clubs: clubs, meetingName: $0.title)?.name ?? "").lowercased().starts(with: search.lowercased()) || (getClubfromMeeting(clubs: clubs, meetingName: $0.title)?.nickname ?? "").lowercased().starts(with: search.lowercased()) }.sorted(by: { $0.startDate < $1.startDate }), id: \.self) { meeting in
                                        ClubMeetingCellPage(meeting: meeting, club: getClubfromMeeting(clubs: clubs, meetingName: meeting.title) ?? Club())
                                    }
                                }
                            }.padding(.horizontal)
                            Spacer().frame(height: 10)
                        }
                    }
                }
            }
        }
        .navigationTitle("Clubs")
        .searchable(text: $search, prompt: "Search for clubs and meetings")
        .disableAutocorrection(true)
        .background(Color("SystemWindow"))
        .onAppear {
            GIDSignIn.sharedInstance.restorePreviousSignIn { googleUser, error in
                if googleUser != nil {
                    authViewModel.signIn()
                    fetchCurrentUser(emailID: googleUser?.profile?.email ?? "NilEmail", completion: { currentUser in
                        campusID = currentUser
                    })
                }
            }
        }
    }
}

struct ClubPage: View {
    
    //MARK: Authentication and Campus ID
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var campusID: User? = nil
    
    //MARK: Club Data
    @AppStorage("JoinedClubs", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var joinedClubs = [String: Bool]()
    let club: Club
    let clubMeetings: [ClubMeeting]
    
    @State var leaders = [User]()
    @State var members = [User]()
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    @State var addLinkSheet = false
    
    @Binding var selection: String?
    
    let columns3 = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if !joinedClubs.keys.map({$0}).contains(cleanFirebaseKey(input: club.name)) {
                if club.category == "affinities" {
                    HStack {
                        Button(action: {
                            joinedClubs.updateValue(true, forKey: cleanFirebaseKey(input: club.name))
                            fetchClubMembers(club: club.name, clubLeaders: club.leaders ?? [], includeAnonymous: leaders.contains(campusID!), completion: { allMembers in
                                members = allMembers
                            })
                        }, label: {
                            HStack(spacing: 5) {
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                Text("Join Club")
                                    .fontWeight(.semibold)
                                    .font(.system(size: 15))
                                    .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                Spacer()
                            }.tintedCellStyle(color: Color(hexString: club.color))
                        }).buttonStyle(.plain)
                        Button(action: {
                            joinedClubs.updateValue(false, forKey: cleanFirebaseKey(input: club.name))
                            fetchClubMembers(club: club.name, clubLeaders: club.leaders ?? [], includeAnonymous: leaders.contains(campusID!), completion: { allMembers in
                                members = allMembers
                            })
                        }, label: {
                            HStack(spacing: 5) {
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                Text("Join Club Anonymously")
                                    .fontWeight(.semibold)
                                    .font(.system(size: 15))
                                    .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                Spacer()
                            }.tintedCellStyle(color: Color(hexString: club.color))
                        }).buttonStyle(.plain)
                    }.padding(.bottom)
                } else {
                    Button(action: {
                        joinedClubs.updateValue(true, forKey: cleanFirebaseKey(input: club.name))
                        fetchClubMembers(club: club.name, clubLeaders: club.leaders ?? [], includeAnonymous: leaders.contains(campusID!), completion: { allMembers in
                            members = allMembers
                        })
                    }, label: {
                        HStack(spacing: 5) {
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                            Text("Join Club")
                                .fontWeight(.semibold)
                                .font(.system(size: 15))
                                .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                            Spacer()
                        }.tintedCellStyle(color: Color(hexString: club.color))
                    }).buttonStyle(.plain)
                        .padding(.bottom)
                }
            }
            if (campusID != nil && leaders.contains(campusID!)) || clubMeetings.filter({ getPredefinedClubfromMeeting(club: club, meetingName: $0.title) && $0.endDate > Date() }) != [] {
                SectionHeader(name: "Meetings")
                VStack {
                    ForEach(clubMeetings.filter { getPredefinedClubfromMeeting(club: club, meetingName: $0.title) && $0.endDate > Date() }.sorted { $0.startDate < $1.startDate }, id: \.id) { meeting in
                        ClubMeetingCellPage(meeting: meeting, club: club)
                    }
                    if campusID != nil && leaders.contains(campusID!) {
                        Button(action: {
                            AddtoClubsCalendarView(club: club, leaders: leaders.map{$0.id+"@college-prep.org"}, title: club.nickname == "" ? club.name + " Meeting" : club.nickname + " Meeting", campusID: $campusID).openInWindow(title: "Add Meeting/Bake Sale", isClear: true, sender: self)
                        }, label: {
                            HStack {
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                Text("Add Meeting or Bake Sale")
                                    .fontWeight(.semibold)
                                    .font(.system(size: 15))
                                    .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                Spacer()
                            }.tintedCellStyle(color: Color(hexString: club.color))
                        })
                        .buttonStyle(.plain)
                    }
                }.padding(.bottom)
            }
            VStack {
                HStack {
                    SectionHeader(name: "About")
                    Text("#\(club.category)")
                        .fontWeight(.medium)
                        .font(.system(size: 15))
                        .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                }
                HStack {
                    Text(club.description)
                        .font(.system(size: 15))
                        .textSelection(.enabled)
                    Spacer()
                }.borderedCellStyle()
                if (campusID != nil && leaders.contains(campusID!)) || club.links != [:] {
                    LazyVGrid(columns: columns3) {
                        if let wrappedLinks = club.links?.map({$0.value}) {
                            ForEach(wrappedLinks.sorted { $0.name < $1.name }, id: \.self) { quickLink in
                                Button(action: {
                                    openURL(URL(string: quickLink.id)!)
                                }, label: {
                                    HStack {
                                        Image(systemName: quickLink.icon)
                                            .font(.system(size: 18))
                                            .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
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
                                        Divider()
                                        if campusID != nil && leaders.contains(campusID!) {
                                            Button(role: .destructive) {
                                                removeClubLink(linkID: quickLink.id, clubName: club.name, completion: {})
                                            } label: {
                                                Text("Delete Link")
                                            }
                                        }
                                    }
                            }
                        }
                        if campusID != nil && leaders.contains(campusID!) {
                            Button(action: {
                                addLinkSheet = true
                            }, label: {
                                HStack {
                                    Image(systemName: "link.badge.plus")
                                        .font(.system(size: 18))
                                        .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                        .frame(width: 40, height: 20)
                                    Text("Add Link to Page")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 15))
                                        .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                        .lineLimit(2)
                                        .lineSpacing(2)
                                    Spacer()
                                }.tintedCellStyle(color: Color(hexString: club.color))
                            }).buttonStyle(.plain)
                                .popover(isPresented: $addLinkSheet) {
                                    AddLinkSheet(club: club)
                                }
                        }
                    }
                }
            }
            if !leaders.isEmpty {
                HStack {
                    SectionHeader(name: "Leaders (\(String(leaders.count)))")
                    if leaders.count > 1 {
                        Button(action: {
                            var emails = [String]()
                            for user in leaders {
                                emails.append(user.id+"@college-prep.org")
                            }
                            let pasteboard = NSPasteboard.general
                            pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
                            pasteboard.setString(emails.joined(separator: ","), forType: NSPasteboard.PasteboardType.string)
                        }, label: {
                            Text("Copy Emails")
                                .fontWeight(.medium)
                                .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                        })
                        Button(action: {
                            var emails = [String]()
                            for user in leaders {
                                emails.append(user.id+"@college-prep.org")
                            }
                            if let url = URL(string: "mailto:\(emails.joined(separator: ","))") {
                                openURL(url)
                            }
                        }, label: {
                            Text("Email Leaders")
                                .fontWeight(.medium)
                                .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                        })
                    }
                }.padding(.top)
                ForEach(leaders.sorted(by: {$0.name < $1.name}).sorted(by: {$0.gradYear < $1.gradYear}), id: \.self) { user in
                    Button(action: {
                        if let url = URL(string: "mailto:\(user.id+"@college-prep.org")") {
                            openURL(url)
                        }
                    }, label: {
                        HStack(spacing: 15) {
                            if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                                Color("SystemGray3")
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                            } else {
                                AsyncImage(url: URL(string: user.imageLink)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                            }
                            VStack(spacing: 2) {
                                HStack {
                                    Text(user.gradYear == "Faculty" ? user.name : user.name+" '"+user.gradYear.dropFirst(2)).bold()
                                        .foregroundStyle(Color("SystemContrast"))
                                    Spacer()
                                }
                                HStack {
                                    Text(user.id+"@college-prep.org")
                                        .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Spacer()
                                }
                            }
                            Spacer()
                        }.borderedCellStyle()
                    }).buttonStyle(.plain)
                }
            }
            if !members.isEmpty {
                HStack {
                    SectionHeader(name: "Members (\(String(members.count)))")
                    if leaders.contains(campusID!) {
                        if club.category == "affinities" {
                            Button(action: {
                                var anonymousEmails = [String]()
                                for user in members.filter({ $0.clubs?[club.name] == false }) {
                                    anonymousEmails.append(user.id+"@college-prep.org")
                                }
                                let pasteboard = NSPasteboard.general
                                pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
                                pasteboard.setString(anonymousEmails.joined(separator: ","), forType: NSPasteboard.PasteboardType.string)
                            }, label: {
                                Text("Copy Bcc Emails")
                                    .fontWeight(.medium)
                                    .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                            })
                        }
                        Button(action: {
                            var emails = [String]()
                            for user in members.filter({ $0.clubs?[club.name] == true }) {
                                emails.append(user.id+"@college-prep.org")
                            }
                            let pasteboard = NSPasteboard.general
                            pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
                            pasteboard.setString(emails.joined(separator: ","), forType: NSPasteboard.PasteboardType.string)
                        }, label: {
                            Text("Copy Emails")
                                .fontWeight(.medium)
                                .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                        })
                        Button(action: {
                            var emails = [String]()
                            for user in members.filter({ $0.clubs?[club.name] == true }) {
                                emails.append(user.id+"@college-prep.org")
                            }
                            var anonymousEmails = [String]()
                            for user in members.filter({ $0.clubs?[club.name] == false }) {
                                anonymousEmails.append(user.id+"@college-prep.org")
                            }
                            if let url = URL(string: "mailto:\(emails.joined(separator: ","))?bcc=\(anonymousEmails.joined(separator: ","))") {
                                openURL(url)
                            }
                        }, label: {
                            Text("Email Members")
                                .fontWeight(.medium)
                                .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                        })
                    }
                }.padding(.top)
                ForEach(members.sorted(by: {$0.name < $1.name}), id: \.self) { user in
                    HStack(spacing: 15) {
                        if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                            Color("SystemGray3")
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                        } else {
                            AsyncImage(url: URL(string: user.imageLink)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 55, height: 55)
                            .clipShape(Circle())
                        }
                        VStack(spacing: 2) {
                            HStack {
                                Text(user.gradYear == "Faculty" ? user.name : user.name+" '"+user.gradYear.dropFirst(2)).bold()
                                    .foregroundStyle(Color("SystemContrast"))
                                Spacer()
                            }
                            HStack {
                                Text(user.id+"@college-prep.org")
                                    .foregroundStyle(Color(.gray))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer()
                            }
                        }
                        Spacer()
                    }.borderedCellStyle()
                }
            }
        }
        .padding()
        .onAppear {
            fetchClubLeaders(leaders: club.leaders ?? [], completion: { allLeaders in
                leaders = allLeaders
                GIDSignIn.sharedInstance.restorePreviousSignIn { googleUser, error in
                    if googleUser != nil {
                        authViewModel.signIn()
                        fetchCurrentUser(emailID: googleUser?.profile?.email ?? "NilEmail", completion: { currentUser in
                            campusID = currentUser
                            fetchClubMembers(club: club.name, clubLeaders: club.leaders ?? [], includeAnonymous: leaders.contains(campusID!), completion: { allMembers in
                                members = allMembers
                            })
                        })
                    }
                }
            })
        }
        .navigationTitle(club.nickname != "" ? club.nickname : club.name)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if campusID != nil && !leaders.contains(campusID!) {
                    Button(action: {
                        if joinedClubs.keys.map({$0}).contains(cleanFirebaseKey(input: club.name)) {
                            joinedClubs.removeValue(forKey: cleanFirebaseKey(input: club.name))
                            selection = ""
                        } else {
                            joinedClubs.updateValue(true, forKey: cleanFirebaseKey(input: club.name))
                            selection = club.name
                        }
                    }, label: {
                        if joinedClubs.keys.map({$0}).contains(cleanFirebaseKey(input: club.name)) {
                            Text("Unjoin Club")
                                .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                        } else {
                            Text("Join Club")
                                .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                        }
                    })
                }
            }
            ToolbarItem(placement: .automatic) {
                if club.category == "affinities" && !joinedClubs.keys.map({$0}).contains(cleanFirebaseKey(input: club.name)) {
                    Button(action: {
                        withAnimation {
                            joinedClubs.updateValue(false, forKey: cleanFirebaseKey(input: club.name))
                            selection = club.name
                        }
                    }, label: {
                        Text("Join Club Anonymously")
                            .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                    })
                }
            }
        }
    }
    
    struct AddLinkSheet: View {
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) var dismiss
        
        let club: Club
        @State var title = ""
        @State var url = ""
        @State var icon = "link"
        
        let columns4 = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        let icons = ["link", "safari.fill", "pin.fill", "bookmark.fill",
                     "folder.fill", "doc.text.fill", "tablecells.fill", "rectangle.split.3x3.fill",
                     "rectangle.fill.on.rectangle.angled.fill", "photo.fill", "film.fill", "waveform",
                     "chart.bar.xaxis", "note.text", "scroll.fill", "paperclip",
                     "quote.opening", "bag.fill", "book.fill", "archivebox.fill"]
        
        var body: some View {
            VStack {
                ScrollView {
                    VStack(spacing: 15) {
                        Spacer().frame(height: 5)
                        VStack(spacing: 0) {
                            HStack(spacing: 15) {
                                Image(systemName: "character.cursor.ibeam")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color(.white))
                                    .frame(width: 32, height: 32)
                                    .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color)))
                                TextField("Title", text: $title)
                                    .font(.system(size: 15, weight: .medium))
                                    .textFieldStyle(.plain)
                            }
                            Divider().padding(.vertical)
                            HStack(spacing: 15) {
                                Image(systemName: "link")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color(.white))
                                    .frame(width: 32, height: 32)
                                    .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(Color(hexString: "36A2FF")))
                                TextField("URL", text: $url)
                                    .font(.system(size: 15, weight: .medium))
                                    .textFieldStyle(.plain)
                            }
                        }.borderedCellStyle()
                    }
                    VStack {
                        LazyVGrid(columns: columns4, spacing: 20) {
                            ForEach(icons, id: \.self) { iconString in
                                Button {
                                    icon = iconString
                                } label: {
                                    if icon == iconString {
                                        Image(systemName: iconString)
                                            .font(.system(size: 18))
                                            .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                            .frame(width: 35, height: 35)
                                            .background(Circle().foregroundStyle(Color("SystemCell").opacity(0.5)))
                                            .padding(3)
                                            .overlay(
                                                Circle()
                                                    .stroke(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color), lineWidth: 3)
                                            )
                                            .frame(width: 40, height: 40)
                                    } else {
                                        Image(systemName: iconString)
                                            .font(.system(size: 18))
                                            .foregroundStyle(colorScheme == .light && NSColor(hexString: club.color).luminance > 0.5 ? Color(NSColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                            .frame(width: 35, height: 35)
                                            .background(Circle().foregroundStyle(Color("SystemCell").opacity(0.5)))
                                            .frame(width: 40, height: 40)
                                    }
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }.borderedCellStyle()
                        .padding(.vertical)
                    Button(action: {
                        publishClubLink(link: QuickLink(name: title, id: url, icon: icon, visible: true), clubName: club.name)
                        dismiss()
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Add Link to Page")
                                .bold()
                                .foregroundStyle(.white)
                                .dynamicTypeSize(.small ... .large)
                            Spacer()
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(hexString: club.color)))
                    }).buttonStyle(ScaleButtonStyle())
                        .disabled(title.isEmpty || url.isEmpty)
                        .opacity(title.isEmpty || url.isEmpty ? 0.5 : 1)
                }
            }
            .padding()
            .frame(minWidth: 400, minHeight: 400)
        }
    }
}
