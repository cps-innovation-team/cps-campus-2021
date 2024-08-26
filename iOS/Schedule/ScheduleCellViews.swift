//
//  ScheduleCellViews.swift
//  CPS Campus (iOS)
//
//  6/19/2022
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import DynamicColor
import EventKit

struct ScheduleBlock: View {
    
    var course: Course
    let id: String
    let startDate: Date
    let endDate: Date
    let inheritedDate: String
    let rotation: Int
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @State var showEvent = false
    
    var body: some View {
        ZStack {
            if course.isFreePeriod || (course.visibleRotations != rotation && course.visibleRotations != 0) {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .foregroundStyle(idiom == .pad ? Color(.systemGray4).opacity(0.5) : Color(.systemGray6))
            } else {
                RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(colorScheme == .dark ? UIColor(hexString: course.color).shaded(amount: 0.15) : UIColor(hexString: course.color).tinted(amount: 0.15)))
            }
            VStack {
                Spacer()
                HStack(spacing: 1) {
                    if coursesGroup.contains(id) {
                        Image(systemName: "\(id.first?.lowercased() ?? "").circle")
                            .foregroundStyle(Color("SystemContrast"))
                            .font(.system(size: 15))
                    }
                    if course.id == "Compass" {
                        Image(systemName: "\(course.visibleRotations).circle")
                            .foregroundStyle(Color("SystemContrast"))
                            .font(.system(size: 15))
                    }
                    Spacer()
                    if !(course.isFreePeriod || (course.visibleRotations != rotation && course.visibleRotations != 0)) {
                        if course.teacher != "" {
                            Image(systemName: "person")
                                .foregroundStyle(Color("SystemContrast"))
                                .font(.system(size: 15))
                        }
                        if course.room != "" {
                            Image(systemName: "building.2")
                                .foregroundStyle(Color("SystemContrast"))
                                .font(.system(size: 15))
                        }
                    }
                }
            }.padding(10)
            HStack {
                VStack(alignment: .center, spacing: 2.5) {
                    if course.isFreePeriod || (course.visibleRotations != rotation && course.visibleRotations != 0) {
                        Text("Free Period")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .large)
                    } else {
                        Text(course.name)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .large)
                    }
                    HStack(spacing: 1) {
                        Text(convertDatetoString(date: startDate, format: "h:mm"))
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .large)
                        Text("-")
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .medium)
                        Text(convertDatetoString(date: endDate, format: "h:mm"))
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .large)
                    }
                }
            }.padding(10)
                .minimumScaleFactor(0.75)
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15, style: .continuous))
        .contextMenu(ContextMenu(menuItems: {
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
                Label("Create Event", systemImage: "calendar.badge.plus")
            })
        }))
        .sheet(isPresented: $showEvent) {
            AddtoCalendarView(event: CalendarEvent(title: "", startDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: startDate)):\(Calendar.current.component(.minute, from: startDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), endDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: endDate)):\(Calendar.current.component(.minute, from: endDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), isAllDay: false, location: "", notes: "", availability: 1))
        }
    }
}

struct UniversalBlock: View {
    let name: String
    let startDate: Date
    let endDate: Date
    let inheritedDate: String
    
    @Environment(\.openURL) var openURL
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @State var showEvent = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundStyle(idiom == .pad ? Color(.systemGray4).opacity(0.5) : Color(.systemGray6))
            HStack {
                VStack(alignment: .center, spacing: 2.5) {
                    Text(name)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .dynamicTypeSize(.small ... .large)
                    HStack(spacing: 1) {
                        Text(convertDatetoString(date: startDate, format: "h:mm"))
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .large)
                        Text("-")
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .large)
                        Text(convertDatetoString(date: endDate, format: "h:mm"))
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .large)
                    }
                }
            }.padding(10)
                .minimumScaleFactor(0.75)
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15, style: .continuous))
        .contextMenu {
            Button(action: {
                eventStore.requestAccess(to: .event, completion: {(granted: Bool, error: Error?) -> Void in })
                showEvent = true
            }, label: {
                Label("Create Event", systemImage: "calendar.badge.plus")
            })
        }
        .sheet(isPresented: $showEvent) {
            AddtoCalendarView(event: CalendarEvent(title: "", startDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: startDate)):\(Calendar.current.component(.minute, from: startDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), endDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: endDate)):\(Calendar.current.component(.minute, from: endDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), isAllDay: false, location: "", notes: "", availability: 1))
        }
    }
}

