//
//  ScheduleHelpers.swift
//  CPS Campus (iOS)
//
//  5/22/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import EventKit

//MARK: - Event Generator
let eventStore = EKEventStore()

func createiCalendarEvent(input: CalendarEvent, calendarID: String?) {
    
    let event = EKEvent(eventStore: eventStore)
    
    if let id = calendarID {
        if id != "" {
            event.calendar = eventStore.calendar(withIdentifier: id)
        }
    } else {
        event.calendar = eventStore.defaultCalendarForNewEvents
    }
    
    event.title = input.title
    event.startDate = input.startDate
    
    //corrects for double date fallacy (tm)
    if input.startDate != input.endDate && input.isAllDay == true {
        event.endDate = Calendar.current.date(byAdding: .minute, value: 1, to: input.endDate)
    } else {
        event.endDate = input.endDate
    }
    
    event.isAllDay = input.isAllDay
    event.location = input.location
    
    do {
        try eventStore.save(event, span: .thisEvent, commit: true)
    }
    catch {
        authLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
    }
}

func createGCalEvent(input: CalendarEvent, account: String) -> URL {
    var string = "https://www.calendar.google.com"
    if input.isAllDay {
        string = String("https://www.google.com/calendar/u/\(account)/event?action=TEMPLATE&dates=\(convertDatetoString(date: input.startDate, format: "YYYYMMdd"))/\(convertDatetoString(date: input.endDate, format: "YYYYMMdd"))&text=\(input.title.replacingOccurrences(of: " ", with: "+"))&location=\(input.location.replacingOccurrences(of: " ", with: "+"))")
    } else {
        string = String("http://www.google.com/calendar/u/\(String(account))/event?action=TEMPLATE&dates=\(convertDatetoString(date: input.startDate, format: "YYYYMMdd'T'HHmm"))00%2F\(convertDatetoString(date: input.endDate, format: "YYYYMMdd'T'HHmm"))00&text=\(input.title.replacingOccurrences(of: " ", with: "+"))&location=\(input.location.replacingOccurrences(of: " ", with: "+"))")
    }
    return URL(string: string) ?? URL(string: "https://www.calendar.google.com")!
}

//MARK: Course Helpers
func getCoursefromID(courseID: String, courses: [Course]) -> Course {
    var output: Course?
    for course in courses {
        if course.id == courseID { output = course }
    }
    return output ?? Course(num: 0, id: "NilCourse", canvasID: "", compassBlock: "", visibleRotations: 0, isFreePeriod: false, name: "", teacher: "", room: "", color: "")
}

func getOptionalCoursefromID(courseID: String, courses: [Course]) -> Course? {
    var output: Course?
    for course in courses {
        if course.id == courseID { output = course }
    }
    return output
}

func getCoursefromName(courseName: String, courses: [Course]) -> Course? {
    var output: Course?
    for course in courses {
        if course.name == courseName { output = course }
    }
    return output
}

//MARK: - Class Checkers
func checkCompass(compass: Course, gradYear: String, block: Block, blocks: [Block], rotation: Int, inheritedDate: String) -> Bool {
    var bool = false
    if gradYear == juniorClass {
        if compass.compassBlock == block.title && compass.visibleRotations == rotation {
            if let compassValue = blocks.first(where: { $0.title.contains("Compass11Rotations") }) {
                if compassValue.dates.contains(reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "w/yyyy")) {
                    // checks if day is not Monday (Wellness is always on Friday for a week with two valid blocks
                    if reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "c") != "2" {
                        bool = true
                    }
                }
            }
        }
    } else if gradYear == sophClass {
        if compass.compassBlock == block.title && compass.visibleRotations == rotation {
            if let compassValue = blocks.first(where: { $0.title.contains("Compass10Rotations") }) {
                if compassValue.dates.contains(reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "w/yyyy")) {
                    // checks if day is not Monday (Wellness is always on Friday for a week with two valid blocks
                    if reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "c") != "2" {
                        bool = true
                    }
                }
            }
        }
    } else if gradYear == freshClass {
        if compass.compassBlock == block.title && compass.visibleRotations == rotation {
            if let compassValue = blocks.first(where: { $0.title.contains("Compass9Rotations") }) {
                if compassValue.dates.contains(reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "w/yyyy")) {
                    // checks if day is not Monday (Wellness is always on Friday for a week with two valid blocks
                    if reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "c") != "2" {
                        bool = true
                    }
                }
            }
        }
    }
    return(bool)
}

