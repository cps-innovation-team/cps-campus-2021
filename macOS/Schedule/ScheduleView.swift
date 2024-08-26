//
//  ScheduleView.swift
//  CPS Campus (macOS)
//
//  5/15/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI

struct ScheduleViewmacOS: View {
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    
    @SceneStorage("date") var date = Date()
    @State var weekday = Calendar.current.component(.weekday, from: Date())
    @State var month = Calendar.current.component(.month, from: Date())
    @State var year = Calendar.current.component(.year, from: Date())
    
    //MARK: Course and Schedule Data
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    
    //MARK: Preferences
    @AppStorage("ShowDatePicker", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var showDatePicker = true
    
    //MARK: Display Constants
    let weekwidth = CGFloat(125)
    
    var body: some View {
        HSplitView {
            HStack(spacing: 10) {
                ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 2, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 2)
                ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 3, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 3)
                ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 4, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 4)
                ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 5, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 5)
                ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 6, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 6)
                
            }.padding(.horizontal)
                .layoutPriority(1)
                .frame(minWidth: 550)
            if showDatePicker {
                CalendarPicker(date: $date)
                    .frame(minWidth: 350)
            }
        }
        .onChange(of: date, perform: { _ in
            weekday = Calendar.current.component(.weekday, from: date)
            month = Calendar.current.component(.month, from: date)
            year = Calendar.current.component(.year, from: date)
        })
        .navigationTitle("Schedule")
        .toolbar {
            ToolbarItem(id: "Previous Week", placement: .primaryAction, showsByDefault: true) {
                Button(action: {
                    var dateComponent = DateComponents()
                    dateComponent.weekOfYear = -1
                    date = Calendar.current.date(byAdding: dateComponent, to: date) ?? date
                }) {
                    Image(systemName: "chevron.left").foregroundStyle(Color("SystemToolbar"))
                }
                .keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [])
                .help("Previous Week")
            }
            ToolbarItem(id: "Today", placement: .primaryAction, showsByDefault: true) {
                Button(action: {
                    date = Date()
                }, label: {
                    Text("Today").foregroundStyle(Color("SystemToolbar"))
                })
                .keyboardShortcut(KeyEquivalent("t"), modifiers: [.command])
                .help("⌘T")
            }
            ToolbarItem(id: "Next Week", placement: .primaryAction, showsByDefault: true) {
                Button(action: {
                    var dateComponent = DateComponents()
                    dateComponent.weekOfYear = 1
                    date = Calendar.current.date(byAdding: dateComponent, to: date) ?? date
                }) {
                    Image(systemName: "chevron.right").foregroundStyle(Color("SystemToolbar"))
                }
                .keyboardShortcut(KeyEquivalent.rightArrow, modifiers: [])
                .help("Next Week")
            }
            ToolbarItem(id: "Date Picker", placement: .primaryAction, showsByDefault: true) {
                Button(action: {
                    self.showDatePicker.toggle()
                }) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color("AccentColor"))
                }
                .keyboardShortcut(KeyEquivalent("d"), modifiers: [.command])
                .help("Date Picker")
            }
            ToolbarItem(id: "Export", placement: .primaryAction, showsByDefault: true) {
                if #available(macOS 13.0, *) {
                    Menu {
                        Button("Export as Portrait PDF") {
                            savePDF(portrait: true)
                        }
                        Button("Export as Landscape PDF") {
                            savePDF(portrait: false)
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .background(Color("SystemWindow"))
    }
    
    @available(macOS 13.0, *)
    @MainActor func render(portrait: Bool) -> URL {
        
        let url = URL.documentsDirectory.appending(path: "2023-2024 CPS Planner.pdf")
        var box = CGRect(x: 0, y: 0, width: portrait ? 612 : 792, height: portrait ? 792 : 612)
        guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
            return url
        }
        
        var dates = [Date]()
        for month in months {
            for weekOfYear in month.weeksOfYear {
                dates.append(createAllDayDate(weekday: 2, weekOfYear: weekOfYear, year: month.year))
            }
        }
        
        for date in dates {
            pdf.beginPDFPage(nil)
            if portrait {
                let renderer1 = ImageRenderer(content: ScheduleExport(date: date, portrait: true, portraitSection: 1))
                renderer1.render { size, context in
                    context(pdf)
                }
                pdf.endPDFPage()
                pdf.beginPDFPage(nil)
                let renderer2 = ImageRenderer(content: ScheduleExport(date: date, portrait: true, portraitSection: 2))
                renderer2.render { size, context in
                    context(pdf)
                }
                pdf.endPDFPage()
            } else {
                let renderer = ImageRenderer(content: ScheduleExport(date: date, portrait: false, portraitSection: 0))
                renderer.render { size, context in
                    context(pdf)
                }
                pdf.endPDFPage()
            }
        }
        
        pdf.closePDF()
        return url
    }
    
    @available(macOS 13.0, *)
    @MainActor func savePDF(portrait: Bool) {
        let url = render(portrait: portrait)
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "2023-2024 CPS Planner.pdf"
        panel.allowedContentTypes = [.pdf]
        
        panel.begin { response in
            if response == .OK, let saveURL = panel.url {
                do {
                    try FileManager.default.copyItem(at: url, to: saveURL)
                } catch {
                    consoleLogger.error("pdf save error > \(error, privacy: .public)")
                }
            }
        }
    }
}

