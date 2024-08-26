//
//  SettingsView.swift
//  CPS Campus (iOS)
//
//  5/30/2021
//  Designed by Rahim Malik in California.
//

import SwiftUI
import Foundation
import GoogleSignIn
import UserNotifications
import FirebaseAuth

//MARK: - Profile View
struct ProfileView: View {
    
    //Authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    //Environment
    @Environment(\.horizontalSizeClass) var ipad
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var campusID: User?
    
    @State var pronouns = ""
    @State var socials = [Social]()
    @State var hideClasses = false
    @State var hideProfilePicture = false
    
    @State var showAlert = false
    
    //MARK: Data
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses: [Course] = defaultCourses
    @AppStorage("JoinedClubs", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var joinedClubs = [String: Bool]()
    @AppStorage("FollowedSports", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var followedSports = [String: Bool]()
    
    var body: some View {
        Form {
            if campusID != nil {
                Section(footer: Text("A **Campus ID** allows you to access all **clubs, directory, Common Classroom, RHF, and Palette Studio features.** This information will be visible on the in-app directory, to **only students and faculty.**")) {}
                Section(header: Text("**Profile**"), footer: Text("This information, including any pronouns you enter, will be visible to all **other students and faculty** on the app.")) {
                    HStack(spacing: 15) {
                        AsyncImage(url: URL(string: campusID!.imageLink)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                        VStack(spacing: 2) {
                            HStack {
                                Text(campusID!.name).bold()
                                    .foregroundStyle(Color("SystemContrast"))
                                    .font(.title3)
                                Spacer()
                            }
                            HStack {
                                Text(campusID!.id+"@college-prep.org")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer()
                            }
                        }
                        Spacer()
                    }.padding(.vertical, 5)
                    HStack {
                        Text("Graduation Year")
                        Spacer()
                        Text(campusID!.gradYear)
                    }
                    HStack {
                        Text("Pronouns")
                        Spacer()
                        TextField("pronouns", text: $pronouns, onCommit: {
                            updateCurrentUser(emailID: campusID!.id, user: User(id: campusID!.id, name: campusID!.name, gradYear: campusID!.gradYear, imageLink: campusID!.imageLink, pronouns: pronouns, socials: Dictionary(uniqueKeysWithValues: socials.map { ($0.key, $0.value) }), privacy: ["hideClasses": hideClasses, "hideProfilePicture": hideProfilePicture], clubs: campusID!.clubs, sports: campusID!.sports, tags: campusID!.tags))
                        })
                        .foregroundStyle(Color("AccentColor"))
                        .multilineTextAlignment(.trailing)
                    }
                }
                if gradYear != "Faculty" {
                    Section(header: Text("**Socials**"), footer: Text("Add any socials that **only students** can use to keep in touch with you. Swipe left to remove.")) {
                        ForEach($socials, id: \.key) { $social in
                            SocialsCell(key: social.key, value: $social.value, temporaryValue: social.value)
                                .padding(.vertical, 1)
                                .swipeActions {
                                    Button("Remove") {
                                        socials.removeAll(where: { $0.key == social.key })
                                    }
                                    .tint(.red)
                                }
                        }
                        Menu(content: {
                            ForEach(socialOptions, id: \.key) { social in
                                if !socials.contains(where: {$0.key == social.key}) {
                                    Button(action: {
                                        socials.append(social)
                                    }, label: {
                                        Text(social.key)
                                    })
                                }
                            }
                        }, label: {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.title3)
                                Text("Add Social")
                                Spacer()
                            }.padding(.all, 7)
                        })
                    }
                }
                Section(header: Text("**Privacy**"), footer: Text("Hide your profile picture and classes from **other students and faculty** at school.")) {
                    Toggle("Hide Profile Picture", isOn: $hideProfilePicture)
                        .onChange(of: hideProfilePicture) { _ in
                            updateCurrentUser(emailID: campusID!.id, user: User(id: campusID!.id, name: campusID!.name, gradYear: campusID!.gradYear, imageLink: campusID!.imageLink, pronouns: pronouns, socials: Dictionary(uniqueKeysWithValues: socials.map { ($0.key, $0.value) }), privacy: ["hideClasses": hideClasses, "hideProfilePicture": hideProfilePicture], clubs: campusID!.clubs, sports: campusID!.sports, tags: campusID!.tags))
                        }
                    Toggle("Hide Classes", isOn: $hideClasses)
                        .onChange(of: hideClasses) { _ in
                            updateCurrentUser(emailID: campusID!.id, user: User(id: campusID!.id, name: campusID!.name, gradYear: campusID!.gradYear, imageLink: campusID!.imageLink, pronouns: pronouns, socials: Dictionary(uniqueKeysWithValues: socials.map { ($0.key, $0.value) }), privacy: ["hideClasses": hideClasses, "hideProfilePicture": hideProfilePicture], clubs: campusID!.clubs, sports: campusID!.sports, tags: campusID!.tags))
                        }
                }
                Section() {
                    Button(action: {
                        authViewModel.signOut()
                        Auth.auth().signInAnonymously { authResult, error in
                            authLogger.log("anonymous auth")
                        }
                        campusID = nil
                    }, label: {
                        Text("Sign Out").foregroundStyle(.red)
                    })
                }
            } else {
                Button(action: {
                    authViewModel.signOut()
                    authViewModel.signIn()
                }, label: {
                    HStack {
                        Spacer()
                        VStack(alignment: .center, spacing: 15) {
                            Image("Campus")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                                        .stroke(colorScheme == .light ? .gray : .clear, lineWidth: 0.5)
                                )
                            Text("Campus ID")
                                .bold()
                                .foregroundStyle(Color("SystemContrast"))
                                .font(.title)
                            Text("Tap to sign in with your Campus ID and access all **clubs, directory, Common Classroom, RHF, and Palette Studio features.**")
                                .foregroundStyle(Color("SystemContrast2"))
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }.padding(.vertical, 10)
                })
            }
        }
        .navigationTitle(campusID == nil ? "Sign In" : "Campus ID")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Account"), message: Text("You must authenticate with a CPS Google Account registered to an attending student or teacher."), dismissButton: .default(Text("OK")))
        }
        .onChange(of: authViewModel.state) { _ in
            if let googleUser = GIDSignIn.sharedInstance.currentUser {
                fetchCurrentUser(emailID: googleUser.profile?.email ?? "NilEmail", completion: { currentUser in
                    if let currentUserWrapped = currentUser {
                        campusID = currentUserWrapped
                        let haptics = UINotificationFeedbackGenerator()
                        haptics.notificationOccurred(.success)
                    } else {
                        authViewModel.signOut()
                        showAlert = true
                        Auth.auth().signInAnonymously { authResult, error in
                            authLogger.log("anonymous auth")
                        }
                    }
                })
            }
        }
        .onChange(of: campusID) { _ in
            if let currentUserWrapped = campusID {
                gradYear = currentUserWrapped.gradYear
                pronouns = currentUserWrapped.pronouns ?? ""
                hideClasses = currentUserWrapped.privacy?["hideClasses"] ?? false
                hideProfilePicture = currentUserWrapped.privacy?["hideProfilePicture"] ?? false
                socials = currentUserWrapped.socials?.map { key, value in return(Social(key: key, value: value))} ?? [Social]()
                joinedClubs = currentUserWrapped.clubs ?? [String: Bool]()
                followedSports = currentUserWrapped.sports ?? [String: Bool]()
                fetchCourses(emailID: currentUserWrapped.id, completion: { courseData in
                    courses = courseData?.values.map({$0}).sorted(by: {$0.num < $1.num}) ?? courses.sorted(by: {$0.num < $1.num})
                })
            }
        }
        .onAppear {
            if let googleUser = GIDSignIn.sharedInstance.currentUser {
                fetchCurrentUser(emailID: googleUser.profile?.email ?? "NilEmail", completion: { currentUser in
                    if let currentUserWrapped = currentUser {
                        campusID = currentUserWrapped
                        pronouns = currentUserWrapped.pronouns ?? ""
                        hideClasses = currentUserWrapped.privacy?["hideClasses"] ?? false
                        hideProfilePicture = currentUserWrapped.privacy?["hideProfilePicture"] ?? false
                        socials = currentUserWrapped.socials?.map { key, value in return(Social(key: key, value: value))} ?? [Social]()
                    }
                })
            }
        }
        .onChange(of: socials) { _ in
            updateCurrentUser(emailID: campusID!.id, user: User(id: campusID!.id, name: campusID!.name, gradYear: campusID!.gradYear, imageLink: campusID!.imageLink, pronouns: pronouns, socials: Dictionary(uniqueKeysWithValues: socials.map { ($0.key, $0.value) }), privacy: ["hideClasses": hideClasses, "hideProfilePicture": hideProfilePicture], clubs: campusID!.clubs, sports: campusID!.sports, tags: campusID!.tags))
        }
        .onDisappear {
            if campusID != nil {
                updateCurrentUser(emailID: campusID!.id, user: User(id: campusID!.id, name: campusID!.name, gradYear: campusID!.gradYear, imageLink: campusID!.imageLink, pronouns: pronouns, socials: Dictionary(uniqueKeysWithValues: socials.map { ($0.key, $0.value) }), privacy: ["hideClasses": hideClasses, "hideProfilePicture": hideProfilePicture], clubs: campusID!.clubs, sports: campusID!.sports, tags: campusID!.tags))
            }
        }
    }
}