func checkAdvising(gradYear: String, inheritedDate: String, blocks: [Block]) -> Bool {
    var bool = true
    if [seniorClass,juniorClass,sophClass].contains(gradYear) {
        if let advisingValue = blocks.first(where: { $0.title.contains("AdvisingRotations") }) {
            if !advisingValue.dates.contains(reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "w/yyyy")) {
                bool = false
            }
        }
    }
    return(bool)
}

func checkCoursebyRotation(course: Course, block: Block, blocks: [Block]) -> Bool {
    var bool = false
    if course.compassBlock == block.title {
        if (blocks.first(where: {$0.title == "1"})?.title) != nil && course.visibleRotations == 1 {
            bool = true
        } else if (blocks.first(where: {$0.title == "2"})?.title) != nil && course.visibleRotations == 2 {
            bool = true
        } else if (blocks.first(where: {$0.title == "3"})?.title) != nil && course.visibleRotations == 3 {
            bool = true
        } else if (blocks.first(where: {$0.title == "4"})?.title) != nil && course.visibleRotations == 4 {
            bool = true
        } else if course.visibleRotations == 0 {
            bool = true
        }
    }
    return bool
}

//MARK: - Schedule Construction
func weekAdvance(date: Date) -> Date {
    var finaldate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date) ?? Date()
    var components = Calendar.current.dateComponents([.weekOfYear, .weekday, .year], from: finaldate)
    components.weekday = 2
    finaldate = Calendar.current.date(from: components) ?? Date()
    return(finaldate)
}

func weekRegress(date: Date) -> Date {
    var finaldate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: date) ?? Date()
    var components = Calendar.current.dateComponents([.weekOfYear, .weekday, .year], from: finaldate)
    components.weekday = 6
    finaldate = Calendar.current.date(from: components) ?? Date()
    return(finaldate)
}

func basicDateDifference(date1: Date, date2: Date) -> Int {
    let diff = Calendar.current.dateComponents([.minute], from: date1, to: date2).minute ?? 100
    return diff
}

func getTotalGeoSize(blocks: [Block]) -> CGFloat {
    var total = 0
    for block in blocks.filter({ ["COURSE","FREE","PASSING"].contains($0.type) }) {
        total += basicDateDifference(date1: convertStringtoDate(string: block.startTime, format: "HH:mm"), date2: convertStringtoDate(string: block.endTime, format: "HH:mm"))
    }
    total = total + ((blocks.filter({ ["COURSE","FREE","PASSING"].contains($0.type) }).count - 1)*5) + 0
    return CGFloat(total)
}

func getRotation(blocks: [Block]) -> Int {
    var rotation = 0
    if (blocks.first(where: {$0.title == "1"})?.title) != nil {
        rotation = 1
    }
    if (blocks.first(where: {$0.title == "2"})?.title) != nil {
        rotation = 2
    }
    if (blocks.first(where: {$0.title == "3"})?.title) != nil {
        rotation = 3
    }
    if (blocks.first(where: {$0.title == "4"})?.title) != nil {
        rotation = 4
    }
    return rotation
}

//MARK: - Schedule Headers
func dateHeaderPicker(date: Date, weekday: Int) -> String {
    var components = Calendar.current.dateComponents([.weekday, .weekOfYear, .year], from: date)
    components.weekday = weekday
    let date = Calendar.current.date(from: components) ?? Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    dateFormatter.setLocalizedDateFormatFromTemplate("d")
    return(dateFormatter.string(from: date).uppercased())
}

