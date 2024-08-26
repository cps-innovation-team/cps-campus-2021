//
//  SettingsView.swift
//  CPS Campus (macOS)
//
//  5/30/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import UserNotifications
import GoogleSignIn
import FirebaseAuth

struct SettingsView: View {
    
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    
    let clubMeetings: [ClubMeeting]
    let clubs: [Club]
    let sports: [Sport]
    let sportGames: [SportGame]
    
    @SceneStorage("SettingsSelection") var selection: String = "campusID"
    
    var body: some View {
        VStack {
            switch selection {
            case "campusID":
                ProfileView()
            case "notifications":
                NotificationsView()
            case "palettes":
                PaletteView()
            default:
                EmptyView()
            }
        }
        .frame(minWidth: 750)
        .background(Color("SystemWindow"))
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Settings", selection: $selection) {
                    Text("Campus ID").tag("campusID")
                    Text("Notifications").tag("notifications")
                    Text("Palettes").tag("palettes")
                }.pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(minWidth: 300)
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

struct ProfileView: View {
    
    //Authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    //Environment
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @State var campusID: User? = nil
    
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
        ScrollView {
            VStack(spacing: 15) {
                if campusID != nil {
                    HStack {
                        Text("A **Campus ID** allows you to access all **clubs, directory, Common Classroom, RHF, and Palette Studio features.** This information will be visible on the in-app directory, to **only students and faculty.**").foregroundStyle(.gray)
                        Spacer()
                    }.padding()
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
                                    Text("Sign Out").foregroundStyle(.red)
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
                                Text("A **Campus ID** allows you to access all **clubs, directory, Common Classroom, RHF, and Palette Studio features.** This information will be visible on the in-app directory, to **only students and faculty.**")
                                    .foregroundStyle(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }.padding(.vertical, 10)
                    }).buttonStyle(.borderless)
                        .borderedCellStyle()
                }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Account"), message: Text("You must authenticate with a CPS Google Account registered to an attending student or teacher."), dismissButton: .default(Text("OK")))
            }
            .onChange(of: authViewModel.state) { _ in
                if let googleUser = GIDSignIn.sharedInstance.currentUser {
                    fetchCurrentUser(emailID: googleUser.profile?.email ?? "NilEmail", completion: { currentUser in
                        if let currentUserWrapped = currentUser {
                            campusID = currentUserWrapped
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
}

struct SocialsCell: View {
    let key: String
    @Binding var value: String
    @State var temporaryValue = ""
    
    var body: some View {
        HStack {
            Text(key)
                .font(.system(size: 15))
            Spacer()
            TextField(key.lowercased(), text: $temporaryValue, onCommit: {
                value = temporaryValue
            })
            .font(.system(size: 15))
            .textFieldStyle(.plain)
            .foregroundStyle(Color("AccentColor"))
            .multilineTextAlignment(.trailing)
            .disableAutocorrection(true)
        }
    }
}

struct NotificationsView: View {
    
    @Environment(\.openURL) var openURL
    
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
                            .font(.system(size: 15))
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
                        Text("CLASSES").fontWeight(.medium).foregroundStyle(.gray)
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
                        Text("Get a configurable notification before your next class starts, when your current class ends, or both.").foregroundStyle(.gray)
                        Spacer()
                    }.padding([.leading, .bottom])
                }
                VStack {
                    HStack {
                        Text("CLUBS").fontWeight(.medium).foregroundStyle(.gray)
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
                        Text("Get a configurable notification before your meetings. You will only receive notifications from clubs you've joined.").foregroundStyle(.gray)
                        Spacer()
                    }.padding([.leading, .bottom])
                }
                VStack {
                    HStack {
                        Text("SPORTS").fontWeight(.medium).foregroundStyle(.gray)
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
                        Text("Get a configurable notification before your sports games. You will only receive notifications from teams you've followed.").foregroundStyle(.gray)
                        Spacer()
                    }.padding([.leading, .bottom])
                }
            }
            .padding()
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
            .onDisappear {
                generateAllNotifications(courses: courses, blocks: scheduleBlocks, notificationSettings: notificationSettings, gradYear: gradYear)
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
