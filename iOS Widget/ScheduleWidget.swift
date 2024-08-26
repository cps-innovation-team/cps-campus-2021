//
//  ScheduleWidgetiOS.swift
//  CPS Campus (iOS Widget)
//
//  7/18/2021
//  Designed by Rahim Malik in California.
//

import WidgetKit
import SwiftUI
import DynamicColor

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct ScheduleWidgetiOSEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    
    var body: some View {
        ZStack {
            VStack {
                Rectangle().foregroundStyle(Color("WidgetBackground"))
            }
            VStack {
                if Calendar.current.component(.hour, from: entry.date) >= 15 || getWidgetBlockToday(size: family, blocks: scheduleBlocks, courses: courses, gradYear: gradYear) == nil {
                    HStack {
                        Text("Tomorrow")
                            .textCase(.uppercase)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("AccentColor"))
                        Spacer()
                        if getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), format: "M/d/yyyy")) }) != 0 {
                            Image(systemName: "\(getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), format: "M/d/yyyy")) })).circle")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color("AccentColor"))
                        }
                    }
                    if family == .systemLarge {
                        if let array = getWidgetBlockTomorrow(size: family, blocks: scheduleBlocks, courses: courses, gradYear: gradYear) {
                            VStack(spacing: 5) {
                                ForEach(array, id: \.self) { block in
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
                                            Text(block.time)
                                                .font(.system(size: 15))
                                        }
                                        .padding(.horizontal)
                                        Spacer()
                                    }
                                    .background(block.freePeriod == true ? Color(.systemGray5) : Color(colorScheme == .dark ? UIColor(block.color).shaded(amount: 0.15) : UIColor(block.color).tinted(amount: 0.15)))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                            .padding(.top, 0.5)
                        } else {
                            HStack {
                                Text("No Classes")
                                    .textCase(.uppercase)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color("SystemContrast2"))
                                Spacer()
                            }
                        }
                    } else {
                        if let array = getWidgetBlockTomorrow(size: family, blocks: scheduleBlocks, courses: courses, gradYear: gradYear) {
                            VStack(spacing: 5) {
                                ForEach(array.indices, id: \.self) { num in
                                    if num < 4 {
                                        HStack {
                                            Capsule()
                                                .foregroundStyle(array[num].freePeriod == true ? Color(.systemGray2) : Color(colorScheme == .light ? UIColor(array[num].color).shaded(amount: 0.15) : UIColor(array[num].color).tinted(amount: 0.15)))
                                                .frame(width: 4, height: 18)
                                            if array[num].freePeriod == true && array[num].type != "FREE" {
                                                Text("Free Period")
                                                    .fontWeight(.semibold)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color("SystemContrast2"))
                                                    .lineLimit(1)
                                                Spacer()
                                                Text(array[num].time)
                                                    .fontWeight(.medium)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color("SystemContrast2"))
                                                    .lineLimit(1)
                                            } else if array[num].type == "FREE" {
                                                Text(array[num].name)
                                                    .fontWeight(.semibold)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color("SystemContrast2"))
                                                    .lineLimit(1)
                                                Spacer()
                                                Text(array[num].time)
                                                    .fontWeight(.medium)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color("SystemContrast2"))
                                                    .lineLimit(1)
                                            } else {
                                                Text(array[num].name)
                                                    .fontWeight(.semibold)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color(colorScheme == .light ? UIColor(array[num].color).shaded(amount: 0.25) : UIColor(array[num].color).tinted(amount: 0.25)))
                                                    .lineLimit(1)
                                                Spacer()
                                                Text(array[num].time)
                                                    .fontWeight(.medium)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color(colorScheme == .light ? UIColor(array[num].color).shaded(amount: 0.25) : UIColor(array[num].color).tinted(amount: 0.25)))
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                }
                                if array.count > 4 {
                                    if array.count-4 == 1 {
                                        Text("+\(array.count-4) Class")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 11, weight: .medium))
                                    } else {
                                        Text("+\(array.count-4) Classes")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                } else {
                                    Spacer()
                                }
                            }
                        } else {
                            HStack {
                                Text("No Classes")
                                    .textCase(.uppercase)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color("SystemContrast2"))
                                Spacer()
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("Today")
                            .textCase(.uppercase)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("AccentColor"))
                        Spacer()
                        if getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Date(), format: "M/d/yyyy")) }) != 0 {
                            Image(systemName: "\(getRotation(blocks: scheduleBlocks.filter { $0.dates.contains(convertDatetoString(date: Date(), format: "M/d/yyyy")) })).circle")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color("AccentColor"))
                        }
                    }
                    if family == .systemLarge {
                        if let array = getWidgetBlockToday(size: family, blocks: scheduleBlocks, courses: courses, gradYear: gradYear) {
                            VStack(spacing: 5) {
                                ForEach(array, id: \.self) { block in
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
                                            Text(block.time)
                                                .font(.system(size: 15))
                                        }
                                        .padding(.horizontal)
                                        Spacer()
                                    }
                                    .background(block.freePeriod == true ? Color(.systemGray5) : Color(colorScheme == .dark ? UIColor(block.color).shaded(amount: 0.15) : UIColor(block.color).tinted(amount: 0.15)))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                            .padding(.top, 0.5)
                        } else {
                            HStack {
                                Text("No Classes")
                                    .textCase(.uppercase)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color("SystemContrast2"))
                                Spacer()
                            }
                        }
                    } else {
                        if let array = getWidgetBlockToday(size: family, blocks: scheduleBlocks, courses: courses, gradYear: gradYear) {
                            VStack(spacing: 5) {
                                ForEach(array.indices, id: \.self) { num in
                                    if num < 4 {
                                        HStack {
                                            Capsule()
                                                .foregroundStyle(array[num].freePeriod == true ? Color(.systemGray2) : Color(colorScheme == .light ? UIColor(array[num].color).shaded(amount: 0.15) : UIColor(array[num].color).tinted(amount: 0.15)))
                                                .frame(width: 4, height: 18)
                                            if array[num].freePeriod == true && array[num].type != "FREE" {
                                                Text("Free Period")
                                                    .fontWeight(.semibold)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color("SystemContrast2"))
                                                    .lineLimit(1)
                                                Spacer()
                                                Text(array[num].time)
                                                    .fontWeight(.medium)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color("SystemContrast2"))
                                                    .lineLimit(1)
                                            } else if array[num].type == "FREE" {
                                                Text(array[num].name)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(Color("SystemContrast2"))
                                                    .font(.system(size: 13))
                                                    .lineLimit(1)
                                                Spacer()
                                                Text(array[num].time)
                                                    .fontWeight(.medium)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color("SystemContrast2"))
                                                    .lineLimit(1)
                                            } else {
                                                Text(array[num].name)
                                                    .fontWeight(.semibold)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color(colorScheme == .light ? UIColor(array[num].color).shaded(amount: 0.25) : UIColor(array[num].color).tinted(amount: 0.25)))
                                                    .lineLimit(1)
                                                Spacer()
                                                Text(array[num].time)
                                                    .fontWeight(.medium)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color(colorScheme == .light ? UIColor(array[num].color).shaded(amount: 0.25) : UIColor(array[num].color).tinted(amount: 0.25)))
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                }
                                if array.count > 4 {
                                    if array.count-4 == 1 {
                                        Text("+\(array.count-4) Class")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 11, weight: .medium))
                                    } else {
                                        Text("+\(array.count-4) Classes")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                } else {
                                    Spacer()
                                }
                            }
                        } else {
                            HStack {
                                Text("No Classes")
                                    .textCase(.uppercase)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color("SystemContrast2"))
                                Spacer()
                            }
                        }
                    }
                }
            }.padding()
                .widgetURL(URL(string: "cpscampus://home")!)
        }
    }
}

struct ScheduleWidgetiOS: Widget {
    let kind: String = "ScheduleWidgetiOS"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ScheduleWidgetiOSEntryView(entry: entry)
                .accentColor(Color("AccentColor"))
                .background(Color("WidgetBackground"))
        }
        .configurationDisplayName("Schedule")
        .description("Check today's classes at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

