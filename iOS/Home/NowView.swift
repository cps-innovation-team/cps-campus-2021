//
//  NowView.swift
//  CPS Campus (iOS)
//
//  5/30/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import WidgetKit
import DynamicColor

struct NowView: View {
    
    //MARK: Course and Schedule Data
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let columns2 = [
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5)
    ]
    
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    
    var body: some View {
        VStack {
            TimelineView(.periodic(from: Date(), by: 1)) { context in
                if let classes = getNowBlockFromDate(date: context.date, blocks: scheduleBlocks, courses: courses, gradYear: gradYear) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2.55) {
                            Text("\(convertDatetoString(date: Date(), format: "EEE, MMM d"))")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .textCase(.uppercase)
                                .foregroundStyle(Color("AccentColor"))
                                .dynamicTypeSize(.small ... .medium)
                            Text("Your Classes")
                                .fontWeight(.bold)
                                .font(.system(size: 24))
                        }
                        Spacer()
                        if getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Date(), format: "M/d/yyyy")) }) != 0 {
                            Text("\(getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Date(), format: "M/d/yyyy")) }))")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .dynamicTypeSize(.small ... .medium)
                                .frame(width: 40, height: 40)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 5)
                    if classes.filter({ getCoursefromName(courseName: $0.name, courses: courses)?.id == "Common Classroom" }).isEmpty == false {
                        CommonClassroomView(color: Color(hexString: getCoursefromID(courseID: "Common Classroom", courses: courses).color))
                    }
                    if classes.count >= 2 && classes[0].startDate < context.date {
                        Group {
                            NowSegment(classes: classes, num: 0, first: true)
                            if let classesfiltered = Optional(classes.filter({ if $0.type == "PASSING" { return false } else { return true }})) {
                                if classesfiltered.count >= 2 && (classesfiltered[0] == classes[0]) && classesfiltered[0].endDate != classesfiltered[1].startDate && (Calendar.current.dateComponents([.minute], from: classesfiltered[0].endDate, to: classesfiltered[1].startDate).minute ?? 100) != 0 {
                                    HStack {
                                        Text("Passing Period")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color("SystemContrast"))
                                        Spacer()
                                        Text("\(Calendar.current.dateComponents([.minute], from: classesfiltered[0].endDate, to: classesfiltered[1].startDate).minute ?? 100) min")
                                            .fontWeight(.medium)
                                            .font(.system(.body, design: .rounded))
                                            .foregroundStyle(Color("SystemContrast2"))
                                    }
                                }
                            }
                            if let classesfiltered = Optional(classes.filter({ if $0.type == "PASSING" { return false } else { return true }})) {
                                if classesfiltered[0] == classes[1] {
                                    NowSegment(classes: classesfiltered, num: 0, first: false)
                                } else {
                                    NowSegment(classes: classesfiltered, num: 1, first: false)
                                }
                            }
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                    } else if classes[0].startDate > context.date {
                        HStack {
                            Text("No Classes")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("SystemContrast"))
                            Spacer()
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                        NowSegment(classes: classes, num: 0, first: false)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                    } else if classes.count == 1 && classes[0].startDate < context.date {
                        NowSegment(classes: classes, num: 0, first: true)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                        HStack {
                            Text("No Classes")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("SystemContrast"))
                            Spacer()
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                    }
                }
                else if let classes = getWidgetBlockTomorrow(size: WidgetFamily.systemLarge, blocks: scheduleBlocks, courses: courses, gradYear: gradYear) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2.55) {
                            Text("Tomorrow")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .textCase(.uppercase)
                                .foregroundStyle(Color("SystemContrast2"))
                                .dynamicTypeSize(.small ... .medium)
                            Text("Your Classes")
                                .fontWeight(.bold)
                                .font(.system(size: 24))
                        }
                        Spacer()
                        if getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), format: "M/d/yyyy")) }) != 0 {
                            Text("\(getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), format: "M/d/yyyy")) }))")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .dynamicTypeSize(.small ... .medium)
                                .frame(width: 40, height: 40)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 5)
                    if classes.filter({ getCoursefromName(courseName: $0.name, courses: courses)?.id == "Common Classroom" }).isEmpty == false {
                        CommonClassroomView(color: Color(hexString: getCoursefromID(courseID: "Common Classroom", courses: courses).color))
                    }
                    VStack(spacing: 0) {
                        LazyVGrid(columns: columns2, spacing: 5) {
                            ForEach(classes, id: \.self) { block in
                                VStack {
                                    Spacer()
                                    HStack {
                                        if block.freePeriod == true && block.type != "FREE" {
                                            Text("Free Period")
                                                .fontWeight(.semibold)
                                        } else if block.type != "FREE" {
                                            Text(block.name)
                                                .fontWeight(.semibold)
                                        } else {
                                            Text(block.name)
                                                .fontWeight(.semibold)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    Spacer()
                                }
                                .background(block.freePeriod == true ? Color(.systemGray6) : Color(colorScheme == .dark ? UIColor(block.color).shaded(amount: 0.15) : UIColor(block.color).tinted(amount: 0.15)))
                                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                            }
                        }
                    }
                    Button(action: {
                        let haptics = UIImpactFeedbackGenerator(style: .medium)
                        haptics.impactOccurred()
                        openURL(URL(string: "cpscampus://schedule/")!)
                    }, label: {
                        HStack {
                            Spacer()
                            Text("See Schedule")
                                .fontWeight(.semibold)
                            Spacer()
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                    })
                }
                else {
                    HStack {
                        VStack(alignment: .leading, spacing: 2.55) {
                            Text("\(convertDatetoString(date: Date(), format: "EEE, MMM d"))")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .textCase(.uppercase)
                                .foregroundStyle(Color("AccentColor"))
                                .dynamicTypeSize(.small ... .medium)
                            Text("Your Classes")
                                .fontWeight(.bold)
                                .font(.system(size: 24))
                        }
                        Spacer()
                        if getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Date(), format: "M/d/yyyy")) }) != 0 {
                            Text("\(getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Date(), format: "M/d/yyyy")) }))")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .dynamicTypeSize(.small ... .medium)
                                .frame(width: 40, height: 40)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 5)
                    Button(action: {
                        let haptics = UIImpactFeedbackGenerator(style: .medium)
                        haptics.impactOccurred()
                        openURL(URL(string: "cpscampus://schedule/")!)
                    }, label: {
                        HStack {
                            Spacer()
                            Text("See Schedule")
                                .fontWeight(.semibold)
                            Spacer()
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                    })
                }
            }
        }
    }
    
    struct NowSegment: View {
        @Environment(\.colorScheme) var colorScheme
        let classes: [NowClass]
        let num: Int
        let first: Bool
        
        var body: some View {
            VStack {
                TimelineView(.periodic(from: Date(), by: 1)) { context in
                    HStack {
                        VStack() {
                            Group {
                                HStack {
                                    if classes[num].freePeriod && classes[num].type != "FREE" && classes[num].type != "PASSING" {
                                        Text("Free Period")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color("SystemContrast"))
                                    } else {
                                        Text(classes[num].name)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color("SystemContrast"))
                                    }
                                    Spacer()
                                }
                                HStack {
                                    Text(classes[num].time.replacingOccurrences(of: " PM", with: "").replacingOccurrences(of: " AM", with: ""))
                                        .fontWeight(.medium)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(Color("SystemContrast2"))
                                    Spacer()
                                }
                            }
                            Group {
                                if classes[num].teacher != "" && classes[num].room != "" && classes[num].freePeriod == false {
                                    HStack {
                                        Text("\(classes[num].teacher) | \(classes[num].room)")
                                            .fontWeight(.medium)
                                            .font(.system(.body, design: .rounded))
                                            .foregroundStyle(Color("SystemContrast2"))
                                        Spacer()
                                    }
                                }
                                else if classes[num].teacher != "" && classes[num].freePeriod == false {
                                    HStack {
                                        Text(classes[num].teacher)
                                            .fontWeight(.medium)
                                            .font(.system(.body, design: .rounded))
                                            .foregroundStyle(Color("SystemContrast2"))
                                        Spacer()
                                    }
                                }
                                else if classes[num].room != "" && classes[num].freePeriod == false {
                                    HStack {
                                        Text(classes[num].room)
                                            .fontWeight(.medium)
                                            .font(.system(.body, design: .rounded))
                                            .foregroundStyle(Color("SystemContrast2"))
                                        Spacer()
                                    }
                                }
                            }
                        }
                        Spacer()
                        ZStack {
                            if classes[num].freePeriod {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundStyle(Color(.systemGray5))
                                    .frame(height: 50)
                            } else {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundStyle(Color(colorScheme == .dark ? UIColor(classes[num].color).shaded(amount: 0.15) : UIColor(classes[num].color).tinted(amount: 0.15)))
                                    .frame(height: 50)
                            }
                            if first {
                                Text(classes[num].endDate, style: .timer)
                                    .fontWeight(.medium)
                                    .font(.system(size: 16))
                                    .animation(nil)
                            } else {
                                Text(classes[num].startDate, style: .timer)
                                    .fontWeight(.medium)
                                    .font(.system(size: 16))
                                    .animation(nil)
                            }
                        }.frame(width: 100)
                    }
                    if first {
                        ProgressBar(date: context.date, classes: classes, num: num)
                    }
                }
            }
        }
        
        struct ProgressBar: View {
            @Environment(\.colorScheme) var colorScheme
            var date: Date
            let classes: [NowClass]
            let num: Int
            
            var body: some View {
                ZStack {
                    GeometryReader { geo in
                        HStack {
                            Capsule()
                                .frame(width: geo.size.width, height: 10)
                                .foregroundStyle(Color(.systemGray5))
                        }.clipShape(Capsule())
                        HStack {
                            Capsule()
                                .frame(width: geo.size.width*CGFloat((date.timeIntervalSince(classes[num].startDate)/(classes[num].endDate.timeIntervalSince(classes[num].startDate)))), height: 10)
                                .foregroundStyle(.clear)
                                .background(classes[num].freePeriod ? Color(.gray) : colorScheme == .dark ? Color(UIColor(classes[num].color).shaded(amount: 0.15)) : Color(UIColor(classes[num].color).tinted(amount: 0.15)))
                                .clipShape(Capsule())
                                .animation(.linear, value: date)
                            Spacer()
                        }.clipShape(Capsule())
                    }
                }
                .animation(.linear, value: date)
            }
        }
    }
}