//MARK: - Schedule Date Picker
struct CalendarPicker: View {
    
    //MARK: Course Data
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var blocks = [Block]()
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    
    @Binding var date: Date
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: true) {
                ScrollViewReader { value in
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        ForEach(months, id: \.name) { month in
                            Section(header: MonthHeader(text: month.name)) {
                                ForEach(month.weeksOfYear, id: \.self) { weekOfYear in
                                    HStack {
                                        ForEach([2,3,4,5,6], id: \.self) { weekday in
                                            DayCell(mainDate: $date, weekday: weekday, date: createAllDayDate(weekday: weekday, weekOfYear: weekOfYear, year: month.year), inheritedDate: convertDatetoString(date: createAllDayDate(weekday: weekday, weekOfYear: weekOfYear, year: month.year), format: "M/d/yyyy"), blocks: blocks, courses: courses)
                                                .frame(minHeight: 100)
                                        }
                                    }.padding(.horizontal)
                                }
                            }.id(month.name)
                        }
                    }
                    .onAppear {
                        withAnimation {
                            value.scrollTo(convertDatetoString(date: date, format: "MMMM"), anchor: .top)
                        }
                    }
                    Spacer().frame(height: 15)
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
        
        @Binding var mainDate: Date
        let weekday: Int
        let date: Date
        let inheritedDate: String
        let blocks: [Block]
        let courses: [Course]
        
        var body: some View {
            Button(action: {
                mainDate = date
            }, label: {
                if date == mainDate || (Calendar.current.isDateInToday(mainDate) && Calendar.current.isDateInToday(date)) {
                    VStack {
                        ZStack {
                            Color("SystemGray2").opacity(0.25)
                            VStack(spacing: 0) {
                                ForEach(blocks.filter { $0.dates.contains(inheritedDate) }, id: \.self) { block in
                                    if allAssignableCourses.contains(block.title) {
                                        if getCoursefromID(courseID: block.title, courses: courses).isFreePeriod {
                                            Color("SystemGray2").opacity(0.25)
                                        } else {
                                            Color(hexString: getCoursefromID(courseID: block.title, courses: courses).color)
                                        }
                                    } else if block.type == "FREE" && block.title != "Lunch" {
                                        Color("SystemGray2").opacity(0.25)
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
                                .stroke(Color.accentColor, lineWidth: 3)
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
                            Color("SystemGray2").opacity(0.25)
                            VStack(spacing: 0) {
                                ForEach(blocks.filter { $0.dates.contains(inheritedDate) }, id: \.self) { block in
                                    if allAssignableCourses.contains(block.title) {
                                        if getCoursefromID(courseID: block.title, courses: courses).isFreePeriod {
                                            Color("SystemGray2").opacity(0.25)
                                        } else {
                                            Color(hexString: getCoursefromID(courseID: block.title, courses: courses).color)
                                        }
                                    } else if block.type == "FREE" && block.title != "Lunch" {
                                        Color("SystemGray2").opacity(0.25)
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

struct ScheduleStack: View {
    
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    
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
            }
            .padding(.bottom, 7)
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
                                .foregroundStyle(Color("SystemGray2").opacity(0.25))
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
