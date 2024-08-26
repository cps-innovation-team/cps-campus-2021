//
//  ScheduleTableViews.swift
//  CPS Campus (iOS)
//
//  6/19/2022
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI

struct SchedulePage: View {
    
    //MARK: Course Data
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    
    //MARK: Environment
    @Environment(\.presentationMode) var presentationMode
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    @State var showHeader = true
    
    let blocks: [Block]
    @Binding var date: Date
    let inheritedDate: String
    let weekday: Int
    
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if showHeader {
                HStack {
                    scheduleDateHeader(weekday: weekday, date: date, inheritedDate: inheritedDate, compact: false)
                    Spacer()
                    scheduleRotationIndicator(weekday: weekday, date: date, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                }.padding(.bottom, 7)
            }
            GeometryReader { metric in
                VStack(spacing: metric.size.height*5/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) })) {
                    ForEach(blocks.filter { $0.dates.contains(inheritedDate) }, id: \.self) { block in
                        if block.type == "HOLIDAY" {
                            if blocks.filter({ $0.dates.contains(inheritedDate) }).count <= 1 {
                                DayBlock(name: block.title, image: Image("Geoffrey"), date: date, inheritedDate: inheritedDate, weekday: weekday)
                                    .frame(height: metric.size.height)
                                    .onAppear {
                                        showHeader = false
                                    }
                                    .onDisappear {
                                        showHeader = true
                                    }
                            }
                        } else if allAssignableCourses.contains(block.title) {
                            if checkCompass(compass: getCoursefromID(courseID: "Compass", courses: courses), gradYear: gradYear, block: block, blocks: blocks, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }), inheritedDate: inheritedDate) {
                                ScheduleBlock(course: getCoursefromID(courseID: "Compass", courses: courses), id: "Compass", startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                                    .frame(height: metric.size.height*CGFloat(basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm")))/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                            } else if block.title == "Advising" && checkAdvising(gradYear: gradYear, inheritedDate: inheritedDate, blocks: blocks) == false {
                                UniversalBlockStack(name: "Open", startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate)
                                    .frame(height: metric.size.height*CGFloat(basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm")))/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                            } else {
                                ScheduleBlock(course: getCoursefromID(courseID: block.title, courses: courses), id: block.title, startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                                    .frame(height: metric.size.height*CGFloat(basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm")))/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                            }
                        } else if block.type == "PASSING" {
                            Capsule()
                                .foregroundStyle(idiom == .pad ? Color(.systemGray4).opacity(0.5) : Color(.systemGray6))
                                .frame(height: metric.size.height*CGFloat(basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm")))/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                        } else if block.type == "FREE" {
                            UniversalBlock(name: block.title, startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate)
                                .frame(height: metric.size.height*CGFloat(basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm")))/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct ScheduleStack: View {
    
    //MARK: Course Data
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    
    //MARK: Environment
    @Environment(\.presentationMode) var presentationMode
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    @State var showHeader = true
    
    let blocks: [Block]
    @Binding var date: Date
    let inheritedDate: String
    let weekday: Int
    
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                scheduleDateHeader(weekday: weekday, date: date, inheritedDate: inheritedDate, compact: true)
                Spacer()
                scheduleRotationIndicator(weekday: weekday, date: date, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
            }.padding(.bottom, 7)
                .dynamicTypeSize(.small ... .small)
            GeometryReader { metric in
                VStack(spacing: metric.size.height*5/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) })) {
                    ForEach(blocks.filter { $0.dates.contains(inheritedDate) }, id: \.self) { block in
                        if block.type == "HOLIDAY" {
                            if blocks.filter({ $0.dates.contains(inheritedDate) }).count <= 1 {
                                DayBlockStack(name: block.title)
                                    .frame(height: metric.size.height)
                            }
                        } else if allAssignableCourses.contains(block.title) {
                            if checkCompass(compass: getCoursefromID(courseID: "Compass", courses: courses), gradYear: gradYear, block: block, blocks: blocks, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }), inheritedDate: inheritedDate) {
                                ScheduleBlockStack(course: getCoursefromID(courseID: "Compass", courses: courses), id: "Compass", startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                                    .frame(height: metric.size.height*CGFloat(basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm")))/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                            } else if block.title == "Advising" && checkAdvising(gradYear: gradYear, inheritedDate: inheritedDate, blocks: blocks) == false {
                                UniversalBlockStack(name: "Open", startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate)
                                    .frame(height: metric.size.height*CGFloat(basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm")))/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                            } else {
                                ScheduleBlockStack(course: getCoursefromID(courseID: block.title, courses: courses), id: block.title, startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                                    .frame(height: metric.size.height*CGFloat(basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm")))/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                            }
                        } else if block.type == "PASSING" {
                            Capsule()
                                .foregroundStyle(idiom == .pad ? Color(.systemGray4).opacity(0.5) : Color(.systemGray6))
                                .frame(height: metric.size.height*CGFloat(basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm")))/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                        } else if block.type == "FREE" {
                            UniversalBlockStack(name: block.title, startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate)
                                .frame(height: metric.size.height*CGFloat(basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm")))/getTotalGeoSize(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                        }
                    }
                }
            }
        }.padding(.vertical)
    }
}

//MARK: - Calendar Picker
struct CalendarPicker: View {
    
    //MARK: Course Data
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var blocks = [Block]()
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    
    @Binding var date: Date
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { value in
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        ForEach(months, id: \.name) { month in
                            Section(header: MonthHeader(text: month.name)) {
                                ForEach(month.weeksOfYear, id: \.self) { weekOfYear in
                                    HStack {
                                        ForEach([2,3,4,5,6], id: \.self) { weekday in
                                            DayCell(mainDate: $date, weekday: weekday, date: createAllDayDate(weekday: weekday, weekOfYear: weekOfYear, year: month.year), inheritedDate: convertDatetoString(date: createAllDayDate(weekday: weekday, weekOfYear: weekOfYear, year: month.year), format: "M/d/yyyy"), blocks: blocks, courses: courses)
                                                .frame(minHeight: 105)
                                        }
                                    }.padding(.horizontal)
                                }
                            }.id(month.name)
                        }
                        .onAppear {
                            withAnimation {
                                value.scrollTo(convertDatetoString(date: date, format: "MMMM"), anchor: .top)
                            }
                        }
                    }
                    Spacer().frame(height: 10)
                }
            }
        }
    }
    
    struct MonthHeader: View {
        
        let text: String
        
        var body: some View {
            HStack {
                Text(text)
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundStyle(Color("SystemContrast"))
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8.5, style: .continuous))
                Spacer()
            }.padding()
                .padding(.leading, 10)
        }
    }
    
    struct DayCell: View {
        
        var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
        
        @Binding var mainDate: Date
        let weekday: Int
        let date: Date
        let inheritedDate: String
        let blocks: [Block]
        let courses: [Course]
        
        var body: some View {
            Button(action: {
                mainDate = date
                let haptics = UIImpactFeedbackGenerator(style: .light)
                haptics.impactOccurred()
            }, label: {
                if date == mainDate || (Calendar.current.isDateInToday(mainDate) && Calendar.current.isDateInToday(date)) {
                    VStack {
                        ZStack {
                            Color(.secondarySystemFill)
                            VStack(spacing: 0) {
                                ForEach(blocks.filter { $0.dates.contains(inheritedDate) }, id: \.self) { block in
                                    if allAssignableCourses.contains(block.title) {
                                        if getCoursefromID(courseID: block.title, courses: courses).isFreePeriod {
                                            Color(.secondarySystemFill)
                                        } else {
                                            Color(hexString: getCoursefromID(courseID: block.title, courses: courses).color)
                                        }
                                    } else if block.type == "FREE" && block.title != "Lunch" {
                                        Color(.secondarySystemFill)
                                    }
                                }
                            }
                            if getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }) != 0 {
                                Text(String(getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) })))
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .frame(width: 35, height: 35)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        }
                        .opacity(opacityChecker(date: date) ? 0.5 : 1)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(Color("AccentColor"), lineWidth: 3)
                        )
                        if Calendar.current.isDateInToday(date) {
                            Text(dateHeaderPicker(date: date, weekday: weekday)).fontWeight(.medium).foregroundStyle(Color("AccentColor"))
                                .font(.system(size: 18, weight: .medium))
                        } else if date == mainDate {
                            Text(dateHeaderPicker(date: date, weekday: weekday)).fontWeight(.medium).foregroundStyle(Color("SystemContrast"))
                                .font(.system(size: 18, weight: .medium))
                        } else {
                            Text(dateHeaderPicker(date: date, weekday: weekday)).fontWeight(.medium).foregroundStyle(.gray)
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                } else {
                    VStack {
                        ZStack {
                            Color(.secondarySystemFill)
                            VStack(spacing: 0) {
                                ForEach(blocks.filter { $0.dates.contains(inheritedDate) }, id: \.self) { block in
                                    if allAssignableCourses.contains(block.title) {
                                        if getCoursefromID(courseID: block.title, courses: courses).isFreePeriod {
                                            Color(.secondarySystemFill)
                                        } else {
                                            Color(hexString: getCoursefromID(courseID: block.title, courses: courses).color)
                                        }
                                    } else if block.type == "FREE" && block.title != "Lunch" {
                                        Color(.secondarySystemFill)
                                    }
                                }
                            }
                            if getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }) != 0 {
                                Text(String(getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) })))
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .frame(width: 35, height: 35)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        }
                        .opacity(opacityChecker(date: date) ? 0.5 : 1)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        if Calendar.current.isDateInToday(date) {
                            Text(dateHeaderPicker(date: date, weekday: weekday)).fontWeight(.medium).foregroundStyle(Color("AccentColor"))
                                .font(.system(size: 18, weight: .medium))
                        } else if date == mainDate {
                            Text(dateHeaderPicker(date: date, weekday: weekday)).fontWeight(.medium).foregroundStyle(Color("SystemContrast"))
                                .font(.system(size: 18, weight: .medium))
                        } else {
                            Text(dateHeaderPicker(date: date, weekday: weekday)).fontWeight(.medium).foregroundStyle(.gray)
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                }
            })
            .buttonStyle(ScaleButtonStyle())
        }
        
        func opacityChecker(date: Date) -> Bool {
            if Calendar.current.isDateInToday(date) {
                return false
            } else {
                return date < Date()
            }
        }
    }
    
    func getWeekforWeekofMonth(weekNumber: Int, weekday: Int, month: Int, year: Int) -> Date {
        var components = Calendar.current.dateComponents([.weekOfMonth, .month, .year], from: Date())
        components.month = month
        components.weekday = weekday
        components.weekOfMonth = weekNumber
        components.year = year
        return Calendar.current.date(from: components) ?? Date()
    }
}