func weekendDateHeader(weekday: Int, date: Date) -> AnyView {
    if weekday == 1 {
        var saturday = Calendar.current.dateComponents([.weekday,.weekOfYear,.year], from: date)
        saturday.weekOfYear = Calendar.current.component(.weekOfYear, from: date) - 1
        saturday.weekday = 7
        let saturdaydate = Calendar.current.date(from: saturday) ?? Date()
        return AnyView(
            HStack(spacing: 0) {
                if Calendar.current.component(.weekday, from: Date()) == 7 && Calendar.current.component(.weekOfYear, from: Date()) == Calendar.current.component(.weekOfYear, from: saturdaydate) {
                    Text("\(weekendDateHelper(date: saturdaydate, weekday: 7, compact: true))")
                        .fontWeight(.medium)
                        .font(.system(Font.TextStyle.body, design: .rounded))
                        .foregroundStyle(Color("AccentColor"))
                        .dynamicTypeSize(.small ... .medium)
                } else {
                    Text("\(weekendDateHelper(date: saturdaydate, weekday: 7, compact: true))")
                        .fontWeight(.medium)
                        .font(.system(Font.TextStyle.body, design: .rounded))
                        .foregroundStyle(Color(.gray))
                        .dynamicTypeSize(.small ... .medium)
                }
                Text(" - ")
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.gray).opacity(1))
                    .dynamicTypeSize(.small ... .large)
                if Calendar.current.component(.weekday, from: Date()) == 1 && Calendar.current.component(.weekOfYear, from: Date()) == Calendar.current.component(.weekOfYear, from: date) {
                    Text("\(weekendDateHelper(date: date, weekday: 1, compact: true))")
                        .fontWeight(.medium)
                        .font(.system(Font.TextStyle.body, design: .rounded))
                        .foregroundStyle(Color("AccentColor"))
                        .dynamicTypeSize(.small ... .medium)
                } else {
                    Text("\(weekendDateHelper(date: date, weekday: 1, compact: true))")
                        .fontWeight(.medium)
                        .font(.system(Font.TextStyle.body, design: .rounded))
                        .foregroundStyle(Color(.gray))
                        .dynamicTypeSize(.small ... .medium)
                }
            }
        )
    } else {
        var sunday = Calendar.current.dateComponents([.weekday,.weekOfYear,.year], from: date)
        sunday.weekOfYear = Calendar.current.component(.weekOfYear, from: date) + 1
        sunday.weekday = 1
        let sundaydate = Calendar.current.date(from: sunday) ?? Date()
        return AnyView(
            HStack(spacing: 0) {
                if Calendar.current.component(.weekday, from: Date()) == 7 && Calendar.current.component(.weekOfYear, from: Date()) == Calendar.current.component(.weekOfYear, from: date) {
                    Text("\(weekendDateHelper(date: date, weekday: 7, compact: true))")
                        .fontWeight(.medium)
                        .font(.system(Font.TextStyle.body, design: .rounded))
                        .foregroundStyle(Color("AccentColor"))
                        .dynamicTypeSize(.small ... .medium)
                } else {
                    Text("\(weekendDateHelper(date: date, weekday: 7, compact: true))")
                        .fontWeight(.medium)
                        .font(.system(Font.TextStyle.body, design: .rounded))
                        .foregroundStyle(Color(.gray))
                        .dynamicTypeSize(.small ... .medium)
                }
                Text(" - ")
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.gray).opacity(1))
                    .dynamicTypeSize(.small ... .large)
                if Calendar.current.component(.weekday, from: Date()) == 1 && Calendar.current.component(.weekOfYear, from: Date()) == Calendar.current.component(.weekOfYear, from: sundaydate) {
                    Text("\(weekendDateHelper(date: sundaydate, weekday: 1, compact: true))")
                        .fontWeight(.medium)
                        .font(.system(Font.TextStyle.body, design: .rounded))
                        .foregroundStyle(Color("AccentColor"))
                        .dynamicTypeSize(.small ... .medium)
                } else {
                    Text("\(weekendDateHelper(date: sundaydate, weekday: 1, compact: true))")
                        .fontWeight(.medium)
                        .font(.system(Font.TextStyle.body, design: .rounded))
                        .foregroundStyle(Color(.gray))
                        .dynamicTypeSize(.small ... .medium)
                }
            }
        )
    }
}

