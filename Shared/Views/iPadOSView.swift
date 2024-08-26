//
//  iPadOSView.swift
//  CPS Campus (iPadOS)
//
//  5/30/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import UserNotifications
import WidgetKit
import GoogleSignIn
import FirebaseAuth

@available(iOS 16, *) //this View is needed because Apple changed NavigationView to NavigationSplitView in iOS 16
struct iPadOSView16: View {
    
    //MARK: Environment
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) var scenePhase
    @State var selection: String? = "Home"
    @State var settingsPresented = false
    
    @State var clubLink = ""
    @State var showClubSheet = false
    
    //MARK: Authentication and Campus ID
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var userObject = UserFetcher()
    
    //MARK: Course Data
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses: [Course] = defaultCourses
    
    //MARK: Schedule Data
    @StateObject var blocksObject = BlocksFetcher()
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    
    //MARK: Club Data
    @AppStorage("JoinedClubs", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var joinedClubs = [String: Bool]()
    @StateObject var clubsObject = ClubsFetcher()
    @State var clubMeetings = [ClubMeeting]()
    
    //MARK: Sport Data
    @AppStorage("FollowedSports", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var followedSports = [String: Bool]()
    @StateObject var sportsObject = SportsFetcher()
    @State var sportGames = [SportGame]()
    
    //MARK: Settings
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("NotificationSettings", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var notificationSettings: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    
    //MARK: Setup
    @AppStorage("SetUp", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var setUp = true
    
    var body: some View {
        Group {
            NavigationSplitView {
                List([""], id: \.self, selection: $selection) { _ in
                    NavigationLink(destination: HomeViewiPadOS(clubMeetings: $clubMeetings, clubs: $clubsObject.clubs, sportGames: $sportGames, sports: $sportsObject.sports), tag: "Home", selection: $selection) {
                        Label(
                            title: { Text("Home") },
                            icon: { Image(systemName: "house.fill") }
                        )
                    }
                    NavigationLink(destination: ScheduleViewiPadOS(), tag: "Schedule", selection: $selection) {
                        Label(
                            title: { Text("Schedule") },
                            icon: { Image(systemName: "calendar").font(Font.body.bold()) }
                        )
                    }
                    Group {
                        if authViewModel.state == .signedIn && !(Auth.auth().currentUser?.isAnonymous ?? false) {
                            NavigationLink(destination: DirectoryViewiPadOS(clubs: clubsObject.clubs), tag: "Directory", selection: $selection) {
                                Label(
                                    title: { Text("Directory") },
                                    icon: { Image(systemName: "person.2.fill").font(Font.body.weight(.medium)) }
                                )
                            }
                        } else {
                            Button(action: {
                                openURL(URL(string: "cpscampus://settings/campusID")!)
                            }, label: {
                                Label(
                                    title: { Text("Directory") },
                                    icon: { Image(systemName: "person.2.fill").font(Font.body.weight(.medium)) }
                                )
                            })
                        }
                    }
                    Group {
                        if authViewModel.state == .signedIn && !(Auth.auth().currentUser?.isAnonymous ?? false) {
                            NavigationLink(destination: ClubsView(meetings: $clubMeetings, clubs: clubsObject.clubs), tag: "Clubs", selection: $selection) {
                                Label(
                                    title: { Text("Clubs") },
                                    icon: { Image(systemName: "theatermask.and.paintbrush.fill").font(Font.body.weight(.medium)) }
                                )
                            }
                        } else {
                            Button(action: {
                                openURL(URL(string: "cpscampus://settings/campusID")!)
                            }, label: {
                                Label(
                                    title: { Text("Clubs") },
                                    icon: { Image(systemName: "theatermask.and.paintbrush.fill").font(Font.body.weight(.medium)) }
                                )
                            })
                        }
                    }
                    NavigationLink(destination: SportsView(games: $sportGames, sports: sportsObject.sports), tag: "Sports", selection: $selection) {
                        Label(
                            title: { Text("Sports") },
                            icon: { Image(systemName: "sportscourt.fill") }
                        )
                    }
                    Section(header: Text("Courses").foregroundStyle(Color("SystemContrast"))) {
                        ForEach($courses.sorted(by: {$0.wrappedValue.num < $1.wrappedValue.num })) { $course in
                            if coursesGroup.contains(course.id) {
                                NavigationLink(value: course.id) {
                                    Label {
                                        CourseLabelView(course: $course)
                                    } icon: {
                                        Image(systemName: "book.closed.fill")
                                            .foregroundStyle(course.isFreePeriod ? .gray : Color(hexString: course.color))
                                    }
                                }
                            } else if course.id == "Compass" && compassGradYears.contains(gradYear) {
                                NavigationLink(value: course.id) {
                                    Label {
                                        CourseLabelView(course: $course)
                                    } icon: {
                                        Image(systemName: "heart.fill")
                                            .foregroundStyle(Color(hexString: course.color))
                                    }
                                }
                            }
                        }
                    }
                    Section(header: Text("Community").foregroundStyle(Color("SystemContrast"))) {
                        ForEach($courses.filter { communityGroup.contains($0.wrappedValue.id) }.sorted(by: {$0.wrappedValue.num < $1.wrappedValue.num })) { $course in
                            NavigationLink(value: course.id) {
                                Label {
                                    CourseLabelView(course: $course)
                                } icon: {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(Color(hexString: course.color))
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Campus")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            settingsPresented = true
                        }, label: {
                            Image(systemName: "gear")
                                .foregroundStyle(Color("AccentColor"))
                        })
                        .sheet(isPresented: $settingsPresented, content: {
                            SettingsPane(clubs: clubsObject.clubs, clubMeetings: clubMeetings, sports: sportsObject.sports, sportGames: sportGames)
                        })
                    }
                }
            } detail: {
                if let linkID = selection {
                    switch linkID {
                    case let courseID where allAssignableCourses.contains(linkID):
                        ForEach($courses.filter{ $0.id == courseID }) { $course in
                            CourseSubview(course: $course, compassBlock: course.compassBlock, visibleRotations: course.visibleRotations, isFreePeriod: course.isFreePeriod, name: course.name, teacher: course.teacher, room: course.room, color: Color(hexString: course.color))
                        }
                    default: HomeViewiPadOS(clubMeetings: $clubMeetings, clubs: $clubsObject.clubs, sportGames: $sportGames, sports: $sportsObject.sports)
                    }
                } else {
                    HomeViewiPadOS(clubMeetings: $clubMeetings, clubs: $clubsObject.clubs, sportGames: $sportGames, sports: $sportsObject.sports)
                }
            }
        }
        .sheet(isPresented: $setUp) {
            SetUpView()
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showClubSheet) {
            ClubSheet(clubName: clubLink, clubs: $clubsObject.clubs, clubMeetings: $clubMeetings)
                .environmentObject(authViewModel)
        }
        .accentColor(Color("AccentColor"))
        .onOpenURL { url in
            if url.absoluteString.contains("schedule") {
                selection = "Schedule"
            } else if url.absoluteString.contains("planner") {
                selection = "Planner"
            } else if url.absoluteString.contains("home") {
                selection = "Home"
            } else if url.absoluteString.contains("directory") {
                selection = "Directory"
            } else if url.absoluteString.contains("sports") {
                selection = "Sports"
            } else if url.absoluteString.contains("settings") {
                settingsPresented = true
            } else if url.absoluteString.contains("compass") {
                selection = "Compass"
            } else if url.absoluteString.contains("open") {
                selection = "Open"
            } else if url.absoluteString.contains("-Block") {
                selection = url.absoluteString.replacingOccurrences(of: "cpscampus://", with: "")
            } else if url.absoluteString.contains("cpscampus://clubs/") {
                clubLink = url.absoluteString.replacingOccurrences(of: "cpscampus://clubs/", with: "").replacingOccurrences(of: "+", with: " ")
                showClubSheet = true
            } else if url.absoluteString.contains("clubs") {
                selection = "Clubs"
            }
        }
        .onAppear(perform: {
            //MARK: Google sign in restore session
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if user != nil {
                    authViewModel.signIn()
                    userObject.observeData(emailID: user?.profile?.email ?? "NilEmail")
                    userObject.observeCourses(emailID: user?.profile?.email ?? "NilEmail")
                    joinedClubs = userObject.user?.clubs ?? [String:Bool]()
                    followedSports = userObject.user?.sports ?? [String:Bool]()
                } else {
                    Auth.auth().signInAnonymously { authResult, error in
                        authLogger.log("anonymous auth")
                    }
                }
            }
            blocksObject.fetchData(completion: { scheduleArray in
                if let array = scheduleArray {
                    generateAllNotifications(courses: courses, blocks: blocksObject.blocks, notificationSettings: notificationSettings, gradYear: gradYear)
                    scheduleBlocks = array
                }
            })
        })
        .onChange(of: userObject.user) { updatedUser in
            gradYear = updatedUser?.gradYear ?? gradYear
            joinedClubs = updatedUser?.clubs ?? [String:Bool]()
            followedSports = updatedUser?.sports ?? [String:Bool]()
        }
        .onChange(of: userObject.courses) { updatedCourses in
            if let wrappedCourses = updatedCourses?.values.map({$0}) {
                courses = wrappedCourses.sorted(by: {$0.num < $1.num})
            }
        }
        .onChange(of: courses) { _ in
            if let currentUser = userObject.user {
                updateCurrentCourses(emailID: currentUser.id, courses: courses)
            }
        }
        .onChange(of: joinedClubs) { _ in
            if let currentUser = userObject.user {
                updateCurrentUser(emailID: currentUser.id, user: User(id: currentUser.id, name: currentUser.name, gradYear: currentUser.gradYear, imageLink: currentUser.imageLink, pronouns: currentUser.pronouns, socials: currentUser.socials, privacy: currentUser.privacy, clubs: joinedClubs, sports: currentUser.sports, tags: currentUser.tags))
            }
        }
        .onChange(of: followedSports) { _ in
            if let currentUser = userObject.user {
                updateCurrentUser(emailID: currentUser.id, user: User(id: currentUser.id, name: currentUser.name, gradYear: currentUser.gradYear, imageLink: currentUser.imageLink, pronouns: currentUser.pronouns, socials: currentUser.socials, privacy: currentUser.privacy, clubs: currentUser.clubs, sports: followedSports, tags: currentUser.tags))
            }
        }
        .onChange(of: blocksObject.blocks) { blocks in
            if !blocks.isEmpty {
                generateAllNotifications(courses: courses, blocks: blocksObject.blocks, notificationSettings: notificationSettings, gradYear: gradYear)
                scheduleBlocks = blocks
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .onChange(of: scenePhase) { _ in
            clubsObject.fetchData(completion: { clubArray in
                if let wrappedClubs = clubArray {
                    clubsObject.clubs = wrappedClubs
                    fetchClubMeetings(clubMeetings: clubMeetings, completion: { clubMeetingArray in
                        if let wrappedMeetings = clubMeetingArray {
                            clubMeetings = wrappedMeetings
                            if notificationSettings["ClubMeetingStarts"] == 1.0 {
                                generateAllNotificationsClubs(clubs: wrappedClubs, joinedClubs: joinedClubs, clubMeetings: wrappedMeetings, minutes: notificationSettings["ClubMinutes"] ?? 5.0)
                            }
                        }
                    })
                }
            })
            sportsObject.fetchData(completion: { sportArray in
                if let wrappedSports = sportArray {
                    sportsObject.sports = wrappedSports
                    fetchSportGames(sportGames: sportGames, completion: { sportGameArray in
                        if let wrappedGames = sportGameArray {
                            sportGames = wrappedGames
                            if notificationSettings["SportGameStarts"] == 1.0 {
                                generateAllNotificationsSports(sports: wrappedSports, followedSports: followedSports, sportGames: wrappedGames, minutes: notificationSettings["SportMinutes"] ?? 5.0)
                            }
                        }
                    })
                }
            })
        }
        .onDisappear {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    struct CourseLabelView: View {
        @Binding var course: Course
        
        var body: some View{
            Group {
                if course.name != course.id {
                    HStack {
                        if course.isFreePeriod {
                            Text("Free Period")
                        } else {
                            Text(course.name)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            if course.name != course.id {
                                if course.id == "Compass" {
                                    Text(course.compassBlock)
                                        .opacity(0.75)
                                } else {
                                    Text(course.id)
                                        .opacity(0.75)
                                }
                            }
                            if course.visibleRotations != 0 {
                                Image(systemName: "\(course.visibleRotations).circle").opacity(0.75)
                            }
                        }
                    }
                } else {
                    Text(course.name)
                }
            }
        }
    }
}

struct iPadOSView: View {
    
    //MARK: Environment
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) var scenePhase
    @State var selection: String? = "Home"
    @State var settingsPresented = false
    
    @State var clubLink = ""
    @State var showClubSheet = false
    
    //MARK: Authentication and Campus ID
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var userObject = UserFetcher()
    
    //MARK: Course Data
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses: [Course] = defaultCourses
    
    //MARK: Schedule Data
    @StateObject var blocksObject = BlocksFetcher()
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    
    //MARK: Club Data
    @AppStorage("JoinedClubs", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var joinedClubs = [String: Bool]()
    @StateObject var clubsObject = ClubsFetcher()
    @State var clubMeetings = [ClubMeeting]()
    
    //MARK: Sport Data
    @AppStorage("FollowedSports", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var followedSports = [String: Bool]()
    @StateObject var sportsObject = SportsFetcher()
    @State var sportGames = [SportGame]()
    
    //MARK: Settings
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("NotificationSettings", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var notificationSettings: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    
    //MARK: Setup
    @AppStorage("SetUp", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var setUp = true
    
    var body: some View {
        Group {
            NavigationView {
                List {
                    NavigationLink(destination: HomeViewiPadOS(clubMeetings: $clubMeetings, clubs: $clubsObject.clubs, sportGames: $sportGames, sports: $sportsObject.sports), tag: "Home", selection: $selection) {
                        Label(
                            title: { Text("Home") },
                            icon: { Image(systemName: "house.fill") }
                        )
                    }
                    NavigationLink(destination: ScheduleViewiPadOS(), tag: "Schedule", selection: $selection) {
                        Label(
                            title: { Text("Schedule") },
                            icon: { Image(systemName: "calendar").font(Font.body.bold()) }
                        )
                    }
                    Group {
                        if authViewModel.state == .signedIn && !(Auth.auth().currentUser?.isAnonymous ?? false) {
                            NavigationLink(destination: DirectoryView(clubs: clubsObject.clubs), tag: "Directory", selection: $selection) {
                                Label(
                                    title: { Text("Directory") },
                                    icon: { Image(systemName: "person.2.fill").font(Font.body.weight(.medium)) }
                                )
                            }
                        } else {
                            Button(action: {
                                openURL(URL(string: "cpscampus://settings/campusID")!)
                            }, label: {
                                Label(
                                    title: { Text("Directory") },
                                    icon: { Image(systemName: "person.2.fill").font(Font.body.weight(.medium)) }
                                )
                            })
                        }
                    }
                    Group {
                        if authViewModel.state == .signedIn && !(Auth.auth().currentUser?.isAnonymous ?? false) {
                            NavigationLink(destination: ClubsView(meetings: $clubMeetings, clubs: clubsObject.clubs), tag: "Clubs", selection: $selection) {
                                Label(
                                    title: { Text("Clubs") },
                                    icon: { Image(systemName: "theatermask.and.paintbrush.fill").font(Font.body.weight(.medium)) }
                                )
                            }
                        } else {
                            Button(action: {
                                openURL(URL(string: "cpscampus://settings/campusID")!)
                            }, label: {
                                Label(
                                    title: { Text("Clubs") },
                                    icon: { Image(systemName: "theatermask.and.paintbrush.fill").font(Font.body.weight(.medium)) }
                                )
                            })
                        }
                    }
                    NavigationLink(destination: SportsView(games: $sportGames, sports: sportsObject.sports), tag: "Sports", selection: $selection) {
                        Label(
                            title: { Text("Sports") },
                            icon: { Image(systemName: "sportscourt.fill") }
                        )
                    }
                    Section(header: Text("Courses").foregroundStyle(Color("SystemContrast"))) {
                        ForEach($courses.sorted(by: {$0.wrappedValue.num < $1.wrappedValue.num })) { $course in
                            if coursesGroup.contains(course.id) {
                                NavigationLink(destination: CourseSubview(course: $course, compassBlock: course.compassBlock, visibleRotations: course.visibleRotations, isFreePeriod: course.isFreePeriod, name: course.name, teacher: course.teacher, room: course.room, color: Color(hexString: course.color)), tag: course.id, selection: $selection) {
                                    Label {
                                        if course.name != course.id {
                                            HStack {
                                                if course.isFreePeriod {
                                                    Text("Free Period").foregroundStyle(Color("SystemContrast"))
                                                } else {
                                                    Text(course.name).foregroundStyle(Color("SystemContrast"))
                                                }
                                                Spacer()
                                                HStack(spacing: 4) {
                                                    if course.name != course.id {
                                                        Text(course.id)
                                                            .foregroundStyle(.gray)
                                                    }
                                                    if course.visibleRotations != 0 {
                                                        Image(systemName: "\(course.visibleRotations).circle").opacity(0.75)
                                                    }
                                                }
                                            }
                                        } else {
                                            Text(course.name)
                                        }
                                    } icon: {
                                        Image(systemName: "book.closed.fill")
                                            .accentColor(course.isFreePeriod ? .gray : Color(hexString: course.color))
                                    }
                                }
                            } else if course.id == "Compass" && compassGradYears.contains(gradYear) {
                                NavigationLink(destination: CourseSubview(course: $course, compassBlock: course.compassBlock, visibleRotations: course.visibleRotations, isFreePeriod: course.isFreePeriod, name: course.name, teacher: course.teacher, room: course.room, color: Color(hexString: course.color)), tag: "Compass", selection: $selection) {
                                    Label {
                                        HStack {
                                            Text(course.name).foregroundStyle(Color("SystemContrast"))
                                            Spacer()
                                            HStack(spacing: 4) {
                                                Text(course.compassBlock)
                                                    .foregroundStyle(.gray)
                                                Image(systemName: "\(course.visibleRotations).circle").foregroundStyle(.gray)
                                            }
                                        }
                                    } icon: {
                                        Image(systemName: "heart.fill")
                                            .accentColor(Color(hexString: course.color))
                                    }
                                }
                            }
                        }
                    }
                    Section(header: Text("Community").foregroundStyle(Color("SystemContrast"))) {
                        ForEach($courses.filter { communityGroup.contains($0.wrappedValue.id) }.sorted(by: {$0.wrappedValue.num < $1.wrappedValue.num })) { $course in
                            NavigationLink(destination: CourseSubview(course: $course, compassBlock: course.compassBlock, visibleRotations: course.visibleRotations, isFreePeriod: course.isFreePeriod, name: course.name, teacher: course.teacher, room: course.room, color: Color(hexString: course.color)), tag: course.id, selection: $selection) {
                                Label {
                                    if course.name != course.id {
                                        HStack {
                                            Text(course.name).lineLimit(1)
                                            Spacer()
                                            Text(course.id).opacity(0.5)
                                        }
                                    } else {
                                        Text(course.name)
                                    }
                                } icon: {
                                    Image(systemName: "person.fill")
                                        .accentColor(Color(hexString: course.color))
                                }
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
                .navigationBarTitle("Campus")
                .navigationViewStyle(DoubleColumnNavigationViewStyle())
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            settingsPresented = true
                        }, label: {
                            Image(systemName: "gear")
                                .foregroundStyle(Color("AccentColor"))
                        })
                        .sheet(isPresented: $settingsPresented, content: {
                            SettingsPane(clubs: clubsObject.clubs, clubMeetings: clubMeetings, sports: sportsObject.sports, sportGames: sportGames)
                        })
                    }
                }
            }
        }
        .sheet(isPresented: $setUp) {
            SetUpView()
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showClubSheet) {
            ClubSheet(clubName: clubLink, clubs: $clubsObject.clubs, clubMeetings: $clubMeetings)
                .environmentObject(authViewModel)
        }
        .accentColor(Color("AccentColor"))
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .onOpenURL { url in
            if url.absoluteString.contains("schedule") {
                selection = "Schedule"
            } else if url.absoluteString.contains("planner") {
                selection = "Planner"
            } else if url.absoluteString.contains("home") {
                selection = "Home"
            } else if url.absoluteString.contains("sports") {
                selection = "Sports"
            } else if url.absoluteString.contains("settings") {
                settingsPresented = true
            } else if url.absoluteString.contains("compass") {
                selection = "Compass"
            } else if url.absoluteString.contains("open") {
                selection = "Open"
            } else if url.absoluteString.contains("-Block") {
                selection = url.absoluteString.replacingOccurrences(of: "cpscampus://", with: "")
            } else if url.absoluteString.contains("cpscampus://clubs/") {
                clubLink = url.absoluteString.replacingOccurrences(of: "cpscampus://clubs/", with: "").replacingOccurrences(of: "+", with: " ")
                showClubSheet = true
            } else if url.absoluteString.contains("clubs") {
                selection = "Clubs"
            }
        }
        .onAppear(perform: {
            //MARK: Google sign in restore session
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if user != nil {
                    authViewModel.signIn()
                    userObject.observeData(emailID: user?.profile?.email ?? "NilEmail")
                    joinedClubs = userObject.user?.clubs ?? [String:Bool]()
                    followedSports = userObject.user?.sports ?? [String:Bool]()
                } else {
                    Auth.auth().signInAnonymously { authResult, error in
                        authLogger.log("anonymous auth")
                    }
                }
            }
            blocksObject.fetchData(completion: { scheduleArray in
                if let array = scheduleArray {
                    generateAllNotifications(courses: courses, blocks: blocksObject.blocks, notificationSettings: notificationSettings, gradYear: gradYear)
                    scheduleBlocks = array
                }
            })
        })
        .onChange(of: userObject.user) { updatedUser in
            gradYear = updatedUser?.gradYear ?? gradYear
            joinedClubs = updatedUser?.clubs ?? [String:Bool]()
            followedSports = updatedUser?.sports ?? [String:Bool]()
        }
        .onChange(of: userObject.courses) { updatedCourses in
            if let wrappedCourses = updatedCourses?.values.map({$0}) {
                courses = wrappedCourses.sorted(by: {$0.num < $1.num})
            }
        }
        .onChange(of: joinedClubs) { _ in
            if let currentUser = userObject.user {
                updateCurrentUser(emailID: currentUser.id, user: User(id: currentUser.id, name: currentUser.name, gradYear: currentUser.gradYear, imageLink: currentUser.imageLink, pronouns: currentUser.pronouns, socials: currentUser.socials, privacy: currentUser.privacy, clubs: joinedClubs, sports: currentUser.sports, tags: currentUser.tags))
            }
        }
        .onChange(of: followedSports) { _ in
            if let currentUser = userObject.user {
                updateCurrentUser(emailID: currentUser.id, user: User(id: currentUser.id, name: currentUser.name, gradYear: currentUser.gradYear, imageLink: currentUser.imageLink, pronouns: currentUser.pronouns, socials: currentUser.socials, privacy: currentUser.privacy, clubs: currentUser.clubs, sports: followedSports, tags: currentUser.tags))
            }
        }
        .onChange(of: blocksObject.blocks) { blocks in
            if !blocks.isEmpty {
                generateAllNotifications(courses: courses, blocks: blocksObject.blocks, notificationSettings: notificationSettings, gradYear: gradYear)
                scheduleBlocks = blocks
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .onChange(of: scenePhase) { _ in
            clubsObject.fetchData(completion: { clubArray in
                if let wrappedClubs = clubArray {
                    clubsObject.clubs = wrappedClubs
                    fetchClubMeetings(clubMeetings: clubMeetings, completion: { clubMeetingArray in
                        if let wrappedMeetings = clubMeetingArray {
                            clubMeetings = wrappedMeetings
                            if notificationSettings["ClubMeetingStarts"] == 1.0 {
                                generateAllNotificationsClubs(clubs: wrappedClubs, joinedClubs: joinedClubs, clubMeetings: wrappedMeetings, minutes: notificationSettings["ClubMinutes"] ?? 5.0)
                            }
                        }
                    })
                }
            })
            sportsObject.fetchData(completion: { sportArray in
                if let wrappedSports = sportArray {
                    sportsObject.sports = wrappedSports
                    fetchSportGames(sportGames: sportGames, completion: { sportGameArray in
                        if let wrappedGames = sportGameArray {
                            sportGames = wrappedGames
                            if notificationSettings["SportGameStarts"] == 1.0 {
                                generateAllNotificationsSports(sports: wrappedSports, followedSports: followedSports, sportGames: wrappedGames, minutes: notificationSettings["SportMinutes"] ?? 5.0)
                            }
                        }
                    })
                }
            })
        }
        .onDisappear {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
