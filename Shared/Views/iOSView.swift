//
//  iOSView.swift
//  CPS Campus (iOS)
//
//  5/30/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import WidgetKit
import UserNotifications
import GoogleSignIn
import FirebaseAuth

struct iOSView: View {
    
    //MARK: Environment
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) var scenePhase
    @State var selectedTab = TabIdentifier.home
    
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
    @AppStorage("SettingsBadge", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var settingsBadge = 0
    @AppStorage("EditCompassAlert", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var compassAlert = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(clubMeetings: $clubMeetings, clubs: $clubsObject.clubs, sportGames: $sportGames, sports: $sportsObject.sports)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(TabIdentifier.home)
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(TabIdentifier.schedule)
            CoursesView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(TabIdentifier.settings)
        }
        .fullScreenCover(isPresented: $setUp) {
            SetUpView()
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showClubSheet) {
            ClubSheet(clubName: clubLink, clubs: $clubsObject.clubs, clubMeetings: $clubMeetings)
                .environmentObject(authViewModel)
        }
        .accentColor(Color("AccentColor"))
        .onOpenURL { url in
            if url.absoluteString.contains("cpscampus://clubs/") {
                clubLink = url.absoluteString.replacingOccurrences(of: "cpscampus://clubs/", with: "").replacingOccurrences(of: "+", with: " ")
                showClubSheet = true
            } else {
                guard let tabIdentifier = url.tabIdentifier else {
                    return
                }
                selectedTab = tabIdentifier
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
}

enum TabIdentifier: Hashable {
    case home, schedule, planner, clubs, sports, settings
}

extension URL {
    var isDeeplink: Bool {
        return scheme == "cpscampus"
    }
    
    var tabIdentifier: TabIdentifier? {
        guard isDeeplink else { return nil }
        
        switch host {
        case "home": return .home
        case "schedule": return .schedule
        case "planner": return .planner
        case "clubs": return .home
        case "sports": return .home
        case "settings": return .settings
        default: return .home
        }
    }
}