struct CommonClassroomView: View {
    
    //Environment
    @Environment(\.openURL) var openURL
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var user = GIDSignIn.sharedInstance.currentUser
    @State var commonClassroom = CommonClassroom(title: nil, date: nil, room: nil, message: nil)
    
    let color: Color
    
    var body: some View {
        VStack {
            if (!(commonClassroom.title?.isEmpty ?? true) || !(commonClassroom.message?.isEmpty ?? true)) && authViewModel.state == .signedIn {
                VStack(spacing: 5) {
                    Button(action: {
                        openURL(URL(string: "https://cpscampus.org/cc")!)
                    }, label: {
                        VStack(spacing: 5) {
                            if !(commonClassroom.message?.isEmpty ?? true) {
                                HStack {
                                    Spacer()
                                    Text(commonClassroom.message ?? "")
                                        .foregroundStyle(Color("SystemContrast"))
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    Text((commonClassroom.title ?? ""))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color("SystemContrast"))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                HStack {
                                    Text("\(commonClassroom.room ?? "") @ 11:05 - 11:50")
                                        .fontWeight(.medium)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(Color("SystemContrast2"))
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(color.opacity(0.25)))
                    })
                }
            }
        }
        .onAppear {
            getUserCommonClassroom(userName: user?.profile?.name ?? "Unidentified", userEmail: user?.profile?.email ?? "Unidentified", completion: { value in
                if let wrappedValue = value {
                    commonClassroom = wrappedValue
                }
            })
        }
        .onChange(of: authViewModel.state) { _ in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if user != nil {
                    authViewModel.signIn()
                } else {
                    Auth.auth().signInAnonymously { authResult, error in
                        authLogger.log("anonymous auth")
                    }
                }
            }
            user = GIDSignIn.sharedInstance.currentUser
            getUserCommonClassroom(userName: user?.profile?.name ?? "Unidentified", userEmail: user?.profile?.email ?? "Unidentified", completion: { value in
                if let wrappedValue = value {
                    commonClassroom = wrappedValue
                }
            })
        }
    }
}
