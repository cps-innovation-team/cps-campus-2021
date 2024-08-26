//
//  NowViewModel.swift
//  CPS Campus (Shared)
//
//  5/30/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import WidgetKit
import DynamicColor

struct NowClass: Equatable, Hashable {
    var name: String
    var teacher: String
    var room: String
    var time: String
    var color: Color
    var freePeriod: Bool
    var startDate: Date
    var endDate: Date
    var type: String
}

func getNowBlockFromDate(date: Date, blocks: [Block], courses: [Course], gradYear: String) -> [NowClass]? {
    var output = [NowClass]()
    let inheritedDate = convertDatetoString(date: date, format: "M/d/yyyy")
    for block in blocks.filter({ $0.dates.contains(inheritedDate) }) {
        if block.endTime > convertDatetoString(date: date, format: "HH:mm") {
            if allAssignableCourses.contains(block.title) {
                if checkCompass(compass: getCoursefromID(courseID: "Compass", courses: courses), gradYear: gradYear, block: block, blocks: blocks, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }), inheritedDate: inheritedDate) {
                    let course = getCoursefromID(courseID: "Compass", courses: courses)
                    output.append(NowClass(name: course.name, teacher: course.teacher, room: course.room, time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color(hexString: course.color), freePeriod: course.isFreePeriod, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                } else if block.title == "Advising" && checkAdvising(gradYear: gradYear, inheritedDate: inheritedDate, blocks: blocks) == false {
                    output.append(NowClass(name: "Open", teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: false, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: "FREE"))
                } else if checkCoursebyRotation(course: getCoursefromID(courseID: block.title, courses: courses), block: block, blocks: blocks.filter { $0.dates.contains(inheritedDate) }) {
                    let course = getCoursefromID(courseID: block.title, courses: courses)
                    output.append(NowClass(name: course.name, teacher: course.teacher, room: course.room, time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color(hexString: course.color), freePeriod: course.isFreePeriod, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                } else {
                    output.append(NowClass(name: "Free Period", teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                }
            } else if block.type == "FREE" || block.type == "PASSING" {
                output.append(NowClass(name: block.title, teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
            }
        }
    }
    if output.count > 0 {
        return output.sorted {$0.startDate < $1.startDate}
    } else {
        return nil
    }
}

func getWidgetBlockToday(size: WidgetFamily, blocks: [Block], courses: [Course], gradYear: String) -> [NowClass]? {
    var output = [NowClass]()
    let inheritedDate = convertDatetoString(date: Date(), format: "M/d/yyyy")
    for block in blocks.filter({ $0.dates.contains(inheritedDate) }) {
        if allAssignableCourses.contains(block.title) {
            if checkCompass(compass: getCoursefromID(courseID: "Compass", courses: courses), gradYear: gradYear, block: block, blocks: blocks, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }), inheritedDate: inheritedDate) {
                let course = getCoursefromID(courseID: "Compass", courses: courses)
                if size == .systemSmall {
                    output.append(NowClass(name: course.name, teacher: course.teacher, room: course.room, time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color(hexString: course.color), freePeriod: course.isFreePeriod, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                } else {
                    output.append(NowClass(name: course.name, teacher: course.teacher, room: course.room, time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color(hexString: course.color), freePeriod: course.isFreePeriod, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                }
            } else if block.title == "Advising" && checkAdvising(gradYear: gradYear, inheritedDate: inheritedDate, blocks: blocks) == false {
                if size == .systemSmall {
                    output.append(NowClass(name: "Open", teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: "FREE"))
                } else {
                    output.append(NowClass(name: "Open", teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: "FREE"))
                }
            } else if checkCoursebyRotation(course: getCoursefromID(courseID: block.title, courses: courses), block: block, blocks: blocks.filter { $0.dates.contains(inheritedDate) }) {
                let course = getCoursefromID(courseID: block.title, courses: courses)
                if size == .systemSmall {
                    output.append(NowClass(name: course.name, teacher: course.teacher, room: course.room, time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color(hexString: course.color), freePeriod: course.isFreePeriod, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                } else {
                    output.append(NowClass(name: course.name, teacher: course.teacher, room: course.room, time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color(hexString: course.color), freePeriod: course.isFreePeriod, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                }
            } else {
                if size == .systemSmall {
                    output.append(NowClass(name: "Free Period", teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                } else {
                    output.append(NowClass(name: "Free Period", teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                }
            }
        } else if block.type == "FREE" {
            if size == .systemSmall {
                output.append(NowClass(name: block.title, teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
            } else {
                output.append(NowClass(name: block.title, teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
            }
        }
    }
    if output.count > 0 {
        return output.sorted {$0.startDate < $1.startDate}
    } else {
        return nil
    }
}

func getWidgetBlockTomorrow(size: WidgetFamily, blocks: [Block], courses: [Course], gradYear: String) -> [NowClass]? {
    var output = [NowClass]()
    
    var components = DateComponents()
    components = Calendar.current.dateComponents([.weekday, .weekOfYear, .year], from: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
    components.hour = 7
    components.minute = 15
    let date = Calendar.current.date(from: components) ?? Date()
    
    let inheritedDate = convertDatetoString(date: date, format: "M/d/yyyy")
    
    for block in blocks.filter({ $0.dates.contains(inheritedDate) }) {
        if allAssignableCourses.contains(block.title) {
            if checkCompass(compass: getCoursefromID(courseID: "Compass", courses: courses), gradYear: gradYear, block: block, blocks: blocks, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(inheritedDate) }), inheritedDate: inheritedDate) {
                let course = getCoursefromID(courseID: "Compass", courses: courses)
                if size == .systemSmall {
                    output.append(NowClass(name: course.name, teacher: course.teacher, room: course.room, time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color(hexString: course.color), freePeriod: course.isFreePeriod, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                } else {
                    output.append(NowClass(name: course.name, teacher: course.teacher, room: course.room, time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color(hexString: course.color), freePeriod: course.isFreePeriod, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                }
            } else if block.title == "Advising" && checkAdvising(gradYear: gradYear, inheritedDate: inheritedDate, blocks: blocks) == false {
                if size == .systemSmall {
                    output.append(NowClass(name: "Open", teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: "FREE"))
                } else {
                    output.append(NowClass(name: "Open", teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: "FREE"))
                }
            } else if checkCoursebyRotation(course: getCoursefromID(courseID: block.title, courses: courses), block: block, blocks: blocks.filter { $0.dates.contains(inheritedDate) }) {
                let course = getCoursefromID(courseID: block.title, courses: courses)
                if size == .systemSmall {
                    output.append(NowClass(name: course.name, teacher: course.teacher, room: course.room, time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color(hexString: course.color), freePeriod: course.isFreePeriod, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                } else {
                    output.append(NowClass(name: course.name, teacher: course.teacher, room: course.room, time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color(hexString: course.color), freePeriod: course.isFreePeriod, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                }
            } else {
                if size == .systemSmall {
                    output.append(NowClass(name: "Free Period", teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                } else {
                    output.append(NowClass(name: "Free Period", teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
                }
            }
        } else if block.type == "FREE" {
            if size == .systemSmall {
                output.append(NowClass(name: block.title, teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
            } else {
                output.append(NowClass(name: block.title, teacher: "", room: "", time: String("\(reformatDateString(date: block.startTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm")) - \(reformatDateString(date: block.endTime, currentDateFormat: "HH:mm", newDateFormat: "h:mm"))"), color: Color("SystemGray3"), freePeriod: true, startDate: convertStringtoDate(string: "\(inheritedDate) \(block.startTime)", format: "M/d/yyyy HH:mm"), endDate: convertStringtoDate(string: "\(inheritedDate) \(block.endTime)", format: "M/d/yyyy HH:mm"), type: block.type))
            }
        }
    }
    if output.count > 0 {
        return output.sorted {$0.startDate < $1.startDate}
    } else {
        return nil
    }
}
