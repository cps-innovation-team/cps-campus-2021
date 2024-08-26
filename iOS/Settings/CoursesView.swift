//
//  CoursesView.swift
//  CPS Campus (iOS)
//
//  4/23/2021
//  Designed by Rahim Malik in California.
//

import SwiftUI
import WidgetKit
import GoogleSignIn

struct CoursesView: View {
    
    //MARK: Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    @State var selection: String? = ""
    
    //MARK: Authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var campusID: User? = nil
    
    //MARK: Course Data
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    
    //MARK: Settings
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("NotificationSettings", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var notificationSettings: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    
    @AppStorage("SettingsBadge", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var settingsBadge = 0
    @AppStorage("EditCompassAlert", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var compassAlert = false
    
    var body: some View {
        NavigationView {
            ScrollViewReader { value in
                List {
                    Section {
                        NavigationLink(destination: ProfileView(campusID: $campusID), tag: "campusID", selection: $selection) {
                            if campusID != nil {
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
                                                .foregroundStyle(Color(.gray))
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            } else {
                                HStack(spacing: 15) {
                                    ZStack {
                                        Image("Campus")
                                            .resizable()
                                            .frame(width: 55, height: 55)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(colorScheme == .light ? .gray : .clear, lineWidth: 0.5)
                                            )
                                    }
                                    VStack(spacing: 2) {
                                        HStack {
                                            Text("Sign In").bold()
                                                .foregroundStyle(Color("SystemContrast"))
                                                .font(.title3)
                                            Spacer()
                                        }
                                        HStack {
                                            Text("Campus ID")
                                                .foregroundStyle(Color(.gray))
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .id("profile")
                    if compassGradYears.contains(gradYear) && compassAlert {
                        if let compass = getOptionalCoursefromID(courseID: "Compass", courses: courses) {
                            Section {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(Color(hexString: compass.color))
                                        .font(.system(size: 20))
                                        .frame(width: 25, height: 25)
                                        .padding(.trailing, 5)
                                    Text("**\(compass.name)** will be displayed during **\(compass.compassBlock)** on **Day \(compass.visibleRotations)**")
                                        .padding(.vertical, 6)
                                }.fixedSize(horizontal: false, vertical: true)
                                Button(action: {
                                    compassAlert = false
                                    settingsBadge = boolArraytoTrueCount(array: [compassAlert])
                                    openURL(URL(string: "cpscampus://settings/compass")!)
                                }, label: {
                                    Text("Change block and rotation")
                                })
                            }
                        }
                    }
                    Section(header: Text("**General**")) {
                        NavigationLink(destination: NotificationsView(), tag: "notifications", selection: $selection) {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                    .foregroundStyle(Color("AccentColor"))
                                    .font(.system(size: 20))
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 5)
                                Text("Notifications")
                                    .foregroundStyle(Color("SystemContrast"))
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }.id("notifications")
                        NavigationLink(destination: PaletteView(negativePadding: -15), tag: "palettes", selection: $selection) {
                            HStack {
                                Image("swatchpalette.fill")
                                    .foregroundStyle(Color("AccentColor"))
                                    .font(.system(size: 20))
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 5)
                                Text("Palette Studio")
                                    .foregroundStyle(Color("SystemContrast"))
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }.id("palettes")
                    }
                    Section(header: Text("**Classes**")) {
                        ForEach($courses.sorted(by: {$0.wrappedValue.num < $1.wrappedValue.num })) { $course in
                            if coursesGroup.contains(course.id) {
                                NavigationLink(destination: CourseSubview(course: $course, compassBlock: course.compassBlock, visibleRotations: course.visibleRotations, isFreePeriod: course.isFreePeriod, name: course.name, teacher: course.teacher, room: course.room, color: Color(hexString: course.color)), tag: course.id.lowercased(), selection: $selection) {
                                    HStack {
                                        Image(systemName: "book.closed.fill")
                                            .foregroundStyle(course.isFreePeriod ? Color("SystemContrast2"): Color(hexString: course.color))
                                            .font(.system(size: 20))
                                            .frame(width: 25, height: 25)
                                            .padding(.trailing, 5)
                                        VStack(alignment: .leading) {
                                            if course.isFreePeriod {
                                                Text("Free Period").foregroundStyle(Color("SystemContrast"))
                                            } else {
                                                Text(course.name)
                                                    .foregroundStyle(Color("SystemContrast"))
                                                    .multilineTextAlignment(.leading)
                                                if course.teacher != "" && course.room != "" {
                                                    Text("\(course.teacher) | \(course.room)")
                                                        .foregroundStyle(Color("SystemContrast"))
                                                        .opacity(0.5)
                                                        .multilineTextAlignment(.leading)
                                                } else if course.teacher != "" {
                                                    Text(course.teacher)
                                                        .foregroundStyle(Color("SystemContrast"))
                                                        .opacity(0.5)
                                                        .multilineTextAlignment(.leading)
                                                } else if course.room != "" {
                                                    Text(course.room)
                                                        .foregroundStyle(Color("SystemContrast"))
                                                        .opacity(0.5)
                                                        .multilineTextAlignment(.leading)
                                                }
                                            }
                                        }
                                        Spacer()
                                        HStack(spacing: 4) {
                                            if course.name != course.id {
                                                Text(course.id)
                                                    .foregroundStyle(.gray)
                                            }
                                            if course.visibleRotations != 0 {
                                                Image(systemName: "\(course.visibleRotations).circle").foregroundStyle(.gray)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 6)
                                }
                                .id(course.id.lowercased())
                            } else if course.id == "Compass" && compassGradYears.contains(gradYear) {
                                NavigationLink(destination: CourseSubview(course: $course, compassBlock: course.compassBlock, visibleRotations: course.visibleRotations, isFreePeriod: course.isFreePeriod, name: course.name, teacher: course.teacher, room: course.room, color: Color(hexString: course.color)), tag: "compass", selection: $selection) {
                                    HStack {
                                        Image(systemName: "heart.fill")
                                            .foregroundStyle(Color(hexString: course.color))
                                            .font(.system(size: 20))
                                            .frame(width: 25, height: 25)
                                            .padding(.trailing, 5)
                                        VStack(alignment: .leading) {
                                            Text(course.name)
                                                .foregroundStyle(Color("SystemContrast"))
                                                .multilineTextAlignment(.leading)
                                            if course.teacher != "" && course.room != "" {
                                                Text("\(course.teacher) | \(course.room)")
                                                    .foregroundStyle(Color("SystemContrast"))
                                                    .opacity(0.5)
                                                    .multilineTextAlignment(.leading)
                                            } else if course.teacher != "" {
                                                Text(course.teacher)
                                                    .foregroundStyle(Color("SystemContrast"))
                                                    .opacity(0.5)
                                                    .multilineTextAlignment(.leading)
                                            } else if course.room != "" {
                                                Text(course.room)
                                                    .foregroundStyle(Color("SystemContrast"))
                                                    .opacity(0.5)
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 6)
                                }
                                .id("compass")
                            }
                        }
                    }
                    Section(header: Text("**Community**")) {
                        ForEach($courses.filter { communityGroup.contains($0.wrappedValue.id) }.sorted(by: {$0.wrappedValue.num < $1.wrappedValue.num })) { $course in
                            NavigationLink(destination: CourseSubview(course: $course, compassBlock: course.compassBlock, visibleRotations: course.visibleRotations, isFreePeriod: course.isFreePeriod, name: course.name, teacher: course.teacher, room: course.room, color: Color(hexString: course.color)), tag: course.id.lowercased(), selection: $selection) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(Color(hexString: course.color))
                                        .font(.system(size: 20))
                                        .frame(width: 25, height: 25)
                                        .padding(.trailing, 5)
                                    VStack(alignment: .leading) {
                                        Text(course.name)
                                            .foregroundStyle(Color("SystemContrast"))
                                            .multilineTextAlignment(.leading)
                                        if course.teacher != "" && course.room != "" {
                                            Text("\(course.teacher) | \(course.room)")
                                                .foregroundStyle(Color("SystemContrast"))
                                                .opacity(0.5)
                                                .multilineTextAlignment(.leading)
                                        } else if course.teacher != "" {
                                            Text(course.teacher)
                                                .foregroundStyle(Color("SystemContrast"))
                                                .opacity(0.5)
                                                .multilineTextAlignment(.leading)
                                        } else if course.room != "" {
                                            Text(course.room)
                                                .foregroundStyle(Color("SystemContrast"))
                                                .opacity(0.5)
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                    Spacer()
                                    if course.name != course.id {
                                        Text(course.id)
                                            .foregroundStyle(Color("SystemContrast"))
                                            .opacity(0.5)
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                            .id(course.id.lowercased())
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Settings")
                .onChange(of: gradYear) { _ in
                    if !compassGradYears.contains(gradYear) {
                        compassAlert = false
                        settingsBadge = boolArraytoTrueCount(array: [compassAlert])
                    } else {
                        compassAlert = true
                        settingsBadge = boolArraytoTrueCount(array: [compassAlert])
                    }
                }
                .onAppear {
                    settingsBadge = boolArraytoTrueCount(array: [compassAlert])
                    GIDSignIn.sharedInstance.restorePreviousSignIn { googleUser, error in
                        if googleUser != nil {
                            authViewModel.signIn()
                            fetchCurrentUser(emailID: googleUser?.profile?.email ?? "NilEmail", completion: { currentUser in
                                campusID = currentUser
                            })
                        }
                    }
                }
                .onOpenURL { url in
                    if url.absoluteString.contains("campusID") {
                        selection = "campusID"
                    } else if url.absoluteString.contains("palettes") {
                        selection = "palettes"
                    } else if url.absoluteString.contains("notifications") {
                        selection = "notifications"
                    } else if url.absoluteString.contains("compass") {
                        value.scrollTo("compass")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            selection = "compass"
                            let haptics = UIImpactFeedbackGenerator(style: .medium)
                            haptics.impactOccurred()
                        }
                    } else if allAssignableCourses.contains(url.absoluteString.replacingOccurrences(of: "cpscampus://settings/", with: "")) {
                        value.scrollTo(url.absoluteString.replacingOccurrences(of: "cpscampus://settings/", with: "").lowercased())
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            selection = url.absoluteString.replacingOccurrences(of: "cpscampus://settings/", with: "").lowercased()
                            let haptics = UIImpactFeedbackGenerator(style: .medium)
                            haptics.impactOccurred()
                        }
                    }
                }
            }
        }
    }
}

struct CourseSubview: View {
    
    //MARK: Course and Schedule Data
    @Binding var course: Course
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    
    //MARK: Environment
    @Environment(\.openURL) private var openURL
    
    @State var compassBlock: String
    @State var visibleRotations: Int
    @State var isFreePeriod: Bool
    
    @State var name: String
    @State var teacher: String
    @State var room: String
    @State var color: Color
    
    //MARK: Settings
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("NotificationSettings", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var notificationSettings: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    if isFreePeriod {
                        TextField("Name", text: .constant("Free Period")).foregroundStyle(Color(.gray)).font(Font.largeTitle.weight(.bold))
                            .minimumScaleFactor(0.5)
                            .disabled(true)
                        Spacer()
                        Text("**UNTOGGLE TO EDIT**").foregroundColor(.gray).font(.caption2)
                    } else {
                        TextField("Name", text: $name, onCommit: {
                            course.name = name
                        })
                        .font(Font.largeTitle.weight(.bold))
                        .minimumScaleFactor(0.5)
                        Spacer()
                        Text("**TAP NAME TO EDIT**").foregroundColor(.gray).font(.caption2)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .listRowInsets(EdgeInsets())
                .background(Color(.systemGroupedBackground))
                Section {
                    if noTeachers.contains(course.id) == false {
                        HStack {
                            if course.id == "Advising" {
                                HStack {
                                    TextField("Advisor", text: $teacher, onCommit: {
                                        course.teacher = teacher
                                    })
                                }
                            } else {
                                HStack {
                                    TextField("Teacher", text: $teacher, onCommit: {
                                        course.teacher = teacher
                                    })
                                    .opacity(isFreePeriod ? 0.5 : 1)
                                }
                            }
                        }.disabled(isFreePeriod)
                    }
                    if noRooms.contains(course.id) == false {
                        HStack {
                            TextField("Room", text: $room, onCommit: {
                                course.room = room
                            })
                            .opacity(isFreePeriod ? 0.5 : 1)
                        }.disabled(isFreePeriod)
                    }
                }
                if coursesGroup.contains(course.id) {
                    Section(header: Text("**Display**"), footer: Text("Configure for which rotations **\(name)** will be displayed. All other rotations will be displayed as a **Free Period**.")) {
                        if noFreePeriods.contains(course.id) == false {
                            Toggle("Always Free Period", isOn: $isFreePeriod)
                            HStack {
                                Text("Rotations")
                                Spacer()
                                Picker(String(visibleRotations), selection: $visibleRotations) {
                                    Text("All Rotations").tag(0)
                                    if rotation1and3Group.contains(course.id) {
                                        Text("Day 1").tag(1)
                                        Text("Day 3").tag(3)
                                    } else {
                                        Text("Day 2").tag(2)
                                        Text("Day 4").tag(4)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                        }
                    }
                    if compassGradYears.contains(gradYear) {
                        if let compass = getOptionalCoursefromID(courseID: "Compass", courses: courses) {
                            if compass.compassBlock == compassBlock && compass.visibleRotations == visibleRotations {
                                Section {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(.yellow)
                                            .font(.system(size: 20))
                                            .frame(width: 25, height: 25)
                                            .padding(.trailing, 5)
                                        Text("**\(compass.name)** is currently using this block and rotation so **\(name)** will never be displayed")
                                    }.padding(.vertical, 10)
                                    Button(action: {
                                        openURL(URL(string: "cpscampus://settings/compass")!)
                                    }, label: {
                                        Text("Edit **\(compass.name)**")
                                    })
                                }
                            } else if compass.compassBlock == compassBlock {
                                Section {
                                    HStack {
                                        Image(systemName: "heart.fill")
                                            .foregroundStyle(Color(hexString: compass.color))
                                            .font(.system(size: 20))
                                            .frame(width: 25, height: 25)
                                            .padding(.trailing, 5)
                                        if isFreePeriod {
                                            Text("**\(compass.name)** will be displayed instead of **Free Period** on **Day \(compass.visibleRotations)**")
                                        } else {
                                            Text("**\(compass.name)** will be displayed instead of **\(name)** on **Day \(compass.visibleRotations)**")
                                        }
                                    }.padding(.vertical, 10)
                                    Button(action: {
                                        openURL(URL(string: "cpscampus://settings/compass")!)
                                    }, label: {
                                        Text("Edit **\(compass.name)**")
                                    })
                                }
                            }
                        }
                    }
                } else if course.id == "Compass" {
                    Section(header: Text("**Display**"), footer: Text("Configure for which block and rotation **\(name)** will be displayed. All other rotations will be displayed as your **\(compassBlock)** course, **\(getCoursefromID(courseID: compassBlock, courses: courses).name)**.")) {
                        HStack {
                            Text("Block").opacity(0.5)
                            Spacer()
                            Picker(compassBlock, selection: $compassBlock) {
                                ForEach(coursesGroup, id: \.self) { courseID in
                                    Text(courseID)
                                        .tag(courseID)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        HStack {
                            Text("Rotation").opacity(0.5)
                            Spacer()
                            Picker(String(visibleRotations), selection: $visibleRotations) {
                                Text("Day 1").tag(1)
                                Text("Day 2").tag(2)
                                Text("Day 3").tag(3)
                                Text("Day 4").tag(4)
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }
                    if rotation1and3Group.contains(compassBlock) && [2,4].contains(visibleRotations) {
                        Section {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.system(size: 20))
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 5)
                                Text("**\(compassBlock)** occurs on **Day 1 and Day 3** not **Day \(visibleRotations)**")
                            }.padding(.vertical, 10)
                        }
                    } else if rotation2and4Group.contains(compassBlock) && [1,3].contains(visibleRotations) {
                        Section {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.system(size: 20))
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 5)
                                Text("**\(compassBlock)** occurs on **Day 2 and Day 4** not **Day \(visibleRotations)**")
                            }.padding(.vertical, 10)
                        }
                    } else {
                        if getCoursefromID(courseID: compassBlock, courses: courses).compassBlock == compassBlock && getCoursefromID(courseID: compassBlock, courses: courses).visibleRotations == visibleRotations {
                            Section {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.system(size: 20))
                                        .frame(width: 25, height: 25)
                                        .padding(.trailing, 5)
                                    Text("**\(name)** will override your **\(compassBlock)** course on **Day \(visibleRotations)** so **\(getCoursefromID(courseID: compassBlock, courses: courses).name)** will never be displayed")
                                }.padding(.vertical, 10)
                                Button(action: {
                                    openURL(URL(string: "cpscampus://settings/\(compassBlock)")!)
                                }, label: {
                                    Text("Edit **\(getCoursefromID(courseID: compassBlock, courses: courses).name)**")
                                })
                            }
                        } else {
                            Section {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(Color(hexString: getCoursefromID(courseID: "Compass", courses: courses).color))
                                        .font(.system(size: 20))
                                        .frame(width: 25, height: 25)
                                        .padding(.trailing, 5)
                                    if getCoursefromID(courseID: compassBlock, courses: courses).isFreePeriod {
                                        Text("**\(name)** will be displayed instead of **Free Period** on **Day \(visibleRotations)**")
                                    } else {
                                        Text("**\(name)** will be displayed instead of **\(getCoursefromID(courseID: compassBlock, courses: courses).name)** on **Day \(visibleRotations)**")
                                    }
                                }.padding(.vertical, 10)
                                Button(action: {
                                    openURL(URL(string: "cpscampus://settings/\(compassBlock)")!)
                                }, label: {
                                    Text("Edit **\(getCoursefromID(courseID: compassBlock, courses: courses).name)**")
                                })
                            }
                        }
                    }
                }
                if course.id == "Advising" && gradYear != freshClass {
                    Section {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(Color(hexString: getCoursefromID(courseID: "Advising", courses: courses).color))
                                .font(.system(size: 20))
                                .frame(width: 25, height: 25)
                                .padding(.trailing, 5)
                            Text("**Open** will be displayed on Thursdays when you have free time instead of **Advising**")
                        }.padding(.vertical, 10)
                        if gradYear == "Faculty" {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.system(size: 20))
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 5)
                                Text("If you lead a CAP group, you will meet every week during **Advising**")
                            }.padding(.vertical, 10)
                        }
                    }
                } else if course.id == "X-Block" {
                    Section {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(Color(hexString: getCoursefromID(courseID: "X-Block", courses: courses).color))
                                .font(.system(size: 20))
                                .frame(width: 25, height: 25)
                                .padding(.trailing, 5)
                            Text("**Open** will be displayed on Mondays when you have free time instead of **X-Block**")
                        }.padding(.vertical, 10)
                    }
                }
                Section(header: Text("**Style**")) {
                    if isFreePeriod {
                        ColorPicker("Color", selection: .constant(Color(.gray)), supportsOpacity: false)
                            .buttonStyle(.plain)
                            .opacity(0.5)
                            .disabled(true)
                    } else {
                        ColorPicker("Color", selection: $color, supportsOpacity: false)
                            .buttonStyle(.plain)
                    }
                    Button(action: {
                        openURL(URL(string: "cpscampus://settings/palettes")!)
                    }, label: {
                        Text("Palette Studio")
                    })
                }
            }
            .navigationTitle(course.id)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear(perform: {
            course.name = name
            course.teacher = teacher
            course.room = room
            course.color = UIColor(color).toHexString()
            generateAllNotifications(courses: courses, blocks: scheduleBlocks, notificationSettings: notificationSettings, gradYear: gradYear)
        })
        .onChange(of: compassBlock) { _ in
            course.compassBlock = compassBlock
        }
        .onChange(of: visibleRotations) { _ in
            if visibleRotations != 0 {
                isFreePeriod = false
            }
            course.visibleRotations = visibleRotations
        }
        .onChange(of: isFreePeriod, perform: { _ in
            if isFreePeriod {
                visibleRotations = 0
            }
            course.isFreePeriod = isFreePeriod
        })
    }
}
