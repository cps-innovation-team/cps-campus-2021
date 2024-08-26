//
//  SetUpView.swift
//  CPS Campus (macOS)
//
//  7/15/2022
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import UserNotifications

struct SetUpView: View {
    
    //MARK: Environment
    @Environment(\.presentationMode) var presentationMode
    @State var presentationOverride = false
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
        VStack {
            Text("Step 1 of 3")
                .font(.title3).fontWeight(.semibold).multilineTextAlignment(.center)
            if campusID != nil {
                VStack(spacing: 15) {
                    Text("Campus ID")
                        .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
                    Text("Every student and teacher at school has a Campus ID, even if they don't use Campus. All of your and their profile information is visible in the in-app directory, and you can control what you want to share with others.")
                        .foregroundStyle(Color("SystemContrast2"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.padding()
                ScrollView(showsIndicators: false) {
                    VStack {
                        HStack {
                            Text("PROFILE").fontWeight(.medium).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.leading)
                        VStack(spacing: 0) {
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
                                            .font(.system(size: 18))
                                        Spacer()
                                    }
                                    HStack {
                                        Text(campusID!.id+"@college-prep.org")
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .font(.system(size: 15))
                                        Spacer()
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    authViewModel.signOut()
                                    Auth.auth().signInAnonymously { authResult, error in
                                        authLogger.log("anonymous auth")
                                    }
                                    campusID = nil
                                }, label: {
                                    Text("Sign out of Campus").foregroundStyle(.red)
                                })
                            }
                            .padding(.bottom)
                            Divider()
                            HStack {
                                Text("Graduation Year")
                                    .font(.system(size: 15))
                                Spacer()
                                Text(campusID!.gradYear)
                                    .font(.system(size: 15))
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.vertical)
                            Divider()
                            HStack {
                                Text("Pronouns")
                                    .font(.system(size: 15))
                                Spacer()
                                TextField("pronouns", text: $pronouns, onCommit: {
                                    updateCurrentUser(emailID: campusID!.id, user: User(id: campusID!.id, name: campusID!.name, gradYear: campusID!.gradYear, imageLink: campusID!.imageLink, pronouns: pronouns, socials: Dictionary(uniqueKeysWithValues: socials.map { ($0.key, $0.value) }), privacy: ["hideClasses": hideClasses, "hideProfilePicture": hideProfilePicture], clubs: campusID!.clubs, sports: campusID!.sports, tags: campusID!.tags))
                                })
                                .font(.system(size: 15))
                                .foregroundStyle(Color("AccentColor"))
                                .frame(width: 100)
                                .textFieldStyle(.plain)
                                .multilineTextAlignment(.trailing)
                            }
                            .padding(.top)
                        }.borderedCellStyle()
                        HStack {
                            Text("This information, including any pronouns you enter, will be visible to all **other students and faculty** on the app.").foregroundStyle(.gray)
                            Spacer()
                        }.padding([.leading, .bottom])
                    }
                    if gradYear != "Faculty" {
                        VStack {
                            HStack {
                                Text("SOCIALS").fontWeight(.medium).foregroundStyle(.gray)
                                Spacer()
                            }.padding(.leading)
                            VStack(spacing: 0) {
                                ForEach($socials, id: \.key) { $social in
                                    HStack {
                                        SocialsCell(key: social.key, value: $social.value, temporaryValue: social.value)
                                        Button(action: {
                                            socials.removeAll(where: { $0.key == social.key })
                                        }, label: {
                                            Text("Remove").foregroundStyle(.red)
                                        }).padding(.leading)
                                    }
                                    Divider().padding(.vertical)
                                }
                                HStack {
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
                                                .foregroundStyle(Color("AccentColor"))
                                            Text("Add Social")
                                        }
                                    }).frame(maxWidth: 150)
                                    Spacer()
                                }
                            }.borderedCellStyle()
                            HStack {
                                Text("Add any socials that **only students** can use to keep in touch with you. Hit ENTER after you finish typing to save.").foregroundStyle(.gray)
                                Spacer()
                            }.padding([.leading, .bottom])
                        }
                    }
                    VStack {
                        HStack {
                            Text("PRIVACY").fontWeight(.medium).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.leading)
                        VStack(spacing: 0) {
                            HStack {
                                Text("Hide Profile Picture")
                                    .font(.system(size: 15))
                                Spacer()
                                Toggle("Hide Profile Picture", isOn: $hideProfilePicture)
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                                    .onChange(of: hideClasses) { _ in
                                        updateCurrentUser(emailID: campusID!.id, user: User(id: campusID!.id, name: campusID!.name, gradYear: campusID!.gradYear, imageLink: campusID!.imageLink, pronouns: pronouns, socials: Dictionary(uniqueKeysWithValues: socials.map { ($0.key, $0.value) }), privacy: ["hideClasses": hideClasses, "hideProfilePicture": hideProfilePicture], clubs: campusID!.clubs, sports: campusID!.sports, tags: campusID!.tags))
                                    }
                            }
                            .padding(.bottom)
                            Divider()
                            HStack {
                                Text("Hide Classes")
                                    .font(.system(size: 15))
                                Spacer()
                                Toggle("Hide Classes", isOn: $hideClasses)
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                                    .onChange(of: hideClasses) { _ in
                                        updateCurrentUser(emailID: campusID!.id, user: User(id: campusID!.id, name: campusID!.name, gradYear: campusID!.gradYear, imageLink: campusID!.imageLink, pronouns: pronouns, socials: Dictionary(uniqueKeysWithValues: socials.map { ($0.key, $0.value) }), privacy: ["hideClasses": hideClasses, "hideProfilePicture": hideProfilePicture], clubs: campusID!.clubs, sports: campusID!.sports, tags: campusID!.tags))
                                    }
                            }
                            .padding(.top)
                        }.borderedCellStyle()
                        HStack {
                            Text("Hide your profile picture and classes from **other students and faculty** at school.").foregroundStyle(.gray)
                            Spacer()
                        }.padding([.leading, .bottom])
                    }
                }
                .onAppear {
                    if let googleUser = GIDSignIn.sharedInstance.currentUser {
                        fetchCurrentUser(emailID: googleUser.profile?.email ?? "NilEmail", completion: { currentUser in
                            if let currentUserWrapped = currentUser {
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
                        Spacer()
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("AccentColor")))
                }).buttonStyle(ScaleButtonStyle())
            } else {
                VStack(spacing: 15) {
                    Text("Authenticate")
                        .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
                    Text("Sign in with your CPS Google Account to access all **clubs, directory, Common Classroom, RHF,** and **Palette Studio** features.\n\nIf you're a parent or want to sign in later, you can skip this step and still use all the **schedule** features.")
                        .foregroundStyle(Color("SystemContrast2"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }.padding()
                Spacer()
                Button(action: {
                    do {
                        try Auth.auth().useUserAccessGroup("8W7N9822AZ.com.TheCollegePreparatorySchool.ScheduleApp")
                    } catch let error as NSError {
                        authLogger.error("error changing user access group > \(error, privacy: .public)")
                    }
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
                            }
                        })
                    }
                }, label: {
                    HStack {
                        Spacer()
                        Text("Sign in with Google")
                            .bold()
                            .foregroundStyle(.white)
                        Spacer()
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("AccentColor")))
                })
                .buttonStyle(ScaleButtonStyle())
                .onChange(of: authViewModel.state) { _ in
                    do {
                        try Auth.auth().useUserAccessGroup("8W7N9822AZ.com.TheCollegePreparatorySchool.ScheduleApp")
                    } catch let error as NSError {
                        authLogger.error("error changing user access group > \(error, privacy: .public)")
                    }
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
                            }
                        })
                    }
                }
                Button(action: {
                    nextStepActive = true
                }, label: {
                    HStack {
                        Spacer()
                        Text("Skip")
                            .bold()
                            .foregroundStyle(Color("AccentColor"))
                        Spacer()
                    }
                    .padding()
                })
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding()
        .padding()
        .frame(width: 600, height: 600)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Account"), message: Text("You must authenticate with a CPS Google Account registered to an attending student or teacher."), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $nextStepActive) {
            NotificationSetUpView(presentationOverride: $presentationOverride)
        }
        .onChange(of: presentationOverride) { _ in
            if presentationOverride {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct NotificationSetUpView: View {
    
    //MARK: Environment
    @Environment(\.presentationMode) var presentationMode
    @Binding var presentationOverride: Bool
    @Environment(\.openURL) var openURL
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
            Text("Step 2 of 3")
                .font(.title3).fontWeight(.semibold).multilineTextAlignment(.center)
                .padding(.horizontal)
            VStack(spacing: 15) {
                Text("Notifications")
                    .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
                Text("You can change these preferences later in the Settings tab, and follow clubs and sports in the Clubs and Sports pages.")
                    .foregroundStyle(Color("SystemContrast2"))
                    .multilineTextAlignment(.center)
            }.padding()
                .padding(.horizontal)
            ScrollView {
                VStack(spacing: 15) {
                    if notificationsAllowed == false {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                                .font(.system(size: 20))
                                .frame(width: 25, height: 25)
                                .padding(.trailing, 5)
                            Text("Campus requires permission to send notifications.")
                            Spacer()
                            Button(action: {
                                openURL(URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!)
                            }, label: {
                                Text("System Preferences")
                            })
                        }.padding()
                            .background(Rectangle().foregroundStyle(.yellow.opacity(0.25)))
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .padding(.vertical)
                    }
                    VStack {
                        HStack {
                            Text("**CLASSES**").font(.caption).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.leading)
                        VStack(alignment: .leading) {
                            HStack {
                                Toggle("When Class Starts", isOn: binding(for: "ClassStarts"))
                                    .labelsHidden()
                                Text("When Class Starts").font(.system(size: 15))
                            }
                            HStack {
                                Toggle("When Class Ends", isOn: binding(for: "ClassEnds"))
                                    .labelsHidden()
                                Text("When Class Ends").font(.system(size: 15))
                            }
                            HStack {
                                Slider(
                                    value: $classMinutes,
                                    in: 0...5,
                                    step: 1, minimumValueLabel: Text("0 min").font(.system(size: 15)), maximumValueLabel: Text("5 min").font(.system(size: 15)), label: {
                                        Text("\(Int(classMinutes)) min before")
                                            .foregroundStyle(Color("AccentColor"))
                                            .font(.system(size: 15))
                                            .frame(width: 100)
                                    })
                            }.disabled(options["ClassStarts"] == 0.0)
                        }.disabled(!notificationsAllowed)
                            .borderedCellStyle()
                        HStack {
                            Text("Get a configurable notification before your next class starts, when your current class ends, or both.").font(.caption).foregroundStyle(.gray)
                            Spacer()
                        }.padding([.leading, .bottom])
                    }
                    VStack {
                        HStack {
                            Text("**CLUBS**").font(.caption).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.leading)
                        VStack(alignment: .leading) {
                            HStack {
                                Toggle("When Meeting Starts", isOn: binding(for: "ClubMeetingStarts"))
                                    .labelsHidden()
                                Text("When Meeting Starts").font(.system(size: 15))
                            }
                            HStack {
                                Slider(
                                    value: $clubMinutes,
                                    in: 0...5,
                                    step: 1, minimumValueLabel: Text("0 min").font(.system(size: 15)), maximumValueLabel: Text("5 min").font(.system(size: 15)), label: {
                                        Text("\(Int(clubMinutes)) min before")
                                            .foregroundStyle(Color("AccentColor"))
                                            .font(.system(size: 15))
                                            .frame(width: 100)
                                    })
                            }.disabled(options["ClubMeetingStarts"] == 0.0)
                        }.disabled(!notificationsAllowed)
                            .borderedCellStyle()
                        HStack {
                            Text("Get a configurable notification before your meetings. You will only receive notifications from clubs you've joined.").font(.caption).foregroundStyle(.gray)
                            Spacer()
                        }.padding([.leading, .bottom])
                    }
                    VStack {
                        HStack {
                            Text("**SPORTS**").font(.caption).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.leading)
                        VStack(alignment: .leading) {
                            HStack {
                                Toggle("Before Game Starts", isOn: binding(for: "SportGameStarts"))
                                    .labelsHidden()
                                Text("Before Game Starts").font(.system(size: 15))
                            }
                            HStack {
                                Slider(
                                    value: $sportMinutes,
                                    in: 0...60, step: 5, minimumValueLabel: Text("0 min").font(.system(size: 15)), maximumValueLabel: Text("1 hour").font(.system(size: 15)), label: {
                                        if sportMinutes == 60 {
                                            Text("1 hour before")
                                                .foregroundStyle(Color("AccentColor"))
                                                .font(.system(size: 15))
                                                .frame(width: 100)
                                        } else {
                                            Text("\(Int(sportMinutes)) min before")
                                                .foregroundStyle(Color("AccentColor"))
                                                .font(.system(size: 15))
                                                .frame(width: 100)
                                        }
                                    })
                            }.disabled(options["SportGameStarts"] == 0.0)
                        }.disabled(!notificationsAllowed)
                            .borderedCellStyle()
                        HStack {
                            Text("Get a configurable notification before your sports games. You will only receive notifications from teams you've followed.").font(.caption).foregroundStyle(.gray)
                            Spacer()
                        }.padding([.leading, .bottom])
                        Spacer()
                    }
                }.padding(.horizontal)
            }
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
                    Spacer()
                }.padding()
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("AccentColor")))
            }).padding()
                .buttonStyle(ScaleButtonStyle())
        }
        .padding()
        .frame(width: 600, height: 600)
        .onChange(of: presentationOverride) { _ in
            if presentationOverride {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .sheet(isPresented: $nextStepActive) {
            PaletteSetUpView(presentationOverride: $presentationOverride)
        }
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
    @Binding var presentationOverride: Bool
    @Environment(\.openURL) var openURL
    
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses: [Course] = defaultCourses
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var paletteObject = PaletteFetcher()
    @State var temporaryCourses: [Course] = defaultCourses
    
    var body: some View {
        VStack {
            Text("Step 3 of 3")
                .font(.title3).fontWeight(.semibold).multilineTextAlignment(.center)
                .padding(.horizontal)
            VStack(spacing: 15) {
                Text("Palettes")
                    .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
                Text("Choose a palette to color your courses. Later, you create your own palettes with Palette Studio or customize courses individually from the Settings tab.")
                    .foregroundStyle(Color("SystemContrast2"))
                    .multilineTextAlignment(.center)
            }.padding()
                .padding(.horizontal)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(defaultPalettes, id: \.self) { palette in
                        Button(action: {
                            temporaryCourses = courses.sorted(by: { $0.num < $1.num })
                            for temporaryCourse in temporaryCourses.sorted(by: { $0.num < $1.num }) {
                                if temporaryCourse.num >= 8 {
                                    temporaryCourses[temporaryCourse.num].color = palette.colorsHex[8]
                                } else {
                                    temporaryCourses[temporaryCourse.num].color = palette.colorsHex[temporaryCourse.num]
                                }
                            }
                            courses = temporaryCourses
                            presentationOverride = true
                        }, label: {
                            PaletteSubview(palette: palette, signedIn: true)
                        }).buttonStyle(ScaleButtonStyle())
                    }
                }.padding(.horizontal)
            }
        }
        .padding(.vertical)
        .frame(width: 600, height: 600)
        .onChange(of: presentationOverride) { _ in
            if presentationOverride {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            if courses.map({$0.color}).removingDuplicates().sorted(by: {$0 < $1}) != defaultPalette.colorsHex.sorted(by: {$0 < $1}) {
                presentationOverride = true
            }
        }
    }
}