func weekendDateHelper(date: Date, weekday: Int, compact: Bool) -> String {
    var components = Calendar.current.dateComponents([.weekday, .weekOfYear, .year], from: date)
    components.weekday = weekday
    let date = Calendar.current.date(from: components) ?? Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    if compact {
        dateFormatter.setLocalizedDateFormatFromTemplate("E MMM d")
        return("\(String(dateFormatter.string(from: date).uppercased()))")
    } else {
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        return(dateFormatter.string(from: date).uppercased())
    }
}

func scheduleDateHeader(weekday: Int, date: Date, inheritedDate: String, compact: Bool) -> AnyView {
    if Calendar.current.component(.weekday, from: Date()) == weekday && Calendar.current.component(.weekOfYear, from: Date()) == Calendar.current.component(.weekOfYear, from: date) {
        return AnyView(
            HStack(spacing: 0) {
                Text("\(compact ? reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "E, MMM d") : reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "EEEE, MMMM d"))")
                    .fontWeight(.medium)
                    .font(.system(Font.TextStyle.body, design: .rounded))
                    .foregroundStyle(Color("AccentColor"))
                    .truncationMode(.middle)
                    .textCase(.uppercase)
                    .dynamicTypeSize(.small ... .medium)
            }.lineLimit(1)
        )
    } else if Calendar.current.component(.weekday, from: date) == weekday {
        return AnyView(
            HStack(spacing: 0) {
                Text(compact ? "\(reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "E, MMM d"))" : "\(reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "EEEE, MMMM d"))")
                    .fontWeight(.medium)
                    .font(.system(Font.TextStyle.body, design: .rounded))
                    .foregroundStyle(Color("SystemContrast"))
                    .truncationMode(.middle)
                    .textCase(.uppercase)
                    .dynamicTypeSize(.small ... .medium)
            }.lineLimit(1)
        )
    } else {
        return AnyView(
            HStack(spacing: 0) {
                Text(compact ? "\(reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "E, MMM d"))" : "\(reformatDateString(date: inheritedDate, currentDateFormat: "M/d/yyyy", newDateFormat: "EEEE, MMMM d"))")
                    .fontWeight(.medium)
                    .font(.system(Font.TextStyle.body, design: .rounded))
                    .foregroundStyle(.gray)
                    .truncationMode(.middle)
                    .textCase(.uppercase)
                    .dynamicTypeSize(.small ... .medium)
            }.lineLimit(1)
        )
    }
}

func scheduleRotationIndicator(weekday: Int, date: Date, rotation: Int) -> AnyView {
    if rotation != 0 {
        if Calendar.current.component(.weekday, from: Date()) == weekday && Calendar.current.component(.weekOfYear, from: Date()) == Calendar.current.component(.weekOfYear, from: date) {
            return AnyView(
                Image(systemName: "\(rotation).circle")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color("AccentColor"))
            )
        } else if Calendar.current.component(.weekday, from: date) == weekday {
            return AnyView(
                Image(systemName: "\(rotation).circle")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color("SystemContrast"))
            )
        } else {
            return AnyView(
                Image(systemName: "\(rotation).circle")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.gray)
            )
        }
    } else {
        return AnyView(
            Image(systemName: "\(rotation).circle")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.clear)
        )
    }
}