struct SocialsCell: View {
    let key: String
    @Binding var value: String
    @State var temporaryValue = ""
    @FocusState private var focused: Bool
    
    var body: some View {
        HStack {
            Text(key)
            Spacer()
            TextField(key.lowercased(), text: $temporaryValue, onCommit: {
                value = temporaryValue
            })
            .foregroundStyle(Color("AccentColor"))
            .multilineTextAlignment(.trailing)
            .disableAutocorrection(true)
            .focused($focused)
            .keyboardType(key == "Phone" ? .phonePad : .emailAddress)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if key == "Phone" {
                        Button(action: {
                            focused = false
                            value = temporaryValue
                        }, label: {
                            Text("Done").bold()
                        })
                    }
                }
            }
        }
    }
}

//MARK: - Notifications View
struct NotificationsView: View {
    
    //MARK: Course and Schedule Data
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("NotificationSettings", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var notificationSettings: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    
    @State var options: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    @State var classMinutes = 5.0
    @State var clubMinutes = 5.0
    @State var sportMinutes = 45.0
    @State var notificationsAllowed = true
    
    var body: some View {
        Form {
            if notificationsAllowed == false {
                Section(footer: Text("Campus requires permission to send notifications.")) {
                    Button(action: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }, label: {
                        Text("Update Permissions in Settings")
                    })
                }
            }
            Section(header: Text("**Classes**"), footer: Text("Get a configurable notification before your next class starts, when your current class ends, or both.")) {
                Toggle("When Class Starts", isOn: binding(for: "ClassStarts"))
                Toggle("When Class Ends", isOn: binding(for: "ClassEnds"))
                HStack {
                    Text("\(Int(classMinutes)) min before").foregroundStyle(Color("AccentColor"))
                    Spacer()
                    Stepper("Headstart", value: $classMinutes, in: 0...5)
                        .labelsHidden()
                }.disabled(options["ClassStarts"] == 0.0)
            }.disabled(!notificationsAllowed)
            Section(header: Text("**Clubs**"), footer: Text("Get a configurable notification before your meetings. You will only receive notifications from clubs you've joined.")) {
                Toggle("When Meeting Starts", isOn: binding(for: "ClubMeetingStarts"))
                HStack {
                    Text("\(Int(clubMinutes)) min before").foregroundStyle(Color("AccentColor"))
                    Spacer()
                    Stepper("Headstart", value: $clubMinutes, in: 0...5)
                        .labelsHidden()
                }.disabled(options["ClubMeetingStarts"] == 0.0)
            }.disabled(!notificationsAllowed)
            Section(header: Text("**Sports**"), footer: Text("Get a configurable notification before your sports games. You will only receive notifications from teams you've followed.")) {
                Toggle("Before Game Starts", isOn: binding(for: "SportGameStarts"))
                HStack {
                    if sportMinutes == 60 {
                        Text("1 hour before").foregroundStyle(Color("AccentColor"))
                    } else {
                        Text("\(Int(sportMinutes)) min before").foregroundStyle(Color("AccentColor"))
                    }
                    Spacer()
                    Stepper("Headstart", value: $sportMinutes, in: 0...60, step: 5)
                        .labelsHidden()
                }.disabled(options["SportGameStarts"] == 0.0)
            }.disabled(!notificationsAllowed)
        }
        .onChange(of: options, perform: { _ in
            notificationSettings = options
            notificationSettings["ClassMinutes"] = classMinutes
            notificationSettings["ClubMinutes"] = clubMinutes
            notificationSettings["SportMinutes"] = sportMinutes
        })
        .onChange(of: classMinutes, perform: { _ in
            notificationSettings["ClassMinutes"] = classMinutes
        })
        .onChange(of: clubMinutes, perform: { _ in
            notificationSettings["ClubMinutes"] = clubMinutes
        })
        .onChange(of: sportMinutes, perform: { _ in
            notificationSettings["SportMinutes"] = sportMinutes
        })
        .onAppear {
            classMinutes = notificationSettings["ClassMinutes"] ?? 5.0
            clubMinutes = notificationSettings["ClubMinutes"] ?? 5.0
            sportMinutes = notificationSettings["SportMinutes"] ?? 45.0
            options = notificationSettings
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    notificationsAllowed = false
                } else if settings.authorizationStatus == .denied {
                    notificationsAllowed = false
                } else if settings.authorizationStatus == .authorized {
                    notificationsAllowed = true
                }
            })
        }
        .onDisappear(perform: {
            generateAllNotifications(courses: courses, blocks: scheduleBlocks, notificationSettings: notificationSettings, gradYear: gradYear)
        })
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func binding(for key: String) -> Binding<Bool> {
        return Binding (get: {
            return self.options[key] == 1.0
        }, set: {
            if $0 {
                self.options[key] = 1.0
            } else {
                self.options[key] = 0.0
            }
        })
    }
}
