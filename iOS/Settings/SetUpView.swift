//
//  SetUpView.swift
//  CPS Campus (iOS)
//
//  7/15/2022
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct SetUpView: View {
    
    //MARK: Environment
    @Environment(\.presentationMode) var presentationMode
    @State var nextStepActive = false
    
    //MARK: Authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var showAlert = false
    
    //MARK: Campus ID
    @State var campusID: User? = nil
    @State var pronouns = ""
    @State var socials = [Social]()
    @State var hideClasses = false
    @State var hideProfilePicture = false
    
    //MARK: Preferences
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("SettingsBadge", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var settingsBadge = 0
    @AppStorage("EditCompassAlert", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var compassAlert = false
    
    //MARK: Data
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses: [Course] = defaultCourses
    @AppStorage("JoinedClubs", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var joinedClubs = [String: Bool]()
    @AppStorage("FollowedSports", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var followedSports = [String: Bool]()
    
    var body: some View {
        NavigationView {
            VStack() {
                if campusID != nil {
                    VStack(spacing: 15) {
                        Text("Campus ID")
                            .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .large)
                        Text("Every student and teacher at school has a Campus ID, even if they don't use Campus. All of your and their profile information is visible in the in-app directory, and you can control what you want to share with others.")
                            .foregroundStyle(Color("SystemContrast2"))
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .large)
                    }.padding().padding([.horizontal,.top])
                    NavigationLink(destination: NotificationSetUpView(), isActive: $nextStepActive, label: {
                        EmptyView()
                    }).frame(width: 0, height: 0)
                    Form {
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
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .onAppear {
                        if let googleUser = GIDSignIn.sharedInstance.currentUser {
                            fetchCurrentUser(emailID: googleUser.profile?.email ?? "NilEmail", completion: { currentUser in
                                if let currentUserWrapped = currentUser {
                                    gradYear = currentUserWrapped.gradYear
                                    if compassGradYears.contains(currentUserWrapped.gradYear) {
                                        compassAlert = true
                                        settingsBadge = 1
                                    }
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
                            })
                        }
                    }
                    .onChange(of: socials) { _ in
                        updateCurrentUser(emailID: campusID!.id, user: User(id: campusID!.id, name: campusID!.name, gradYear: campusID!.gradYear, imageLink: campusID!.imageLink, pronouns: pronouns, socials: Dictionary(uniqueKeysWithValues: socials.map { ($0.key, $0.value) }), privacy: ["hideClasses": hideClasses, "hideProfilePicture": hideProfilePicture], clubs: campusID!.clubs, sports: campusID!.sports, tags: campusID!.tags))
                    }
                    Button(action: {
                        updateCurrentUser(emailID: campusID!.id, user: User(id: campusID!.id, name: campusID!.name, gradYear: campusID!.gradYear, imageLink: campusID!.imageLink, pronouns: pronouns, socials: Dictionary(uniqueKeysWithValues: socials.map { ($0.key, $0.value) }), privacy: ["hideClasses": hideClasses, "hideProfilePicture": hideProfilePicture], clubs: campusID!.clubs, sports: campusID!.sports, tags: campusID!.tags))
                        nextStepActive = true
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .bold()
                                .foregroundStyle(.white)
                                .dynamicTypeSize(.small ... .large)
                            Spacer()
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("AccentColor")))
                    }).padding()
                } else {
                    VStack {
                        VStack(spacing: 15) {
                            Text("Authenticate")
                                .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
                                .dynamicTypeSize(.small ... .large)
                            Text("Sign in with your CPS Google Account to access all **clubs, directory, Common Classroom, RHF,** and **Palette Studio** features.\n\nIf you're a parent or want to sign in later, you can skip this step and still use all the **schedule** features.")
                                .foregroundStyle(Color("SystemContrast2"))
                                .multilineTextAlignment(.center)
                                .dynamicTypeSize(.small ... .large)
                        }.padding()
                        NavigationLink(destination: NotificationSetUpView(), isActive: $nextStepActive, label: {
                            EmptyView()
                        }).frame(width: 0, height: 0)
                        Spacer()
                        Button(action: {
                            authViewModel.signIn()
                            if let googleUser = GIDSignIn.sharedInstance.currentUser {
                                fetchCurrentUser(emailID: googleUser.profile?.email ?? "NilEmail", completion: { currentUser in
                                    if currentUser == nil {
                                        authViewModel.signOut()
                                        showAlert = true
                                        Auth.auth().signInAnonymously { authResult, error in
                                            authLogger.log("anonymous auth")
                                        }
                                    } else {
                                        campusID = currentUser
                                        let haptics = UINotificationFeedbackGenerator()
                                        haptics.notificationOccurred(.success)
                                    }
                                })
                            }
                        }, label: {
                            HStack {
                                Spacer()
                                Text("Sign in with Google")
                                    .bold()
                                    .foregroundStyle(.white)
                                    .dynamicTypeSize(.small ... .large)
                                Spacer()
                            }.padding()
                                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("AccentColor")))
                        })
                        .onChange(of: authViewModel.state) { _ in
                            if let googleUser = GIDSignIn.sharedInstance.currentUser {
                                fetchCurrentUser(emailID: googleUser.profile?.email ?? "NilEmail", completion: { currentUser in
                                    if currentUser == nil {
                                        authViewModel.signOut()
                                        showAlert = true
                                        Auth.auth().signInAnonymously { authResult, error in
                                            authLogger.log("anonymous auth")
                                        }
                                    } else {
                                        campusID = currentUser
                                        let haptics = UINotificationFeedbackGenerator()
                                        haptics.notificationOccurred(.success)
                                    }
                                })
                            }
                        }
                        Button(action: {
                            nextStepActive = true
                            Auth.auth().signInAnonymously { authResult, error in
                                authLogger.log("anonymous auth")
                            }
                        }, label: {
                            HStack {
                                Spacer()
                                Text("Skip")
                                    .bold()
                                    .foregroundStyle(Color("AccentColor"))
                                    .dynamicTypeSize(.small ... .large)
                                Spacer()
                            }
                            .padding()
                        })
                    }.padding()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Account"), message: Text("You must authenticate with a CPS Google Account registered to an attending student or teacher."), dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Step 1 of 3")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NotificationSetUpView: View {
    
    //MARK: Environment
    @Environment(\.presentationMode) var presentationMode
    @State var nextStepActive = false
    
    //MARK: Preferences
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("NotificationSettings", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var notificationSettings: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    
    @State var options: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    @State var classMinutes = 5.0
    @State var clubMinutes = 5.0
    @State var sportMinutes = 45.0
    @State var notificationsAllowed = true
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Notifications")
                    .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
                    .dynamicTypeSize(.small ... .large)
                Text("You can change these preferences later in the Settings tab, and join clubs and sports in the Clubs and Sports pages.")
                    .foregroundStyle(Color("SystemContrast2"))
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(.small ... .large)
            }.padding()
                .padding([.horizontal,.top])
            NavigationLink(destination: PaletteSetUpView(), isActive: $nextStepActive, label: {
                EmptyView()
            }).frame(width: 0, height: 0)
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
            .edgesIgnoringSafeArea(.bottom)
            Button(action: {
                notificationSettings["ClassMinutes"] = classMinutes
                notificationSettings["ClubMinutes"] = clubMinutes
                notificationSettings["SportMinutes"] = sportMinutes
                nextStepActive = true
            }, label: {
                HStack {
                    Spacer()
                    Text("Continue")
                        .bold()
                        .foregroundStyle(.white)
                        .dynamicTypeSize(.small ... .large)
                    Spacer()
                }.padding()
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("AccentColor")))
            }).padding()
        }
        .navigationTitle("Step 2 of 3")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: options, perform: { _ in
            notificationSettings = options
            notificationSettings["ClassMinutes"] = classMinutes
            notificationSettings["ClubMinutes"] = clubMinutes
            notificationSettings["SportMinutes"] = sportMinutes
        })
        .onAppear {
            classMinutes = 5.0
            clubMinutes = 5.0
            sportMinutes = 45.0
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
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                if success {
                    consoleLogger.log("notification access granted")
                    notificationsAllowed = true
                } else if let error = error {
                    consoleLogger.error("notification access error > \(error, privacy: .public)")
                }
            }
        }
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

