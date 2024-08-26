//
//  NowView.swift
//  CPS Campus (macOS)
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
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(convertDatetoString(date: Date(), format: "EEE, MMM d"))")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .textCase(.uppercase)
                                .foregroundStyle(Color("AccentColor"))
                            Text("Your Classes")
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                                .foregroundStyle(Color("SystemContrast"))
                        }
                        Spacer()
                        if getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Date(), format: "M/d/yyyy")) }) != 0 {
                            Text("\(getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Date(), format: "M/d/yyyy")) }))")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .frame(width: 35, height: 35)
                                .background(Color("SystemGray3").opacity(0.25))
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
                                            .font(.system(size: 15))
                                            .foregroundStyle(Color("SystemContrast"))
                                        Spacer()
                                        Text("\(Calendar.current.dateComponents([.minute], from: classesfiltered[0].endDate, to: classesfiltered[1].startDate).minute ?? 100) min")
                                            .fontWeight(.medium)
                                            .font(.system(size: 15, design: .rounded))
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
                        }.borderedCellStyle()
                    } else if classes[0].startDate > context.date {
                        HStack {
                            Text("No Classes")
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("SystemContrast"))
                            Spacer()
                        }.borderedCellStyle()
                        NowSegment(classes: classes, num: 0, first: false)
                            .borderedCellStyle()
                    } else if classes.count == 1 && classes[0].startDate < context.date {
                        NowSegment(classes: classes, num: 0, first: true)
                            .borderedCellStyle()
                        HStack {
                            Text("No Classes")
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("SystemContrast"))
                            Spacer()
                        }.borderedCellStyle()
                    }
                }
                else if let classes = getWidgetBlockTomorrow(size: WidgetFamily.systemLarge, blocks: scheduleBlocks, courses: courses, gradYear: gradYear) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Tomorrow")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .textCase(.uppercase)
                                .foregroundStyle(Color("SystemContrast2"))
                            Text("Your Classes")
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                                .foregroundStyle(Color("SystemContrast"))
                        }
                        Spacer()
                        if getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), format: "M/d/yyyy")) }) != 0 {
                            Text("\(getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), format: "M/d/yyyy")) }))")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .frame(width: 35, height: 35)
                                .background(Color("SystemGray3").opacity(0.25))
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
                                                .font(.system(size: 15))
                                        } else if block.type != "FREE" {
                                            Text(block.name)
                                                .fontWeight(.semibold)
                                                .font(.system(size: 15))
                                        } else {
                                            Text(block.name)
                                                .fontWeight(.semibold)
                                                .font(.system(size: 15))
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    Spacer()
                                }
                                .background(block.freePeriod == true ? Color("SystemGray3").opacity(0.25) : Color(colorScheme == .dark ? NSColor(block.color).shaded(amount: 0.15) : NSColor(block.color).tinted(amount: 0.15)))
                                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                            }
                        }
                    }
                    Button(action: {
                        openURL(URL(string: "cpscampus://schedule/")!)
                    }, label: {
                        HStack {
                            Spacer()
                            Text("See Schedule")
                                .fontWeight(.medium)
                                .font(.system(size: 15))
                                .foregroundStyle(Color("AccentColor"))
                            Spacer()
                        }.borderedCellStyle()
                    }).buttonStyle(.plain)
                }
                else {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(convertDatetoString(date: Date(), format: "EEE, MMM d"))")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .textCase(.uppercase)
                                .foregroundStyle(Color("AccentColor"))
                            Text("Your Classes")
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                                .foregroundStyle(Color("SystemContrast"))
                        }
                        Spacer()
                        if getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Date(), format: "M/d/yyyy")) }) != 0 {
                            Text("\(getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Date(), format: "M/d/yyyy")) }))")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .frame(width: 35, height: 35)
                                .background(Color("SystemGray3").opacity(0.25))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 5)
                    Button(action: {
                        openURL(URL(string: "cpscampus://schedule/")!)
                    }, label: {
                        HStack {
                            Spacer()
                            Text("See Schedule")
                                .fontWeight(.medium)
                                .font(.system(size: 15))
                                .foregroundStyle(Color("AccentColor"))
                            Spacer()
                        }.borderedCellStyle()
                    }).buttonStyle(.plain)
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
                                            .font(.system(size: 15))
                                            .foregroundStyle(Color("SystemContrast"))
                                    } else {
                                        Text(classes[num].name)
                                            .fontWeight(.semibold)
                                            .font(.system(size: 15))
                                            .foregroundStyle(Color("SystemContrast"))
                                    }
                                    Spacer()
                                }
                                HStack {
                                    Text(classes[num].time.replacingOccurrences(of: " PM", with: "").replacingOccurrences(of: " AM", with: ""))
                                        .fontWeight(.medium)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundStyle(Color("SystemContrast2"))
                                    Spacer()
                                }
                            }
                            Group {
                                if classes[num].teacher != "" && classes[num].room != "" && classes[num].freePeriod == false {
                                    HStack {
                                        Text("\(classes[num].teacher) | \(classes[num].room)")
                                            .fontWeight(.medium)
                                            .font(.system(size: 15, design: .rounded))
                                            .foregroundStyle(Color("SystemContrast2"))
                                        Spacer()
                                    }
                                }
                                else if classes[num].teacher != "" && classes[num].freePeriod == false {
                                    HStack {
                                        Text(classes[num].teacher)
                                            .fontWeight(.medium)
                                            .font(.system(size: 15, design: .rounded))
                                            .foregroundStyle(Color("SystemContrast2"))
                                        Spacer()
                                    }
                                }
                                else if classes[num].room != "" && classes[num].freePeriod == false {
                                    HStack {
                                        Text(classes[num].room)
                                            .fontWeight(.medium)
                                            .font(.system(size: 15, design: .rounded))
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
                                    .foregroundStyle(Color("SystemGray2").opacity(0.25))
                                    .frame(height: 50)
                            } else {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundStyle(Color(colorScheme == .dark ? NSColor(classes[num].color).shaded(amount: 0.15) : NSColor(classes[num].color).tinted(amount: 0.15)))
                                    .frame(height: 50)
                            }
                            if first {
                                Text(classes[num].endDate, style: .timer)
                                    .fontWeight(.medium)
                                    .font(.system(size: 15))
                                    .animation(nil)
                            } else {
                                Text(classes[num].startDate, style: .timer)
                                    .fontWeight(.medium)
                                    .font(.system(size: 15))
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
                                .foregroundStyle(Color("SystemGray2").opacity(0.25))
                        }.clipShape(Capsule())
                        HStack {
                            Capsule()
                                .frame(width: geo.size.width*CGFloat((date.timeIntervalSince(classes[num].startDate)/(classes[num].endDate.timeIntervalSince(classes[num].startDate)))), height: 10)
                                .foregroundStyle(.clear)
                                .background(classes[num].freePeriod ? Color(.gray) : colorScheme == .dark ? Color(NSColor(classes[num].color).shaded(amount: 0.15)) : Color(NSColor(classes[num].color).tinted(amount: 0.15)))
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
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color("SystemContrast"))
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    Text((commonClassroom.title ?? ""))
                                        .fontWeight(.semibold)
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color("SystemContrast"))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                HStack {
                                    Text("\(commonClassroom.room ?? "") @ 11:05 - 11:50")
                                        .fontWeight(.medium)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundStyle(Color("SystemContrast2"))
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(color.opacity(0.25)))
                    }).buttonStyle(.plain)
                        .fixedSize(horizontal: false, vertical: true)
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
