//
//  ExportVM.swift
//  CPS Campus (Shared)
//
//  7/20/2022
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import DynamicColor

let corners = CGFloat(0)

struct ScheduleExport: View {
    
    //MARK: Environment
    let date: Date
    
    //MARK: Course and Schedule Data
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    let portrait: Bool
    let portraitSection: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 3) {
                if portrait {
                    if portraitSection == 1 {
                        ScheduleStackExport(blocks: scheduleBlocks, date: date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 2, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), portrait: portrait)
                        ScheduleStackExport(blocks: scheduleBlocks, date: date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 3, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), portrait: portrait)
                        ScheduleStackExport(blocks: scheduleBlocks, date: date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 4, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), portrait: portrait)
                    } else {
                        ScheduleStackExport(blocks: scheduleBlocks, date: date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 5, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), portrait: portrait)
                        ScheduleStackExport(blocks: scheduleBlocks, date: date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 6, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), portrait: portrait)
                        VStack(spacing: 0) {
                            HStack {
                                Text(reformatDateString(date: convertDatetoString(date: createAllDayDate(weekday: 7, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), currentDateFormat: "M/d/yyyy", newDateFormat: "E, MMM d"))
                                    .fontWeight(.semibold)
                                    .font(.system(size: 8))
                                    .foregroundStyle(Color("SystemContrast"))
                                Spacer()
                            }.frame(height: 10).padding(.horizontal, 3).padding(.bottom, 5)
                            RoundedRectangle(cornerRadius: corners, style: .circular)
                                .foregroundStyle(.clear)
                                .overlay(RoundedRectangle(cornerRadius: corners, style: .circular).stroke(Color("SystemGray3"), lineWidth: 3))
                                .clipShape(RoundedRectangle(cornerRadius: corners, style: .circular))
                            HStack {
                                Text(reformatDateString(date: convertDatetoString(date: Calendar.current.date(byAdding: .day, value: 1, to: createAllDayDate(weekday: 7, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date))) ?? Date(), format: "M/d/yyyy"), currentDateFormat: "M/d/yyyy", newDateFormat: "E, MMM d"))
                                    .fontWeight(.semibold)
                                    .font(.system(size: 8))
                                    .foregroundStyle(Color("SystemContrast"))
                                Spacer()
                            }.frame(height: 10).padding(.horizontal, 3).padding(.vertical, 5)
                            RoundedRectangle(cornerRadius: corners, style: .circular)
                                .foregroundStyle(.clear)
                                .overlay(RoundedRectangle(cornerRadius: corners, style: .circular).stroke(Color("SystemGray3"), lineWidth: 3))
                                .clipShape(RoundedRectangle(cornerRadius: corners, style: .circular))
                                .padding(.bottom, 3)
                            ZStack {
                                RoundedRectangle(cornerRadius: corners, style: .circular)
                                    .foregroundStyle(Color("SystemCell").opacity(0.5))
                                    .overlay(RoundedRectangle(cornerRadius: corners, style: .circular).stroke(Color("SystemGray3"), lineWidth: 3))
                                    .clipShape(RoundedRectangle(cornerRadius: corners, style: .circular))
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text("2023-2024 CPS Planner")
                                            Text("Designed by Rahim Malik in California")
                                        }.font(.system(size: 5, design: .rounded)).foregroundStyle(.gray).multilineTextAlignment(.trailing)
                                    }
                                }.padding(7)
                            }
                        }
                    }
                } else {
                    ScheduleStackExport(blocks: scheduleBlocks, date: date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 2, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), portrait: portrait)
                    ScheduleStackExport(blocks: scheduleBlocks, date: date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 3, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), portrait: portrait)
                    ScheduleStackExport(blocks: scheduleBlocks, date: date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 4, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), portrait: portrait)
                    ScheduleStackExport(blocks: scheduleBlocks, date: date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 5, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), portrait: portrait)
                    ScheduleStackExport(blocks: scheduleBlocks, date: date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 6, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), portrait: portrait)
                    VStack(spacing: 0) {
                        HStack {
                            Text(reformatDateString(date: convertDatetoString(date: createAllDayDate(weekday: 7, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), currentDateFormat: "M/d/yyyy", newDateFormat: "E, MMM d"))
                                .fontWeight(.semibold)
                                .font(.system(size: 8))
                                .foregroundStyle(Color("SystemContrast"))
                            Spacer()
                        }.frame(height: 10).padding(.horizontal, 3).padding(.bottom, 5)
                        RoundedRectangle(cornerRadius: corners, style: .circular)
                            .foregroundStyle(.clear)
                            .overlay(RoundedRectangle(cornerRadius: corners, style: .circular).stroke(Color("SystemGray3"), lineWidth: 3))
                            .clipShape(RoundedRectangle(cornerRadius: corners, style: .circular))
                        HStack {
                            Text(reformatDateString(date: convertDatetoString(date: Calendar.current.date(byAdding: .day, value: 1, to: createAllDayDate(weekday: 7, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date))) ?? Date(), format: "M/d/yyyy"), currentDateFormat: "M/d/yyyy", newDateFormat: "E, MMM d"))
                                .fontWeight(.semibold)
                                .font(.system(size: 8))
                                .foregroundStyle(Color("SystemContrast"))
                            Spacer()
                        }.frame(height: 10).padding(.horizontal, 3).padding(.vertical, 5)
                        RoundedRectangle(cornerRadius: corners, style: .circular)
                            .foregroundStyle(.clear)
                            .overlay(RoundedRectangle(cornerRadius: corners, style: .circular).stroke(Color("SystemGray3"), lineWidth: 3))
                            .clipShape(RoundedRectangle(cornerRadius: corners, style: .circular))
                            .padding(.bottom, 3)
                        ZStack {
                            RoundedRectangle(cornerRadius: corners, style: .circular)
                                .foregroundStyle(Color("SystemCell").opacity(0.5))
                                .overlay(RoundedRectangle(cornerRadius: corners, style: .circular).stroke(Color("SystemGray3"), lineWidth: 3))
                                .clipShape(RoundedRectangle(cornerRadius: corners, style: .circular))
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("2023-2024 CPS Planner")
                                        Text("Designed by Rahim Malik in California")
                                    }.font(.system(size: 5, design: .rounded)).foregroundStyle(.gray).multilineTextAlignment(.trailing)
                                }
                            }.padding(7)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: portrait ? 612 : 792, alignment: .center)
        .frame(height: portrait ? 792 : 600, alignment: .bottom)
        .background(Color("SystemWindow"))
    }
    
    struct ScheduleStackExport: View {
        
        @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
        
        let blocks: [Block]
        let date: Date
        let inheritedDate: String
        let portrait: Bool
        
        @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
        
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Text(reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "E, MMM d"))
                        .fontWeight(.semibold)
                        .font(.system(size: 8))
                        .foregroundStyle(Color("SystemContrast"))
                    Spacer()
                    if getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }) != 0 {
                        Image(systemName: "\(getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate)})).circle")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color("SystemContrast"))
                    }
                }.frame(height: 10).padding(.horizontal, 3).padding(.bottom, 5)
                VStack(spacing: 3) {
                    ForEach(blocks.filter { $0.dates.contains(inheritedDate) }, id: \.self) { block in
                        if block.type == "HOLIDAY" {
                            if blocks.filter({ $0.dates.contains(inheritedDate) }).count <= 1 {
                                DayBlockExport(name: block.title)
                            }
                        } else if coursesGroup.contains(block.title) {
                            if checkCompass(compass: getCoursefromID(courseID: "Compass", courses: courses), gradYear: gradYear, block: block, blocks: blocks, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }), inheritedDate: inheritedDate) {
                                ScheduleBlockExport(course: getCoursefromID(courseID: block.title, courses: courses), id: block.title, startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                                    .frame(height: portrait ? 115 : 88)
                            } else {
                                if let course = Optional(getCoursefromID(courseID: block.title, courses: courses)) {
                                    if course.isFreePeriod || (course.visibleRotations != getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }) && course.visibleRotations != 0) {
                                        UniversalBlockExport(name: "Free Period", startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate)
                                            .frame(height: portrait ? 115 : 88)
                                    } else {
                                        ScheduleBlockExport(course: getCoursefromID(courseID: block.title, courses: courses), id: block.title, startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                                            .frame(height: portrait ? 115 : 88)
                                    }
                                }
                            }
                        } else if communityGroup.contains(block.title) {
                            if block.title == "Advising" && checkAdvising(gradYear: gradYear, inheritedDate: inheritedDate, blocks: blocks) == false {
                                UniversalBlockExport(name: "Open", startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate)
                            } else {
                                ScheduleBlockExport(course: getCoursefromID(courseID: block.title, courses: courses), id: block.title, startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }))
                            }
                        } else if block.title == "Faculty Collab" {
                            UniversalBlockExport(name: block.title, startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate)
                                .frame(height: portrait ? 115 : 88)
                        } else if block.type == "FREE" {
                            UniversalBlockExport(name: block.title, startDate: convertStringtoDate(string: block.startTime, format: "HH:mm"), endDate: convertStringtoDate(string: block.endTime, format: "HH:mm"), inheritedDate: inheritedDate)
                        }
                    }
                    if blocks.filter({ $0.dates.contains(inheritedDate) && $0.type == "HOLIDAY"}).first == nil {
                        RoundedRectangle(cornerRadius: 5, style: .circular)
                            .foregroundStyle(Color("SystemCell").opacity(0.5))
                            .overlay(RoundedRectangle(cornerRadius: corners, style: .circular).stroke(Color("SystemGray3"), lineWidth: 3))
                            .clipShape(RoundedRectangle(cornerRadius: corners, style: .circular))
                    }
                }
            }
        }
    }
    
    struct ScheduleBlockExport: View {
        
        var course: Course
        let id: String
        let startDate: Date
        let endDate: Date
        let inheritedDate: String
        let rotation: Int
        
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text(course.name)
                        .fontWeight(.semibold)
                        .font(.system(size: 7))
                    Spacer()
                    Text("\(convertDatetoString(date: startDate, format: "h:mm"))-\(convertDatetoString(date: endDate, format: "h:mm"))")
                        .opacity(0.75)
                        .font(.system(size: 7))
                }.padding(7)
                Spacer()
            }
            .overlay(RoundedRectangle(cornerRadius: corners, style: .circular).stroke(Color(colorScheme == .dark ? DynamicColor(hexString: course.color).shaded(amount: 0.15) : DynamicColor(hexString: course.color).tinted(amount: 0.15)), lineWidth: 3))
            .clipShape(RoundedRectangle(cornerRadius: corners, style: .circular))
        }
    }
    
    struct UniversalBlockExport: View {
        
        let name: String
        let startDate: Date
        let endDate: Date
        let inheritedDate: String
        
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text(name)
                        .fontWeight(.semibold)
                        .font(.system(size: 7))
                    Spacer()
                    Text("\(convertDatetoString(date: startDate, format: "h:mm"))-\(convertDatetoString(date: endDate, format: "h:mm"))")
                        .opacity(0.75)
                        .font(.system(size: 7))
                }
                .padding(7)
                Spacer()
            }
            .overlay(RoundedRectangle(cornerRadius: corners, style: .circular).stroke(Color("SystemGray3"), lineWidth: 3))
            .clipShape(RoundedRectangle(cornerRadius: corners, style: .circular))
        }
    }
    
    struct DayBlockExport: View {
        
        let name: String
        
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text(name)
                        .fontWeight(.semibold)
                        .font(.system(size: 7))
                    Spacer()
                }
                .padding(7)
                Spacer()
            }
            .overlay(RoundedRectangle(cornerRadius: corners, style: .circular).stroke(Color("SystemGray3"), lineWidth: 3))
            .clipShape(RoundedRectangle(cornerRadius: corners, style: .circular))
        }
    }
}