struct PaletteSetUpView: View {
    
    //MARK: Environment
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    @StateObject var paletteObject = PaletteFetcher()
    
    //MARK: Authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses: [Course] = defaultCourses
    @State var temporaryCourses: [Course] = defaultCourses
    
    @AppStorage("SetUp", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var setUp = true
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Palettes")
                    .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
                    .dynamicTypeSize(.small ... .large)
                Text("Choose a palette to color your courses. Later, you can create your own palettes with Palette Studio or customize courses individually from the Settings tab.")
                    .foregroundStyle(Color("SystemContrast2"))
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(.small ... .large)
            }.padding()
                .padding([.horizontal,.top])
            ScrollView {
                VStack(spacing: 12.5) {
                    ForEach(defaultPalettes, id: \.self) { palette in
                        Button(action: {
                            let haptics = UIImpactFeedbackGenerator(style: .rigid)
                            haptics.impactOccurred()
                            temporaryCourses = courses.sorted(by: { $0.num < $1.num })
                            for temporaryCourse in temporaryCourses.sorted(by: { $0.num < $1.num }) {
                                if temporaryCourse.num >= 8 {
                                    temporaryCourses[temporaryCourse.num].color = palette.colorsHex[8]
                                } else {
                                    temporaryCourses[temporaryCourse.num].color = palette.colorsHex[temporaryCourse.num]
                                }
                            }
                            courses = temporaryCourses
                            openURL(URL(string: "cpscampus://schedule")!)
                            setUp = false
                        }, label: {
                            PaletteSubview(palette: palette, signedIn: true)
                        }).buttonStyle(ScaleButtonStyle())
                    }
                }.padding()
            }
        }.navigationTitle("Step 3 of 3")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if courses.map({$0.color}).removingDuplicates().sorted(by: {$0 < $1}) != defaultPalette.colorsHex.sorted(by: {$0 < $1}) {
                    setUp = false
                }
            }
    }
}
