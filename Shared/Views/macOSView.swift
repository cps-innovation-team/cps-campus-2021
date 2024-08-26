//
//  macOSView.swift
//  CPS Campus (macOS)
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

struct macOSView: View {
    
    //MARK: Environment
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) var scenePhase
    @State var selection: String? = "Home"
    @State var settingsPresented = false
    
    @State var timer = Timer.publish(every: 0.5, tolerance: 1, on: .main, in: .common).autoconnect()
    @State private var counter = 0
    
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
        NavigationView {
            List {
                NavigationLink(destination: HomeViewmacOS(clubMeetings: $clubMeetings, clubs: $clubsObject.clubs, sportGames: $sportGames, sports: $sportsObject.sports), tag: "Home", selection: $selection) {
                    Label(
                        title: { Text("Home") },
                        icon: { Image(systemName: "house").font(Font.body.weight(.medium)) }
                    )
                }
                NavigationLink(destination: ScheduleViewmacOS(), tag: "Schedule", selection: $selection) {
                    Label(
                        title: { Text("Schedule") },
                        icon: { Image(systemName: "calendar").font(Font.body.weight(.medium)) }
                    )
                }
                Group {
                    if authViewModel.state == .signedIn && !(Auth.auth().currentUser?.isAnonymous ?? false) {
                        NavigationLink(destination: DirectoryViewmacOS(clubs: clubsObject.clubs), tag: "Directory", selection: $selection) {
                            Label(
                                title: { Text("Directory") },
                                icon: { Image(systemName: "person.2").font(Font.body.weight(.medium)) }
                            )
                        }
                    } else {
                        Button(action: {
                            openURL(URL(string: "cpscampus://settings/campusID")!)
                        }, label: {
                            Label(
                                title: { Text("Directory") },
                                icon: { Image(systemName: "person.2").font(Font.body.weight(.medium)) }
                            )
                        }).buttonStyle(.plain)
                    }
                }
                Group {
                    if authViewModel.state == .signedIn && !(Auth.auth().currentUser?.isAnonymous ?? false) {
                        NavigationLink(destination: ClubsView(meetings: $clubMeetings, clubs: clubsObject.clubs), tag: "Clubs", selection: $selection) {
                            Label(
                                title: { Text("Clubs") },
                                icon: { Image(systemName: "theatermask.and.paintbrush").font(Font.body.weight(.medium)) }
                            )
                        }
                    } else {
                        Button(action: {
                            openURL(URL(string: "cpscampus://settings/campusID")!)
                        }, label: {
                            Label(
                                title: { Text("Clubs") },
                                icon: { Image(systemName: "theatermask.and.paintbrush").font(Font.body.weight(.medium)) }
                            )
                        }).buttonStyle(.plain)
                    }
                }
                NavigationLink(destination: SportsView(games: $sportGames, sports: sportsObject.sports), tag: "Sports", selection: $selection) {
                    Label(
                        title: { Text("Sports") },
                        icon: { Image(systemName: "sportscourt").font(Font.body.weight(.medium)) }
                    )
                }
                Section(header: Text("Courses")) {
                    ForEach($courses.sorted(by: {$0.wrappedValue.num < $1.wrappedValue.num })) { $course in
                        if coursesGroup.contains(course.id) {
                            NavigationLink(destination: CourseSubview(course: $course, compassBlock: course.compassBlock, visibleRotations: course.visibleRotations, isFreePeriod: course.isFreePeriod, name: course.name, teacher: course.teacher, room: course.room, color: Color(hexString: course.color)), tag: course.id, selection: $selection) {
                                Label {
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
                                                    Text(course.id)
                                                        .opacity(0.5)
                                                }
                                                if course.visibleRotations != 0 {
                                                    Image(systemName: "\(course.visibleRotations).circle").opacity(0.5)
                                                }
                                            }
                                        }
                                    } else {
                                        Text(course.name)
                                    }
                                } icon: {
                                    Image(systemName: "book.closed").font(Font.body.weight(.medium))
                                }.accentColor(course.isFreePeriod ? .gray : Color(hexString: course.color))
                            }
                        } else if course.id == "Compass" && compassGradYears.contains(gradYear) {
                            NavigationLink(destination: CourseSubview(course: $course, compassBlock: course.compassBlock, visibleRotations: course.visibleRotations, isFreePeriod: course.isFreePeriod, name: course.name, teacher: course.teacher, room: course.room, color: Color(hexString: course.color)), tag: "Compass", selection: $selection) {
                                Label {
                                    HStack {
                                        Text(course.name)
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Text(course.compassBlock)
                                                .opacity(0.5)
                                            Image(systemName: "\(course.visibleRotations).circle").opacity(0.5)
                                        }
                                    }
                                } icon: {
                                    Image(systemName: "heart").font(Font.body.weight(.medium))
                                }.accentColor(Color(hexString: course.color))
                            }
                        }
                    }
                }
                Section(header: Text("Community")) {
                    ForEach($courses.filter { communityGroup.contains($0.wrappedValue.id) }.sorted(by: {$0.wrappedValue.num < $1.wrappedValue.num })) { $course in
                        NavigationLink(destination: CourseSubview(course: $course, compassBlock: course.compassBlock, visibleRotations: course.visibleRotations, isFreePeriod: course.isFreePeriod, name: course.name, teacher: course.teacher, room: course.room, color: Color(hexString: course.color)), tag: course.id, selection: $selection) {
                            Label {
                                if course.name != course.id {
                                    HStack {
                                        Text(course.name)
                                        Spacer()
                                        Text(course.id).opacity(0.5)
                                    }
                                } else {
                                    Text(course.name)
                                }
                            } icon: {
                                Image(systemName: "person").font(Font.body.weight(.medium))
                            }.accentColor(Color(hexString: course.color))
                        }
                    }
                }
                Divider()
                NavigationLink(destination: SettingsView(clubMeetings: clubMeetings, clubs: clubsObject.clubs, sports: sportsObject.sports, sportGames: sportGames), tag: "Settings", selection: $selection) {
                    Label(
                        title: { Text("Settings") },
                        icon: { Image(systemName: "gear").font(Font.body.weight(.medium)) }
                    ).accentColor(Color("SystemContrast2"))
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Campus")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        toggleSidebar()
                    }, label: {
                        Image(systemName: "sidebar.left")
                            .font(.title2)
                            .foregroundStyle(Color("SystemToolbar"))
                    })
                }
            }
        }
        .accentColor(Color("AccentColor"))
        .sheet(isPresented: $setUp) {
            SetUpView()
                .environmentObject(authViewModel)
        }
        .onOpenURL { url in
            if url.absoluteString.contains("schedule") {
                selection = "Schedule"
            } else if url.absoluteString.contains("planner") {
                selection = "Planner"
            } else if url.absoluteString.contains("home") {
                selection = "Home"
            } else if url.absoluteString.contains("clubs") {
                selection = "Clubs"
            } else if url.absoluteString.contains("sports") {
                selection = "Sports"
            } else if url.absoluteString.contains("settings") {
                selection = "Settings"
            } else if url.absoluteString.contains("compass") {
                selection = "Compass"
            } else if url.absoluteString.contains("open") {
                selection = "Open"
            } else if url.absoluteString.contains("settings") {
                selection = "Settings"
            } else if url.absoluteString.contains("-Block") {
                selection = url.absoluteString.replacingOccurrences(of: "cpscampus://", with: "")
            }
        }
        .onAppear(perform: {
            //MARK: Google sign in restore session
            do {
                try Auth.auth().useUserAccessGroup("8W7N9822AZ.com.TheCollegePreparatorySchool.ScheduleApp")
            } catch let error as NSError {
                authLogger.error("error changing user access group > \(error, privacy: .public)")
            }
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
        .onChange(of: selection) { value in
            if ["Home","Clubs","Sports"].contains(value) {
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
        }
    }
}
