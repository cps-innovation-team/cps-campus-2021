//
//  ScheduleCellViews.swift
//  CPS Campus (macOS)
//
//  5/22/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import DynamicColor

struct ScheduleBlockStack: View {
    
    var course: Course
    let id: String
    let startDate: Date
    let endDate: Date
    let inheritedDate: String
    let rotation: Int
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @State var showEvent = false
    
    var body: some View {
        ZStack {
            if course.isFreePeriod || (course.visibleRotations != rotation && course.visibleRotations != 0) {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .foregroundStyle(Color("SystemGray2").opacity(0.25))
            } else {
                RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(colorScheme == .dark ? NSColor(hexString: course.color).shaded(amount: 0.15) : NSColor(hexString: course.color).tinted(amount: 0.15)))
            }
            HStack {
                VStack(alignment: .center, spacing: 2.5) {
                    if course.isFreePeriod || (course.visibleRotations != rotation && course.visibleRotations != 0) {
                        Text("Free Period")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(course.name)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    }
                    HStack(spacing: 1) {
                        Text(convertDatetoString(date: startDate, format: "h:mm"))
                            .multilineTextAlignment(.center)
                        Text("-")
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                        Text(convertDatetoString(date: endDate, format: "h:mm"))
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                    }
                }
            }.padding(10)
                .minimumScaleFactor(0.75)
        }
        .contextMenu {
            if coursesGroup.contains(id) {
                Label(id, systemImage: String("\(rotation).circle"))
            }
            if course.id == "Compass" {
                Label(course.compassBlock, systemImage: String("\(course.visibleRotations).circle"))
            }
            if !(course.isFreePeriod || (course.visibleRotations != rotation && course.visibleRotations != 0)) {
                if course.teacher != "" {
                    Label(course.teacher, systemImage: "person")
                }
                if course.room != "" {
                    Label(course.room, systemImage: "building.2")
                }
            }
            Divider()
            Button(action: {
                eventStore.requestAccess(to: .event, completion: {(granted: Bool, error: Error?) -> Void in })
                showEvent = true
            }, label: {
                Text("Create Event")
            })
        }
        .popover(isPresented: $showEvent) {
            AddtoCalendarView(event: CalendarEvent(title: "", startDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: startDate)):\(Calendar.current.component(.minute, from: startDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), endDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: endDate)):\(Calendar.current.component(.minute, from: endDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), isAllDay: false, location: "", notes: "", availability: 1))
                .frame(maxWidth: 300, maxHeight: 500)
        }
    }
}

struct UniversalBlockStack: View {
    let name: String
    let startDate: Date
    let endDate: Date
    let inheritedDate: String
    
    @Environment(\.openURL) var openURL
    @State var showEvent = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundStyle(Color("SystemGray2").opacity(0.25))
            HStack {
                VStack(alignment: .center, spacing: 2.5) {
                    Text(name)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    HStack(spacing: 1) {
                        Text(convertDatetoString(date: startDate, format: "h:mm"))
                            .multilineTextAlignment(.center)
                        Text("-")
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                        Text(convertDatetoString(date: endDate, format: "h:mm"))
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                    }
                }
            }.padding(10)
                .minimumScaleFactor(0.75)
        }
        .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .contextMenu {
            Button(action: {
                eventStore.requestAccess(to: .event, completion: {(granted: Bool, error: Error?) -> Void in })
                showEvent = true
            }, label: {
                Text("Create Event")
            })
        }
        .popover(isPresented: $showEvent) {
            AddtoCalendarView(event: CalendarEvent(title: "", startDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: startDate)):\(Calendar.current.component(.minute, from: startDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), endDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: endDate)):\(Calendar.current.component(.minute, from: endDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), isAllDay: false, location: "", notes: "", availability: 1))
                .frame(maxWidth: 300, maxHeight: 500)
        }
    }
}

struct DayBlockStack: View {
    let name: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("SystemGray2").opacity(0.25))
            HStack {
                VStack(alignment: .center, spacing: 2.5) {
                    Text(name)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.75)
                }
            }.padding()
        }
    }
}