struct ScheduleBlockStack: View {
    
    var course: Course
    let id: String
    let startDate: Date
    let endDate: Date
    let inheritedDate: String
    let rotation: Int
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @State var showEvent = false
    
    var body: some View {
        ZStack {
            if course.isFreePeriod || (course.visibleRotations != rotation && course.visibleRotations != 0) {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .foregroundStyle(idiom == .pad ? Color(.systemGray4).opacity(0.5) : Color(.systemGray6))
            } else {
                RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(colorScheme == .dark ? UIColor(hexString: course.color).shaded(amount: 0.15) : UIColor(hexString: course.color).tinted(amount: 0.15)))
            }
            HStack {
                VStack(alignment: .center, spacing: 2.5) {
                    if course.isFreePeriod || (course.visibleRotations != rotation && course.visibleRotations != 0) {
                        Text("Free Period")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .medium)
                    } else {
                        Text(course.name)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .medium)
                    }
                    HStack(spacing: 1) {
                        Text(convertDatetoString(date: startDate, format: "h:mm"))
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .medium)
                        Text("-")
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .medium)
                        Text(convertDatetoString(date: endDate, format: "h:mm"))
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .medium)
                    }
                }
            }.padding(10)
                .minimumScaleFactor(0.75)
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15, style: .continuous))
        .contextMenu(ContextMenu(menuItems: {
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
                Label("Create Event", systemImage: "calendar.badge.plus")
            })
        }))
        .sheet(isPresented: $showEvent) {
            AddtoCalendarView(event: CalendarEvent(title: "", startDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: startDate)):\(Calendar.current.component(.minute, from: startDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), endDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: endDate)):\(Calendar.current.component(.minute, from: endDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), isAllDay: false, location: "", notes: "", availability: 1))
        }
    }
}

struct UniversalBlockStack: View {
    let name: String
    let startDate: Date
    let endDate: Date
    let inheritedDate: String
    
    @Environment(\.openURL) var openURL
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @State var showEvent = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundStyle(idiom == .pad ? Color(.systemGray4).opacity(0.5) : Color(.systemGray6))
            HStack {
                VStack(alignment: .center, spacing: 2.5) {
                    Text(name)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .dynamicTypeSize(.small ... .medium)
                    HStack(spacing: 1) {
                        Text(convertDatetoString(date: startDate, format: "h:mm"))
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .medium)
                        Text("-")
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .medium)
                        Text(convertDatetoString(date: endDate, format: "h:mm"))
                            .opacity(0.75)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small ... .medium)
                    }
                }
            }.padding(10)
                .minimumScaleFactor(0.75)
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15, style: .continuous))
        .contextMenu {
            Button(action: {
                eventStore.requestAccess(to: .event, completion: {(granted: Bool, error: Error?) -> Void in })
                showEvent = true
            }, label: {
                Label("Create Event", systemImage: "calendar.badge.plus")
            })
        }
        .sheet(isPresented: $showEvent) {
            AddtoCalendarView(event: CalendarEvent(title: "", startDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: startDate)):\(Calendar.current.component(.minute, from: startDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), endDate: convertStringtoDate(string: "\(Calendar.current.component(.hour, from: endDate)):\(Calendar.current.component(.minute, from: endDate)) \(inheritedDate)", format: "HH:mm M/d/yyyy"), isAllDay: false, location: "", notes: "", availability: 1))
        }
    }
}

struct DayBlock: View {
    let name: String
    let image: Image
    let date: Date
    let inheritedDate: String
    let weekday: Int
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 5) {
                Text(name)
                    .fontWeight(.bold)
                    .font(.system(size: 30))
                scheduleDateHeader(weekday: weekday, date: date, inheritedDate: inheritedDate, compact: true)
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
                    .padding(.top)
            }
            Spacer()
        }
    }
}

struct DayBlockStack: View {
    let name: String
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundStyle(idiom == .pad ? Color(.systemGray4).opacity(0.5) : Color(.systemGray6))
            HStack {
                VStack(alignment: .center, spacing: 2.5) {
                    Text(name)
                        .font(.system(size: 15))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.75)
                }
            }.padding()
        }
    }
}
