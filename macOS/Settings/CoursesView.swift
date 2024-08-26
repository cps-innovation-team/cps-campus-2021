//
//  CoursesView.swift
//  CPS Campus (macOS)
//
//  4/23/2021
//  Designed by Rahim Malik in California.
//

import SwiftUI
import WidgetKit

struct CourseSubview: View {
    
    //MARK: Course and Schedule Data
    @Binding var course: Course
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses = defaultCourses
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    
    //MARK: Environment
    @Environment(\.openURL) private var openURL
    
    @State var compassBlock: String
    @State var visibleRotations: Int
    @State var isFreePeriod: Bool
    
    @State var name: String
    @State var teacher: String
    @State var room: String
    @State var color: Color
    
    //MARK: Settings
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    @AppStorage("NotificationSettings", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var notificationSettings: [String: Double] = ["ClassStarts": 1.0, "ClassEnds": 0.0, "ClubMeetingStarts": 1.0, "SportGameStarts": 1.0, "ClassMinutes": 5.0, "ClubMinutes": 5.0, "SportMinutes": 45.0]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                Spacer().frame(height: 10)
                VStack {
                    if isFreePeriod {
                        HStack {
                            TextField("Name", text: .constant("Free Period"))
                                .textFieldStyle(.plain)
                                .font(Font.largeTitle.weight(.bold))
                                .foregroundStyle(Color(.gray))
                                .disabled(true)
                            Spacer()
                            Text("UNTOGGLE TO EDIT").fontWeight(.medium).foregroundStyle(.gray)
                        }.padding(.bottom, 8.5)
                    } else {
                        HStack {
                            TextField("Name", text: $name, onCommit: {
                                course.name = name
                            })
                            .textFieldStyle(.plain)
                            .font(Font.largeTitle.weight(.bold))
                            Spacer()
                            Text("CLICK NAME TO EDIT").fontWeight(.medium).foregroundStyle(.gray)
                        }.padding(.bottom, 8.5)
                    }
                    if !(noTeachers.contains(course.id) && noRooms.contains(course.id)) {
                        VStack(spacing: 0) {
                            if noTeachers.contains(course.id) == false {
                                if course.id == "Advising" {
                                    TextField("Advisor", text: $teacher, onCommit: {
                                        course.teacher = teacher
                                    })
                                    .font(.system(size: 15))
                                    .textFieldStyle(.plain)
                                    .padding(.bottom)
                                    .disabled(isFreePeriod)
                                } else {
                                    TextField("Teacher", text: $teacher, onCommit: {
                                        course.teacher = teacher
                                    })
                                    .font(.system(size: 15))
                                    .textFieldStyle(.plain)
                                    .padding(.bottom)
                                    .disabled(isFreePeriod)
                                }
                            }
                            if noRooms.contains(course.id) == false {
                                Divider()
                                TextField("Room", text: $room, onCommit: {
                                    course.room = room
                                })
                                .font(.system(size: 15))
                                .textFieldStyle(.plain)
                                .padding(.top)
                                .disabled(isFreePeriod)
                            }
                        }.borderedCellStyle()
                    }
                }
                if coursesGroup.contains(course.id) {
                    VStack {
                        HStack {
                            Text("DISPLAY").fontWeight(.medium).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.leading)
                        VStack(spacing: 0) {
                            HStack {
                                Text("Always Free Period")
                                    .font(.system(size: 15))
                                Spacer()
                                Toggle("Always Free Period", isOn: $isFreePeriod)
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                            }
                            .padding(.bottom)
                            Divider()
                            HStack {
                                Text("Rotations").font(.system(size: 15))
                                Spacer()
                                Picker(String(visibleRotations), selection: $visibleRotations) {
                                    Text("All Rotations").tag(0)
                                    if rotation1and3Group.contains(course.id) {
                                        Text("Day 1").tag(1)
                                        Text("Day 3").tag(3)
                                    } else {
                                        Text("Day 2").tag(2)
                                        Text("Day 4").tag(4)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(maxWidth: 200)
                            }
                            .padding(.top)
                        }.borderedCellStyle()
                        HStack {
                            Text("Configure for which rotations **\(name)** will be displayed. All other rotations will be displayed as a **Free Period.**")
                            Spacer()
                        }.padding([.leading,.bottom]).foregroundStyle(.gray)
                    }
                    if compassGradYears.contains(gradYear) {
                        if let compass = getOptionalCoursefromID(courseID: "Compass", courses: courses) {
                            if compass.compassBlock == compassBlock && compass.visibleRotations == visibleRotations {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.system(size: 20))
                                        .frame(width: 25, height: 25)
                                        .padding(.trailing, 5)
                                    Text("**\(compass.name)** is currently using this block and rotation so **\(name)** will never be displayed")
                                        .font(.system(size: 15))
                                    Spacer()
                                    Button(action: {
                                        openURL(URL(string: "cpscampus://compass")!)
                                    }, label: {
                                        Text("Edit **\(compass.name)**")
                                    })
                                }.tintedCellStyle(color: .yellow)
                            } else if compass.compassBlock == compassBlock {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(Color(hexString: getCoursefromID(courseID: "Compass", courses: courses).color))
                                        .font(.system(size: 20))
                                        .frame(width: 25, height: 25)
                                        .padding(.trailing, 5)
                                    if isFreePeriod {
                                        Text("**\(compass.name)** will be displayed instead of **Free Period** on **Day \(compass.visibleRotations)**")
                                            .font(.system(size: 15))
                                    } else {
                                        Text("**\(compass.name)** will be displayed instead of **\(name)** on **Day \(compass.visibleRotations)**")
                                            .font(.system(size: 15))
                                    }
                                    Spacer()
                                    Button(action: {
                                        openURL(URL(string: "cpscampus://compass")!)
                                    }, label: {
                                        Text("Edit **\(compass.name)**")
                                    })
                                }.tintedCellStyle(color: Color(hexString: compass.color))
                            }
                        }
                    }
                } else if course.id == "Compass" {
                    VStack {
                        HStack {
                            Text("DISPLAY").fontWeight(.medium).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.leading)
                        VStack(spacing: 0) {
                            HStack {
                                Text("Block").opacity(0.5).font(.system(size: 15))
                                Spacer()
                                Picker(compassBlock, selection: $compassBlock) {
                                    ForEach(coursesGroup, id: \.self) { courseID in
                                        Text(courseID)
                                            .tag(courseID)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(maxWidth: 200)
                            }
                            .padding(.bottom)
                            Divider()
                            HStack {
                                Text("Rotations").opacity(0.5)
                                Spacer()
                                Picker(String(visibleRotations), selection: $visibleRotations) {
                                    Text("Day 1").tag(1)
                                    Text("Day 2").tag(2)
                                    Text("Day 3").tag(3)
                                    Text("Day 4").tag(4)
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(maxWidth: 200)
                            }
                            .padding(.top)
                        }.borderedCellStyle()
                        HStack {
                            Text("Configure for which block and rotation **\(name)** will be displayed. All other rotations will be displayed as your **\(compassBlock)** course, **\(getCoursefromID(courseID: compassBlock, courses: courses).name)**.")
                            Spacer()
                        }.padding([.leading,.bottom]).foregroundStyle(.gray)
                    }
                    if rotation1and3Group.contains(compassBlock) && [2,4].contains(visibleRotations) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                                .font(.system(size: 20))
                                .frame(width: 25, height: 25)
                                .padding(.trailing, 5)
                            Text("**\(compassBlock)** occurs on **Day 1 and Day 3** not **Day \(visibleRotations)**")
                                .font(.system(size: 15))
                            Spacer()
                        }.tintedCellStyle(color: .yellow)
                    } else if rotation2and4Group.contains(compassBlock) && [1,3].contains(visibleRotations) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                                .font(.system(size: 20))
                                .frame(width: 25, height: 25)
                                .padding(.trailing, 5)
                            Text("**\(compassBlock)** occurs on **Day 2 and Day 4** not **Day \(visibleRotations)**")
                                .font(.system(size: 15))
                            Spacer()
                        }.tintedCellStyle(color: .yellow)
                    } else {
                        if getCoursefromID(courseID: compassBlock, courses: courses).compassBlock == compassBlock && getCoursefromID(courseID: compassBlock, courses: courses).visibleRotations == visibleRotations {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.system(size: 20))
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 5)
                                Text("**\(name)** will override your **\(compassBlock)** course on **Day \(visibleRotations)** so **\(getCoursefromID(courseID: compassBlock, courses: courses).name)** will never be displayed")
                                    .font(.system(size: 15))
                                Spacer()
                                Button(action: {
                                    openURL(URL(string: "cpscampus://\(compassBlock)")!)
                                }, label: {
                                    Text("Edit **\(getCoursefromID(courseID: compassBlock, courses: courses).name)**")
                                })
                            }.tintedCellStyle(color: .yellow)
                        } else {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(Color(hexString: getCoursefromID(courseID: "Compass", courses: courses).color))
                                    .font(.system(size: 20))
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 5)
                                if getCoursefromID(courseID: compassBlock, courses: courses).isFreePeriod {
                                    Text("**\(name)** will be displayed instead of **Free Period** on **Day \(visibleRotations)**")
                                        .font(.system(size: 15))
                                } else {
                                    Text("**\(name)** will be displayed instead of **\(getCoursefromID(courseID: compassBlock, courses: courses).name)** on **Day \(visibleRotations)**")
                                        .font(.system(size: 15))
                                }
                                Spacer()
                                Button(action: {
                                    openURL(URL(string: "cpscampus://\(compassBlock)")!)
                                }, label: {
                                    Text("Edit **\(getCoursefromID(courseID: compassBlock, courses: courses).name)**")
                                })
                            }.tintedCellStyle(color: Color(hexString: getCoursefromID(courseID: "Compass", courses: courses).color))
                        }
                    }
                }
                if course.id == "Advising" && gradYear != freshClass {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(Color(hexString: getCoursefromID(courseID: "Advising", courses: courses).color))
                                .font(.system(size: 20))
                                .frame(width: 25, height: 25)
                                .padding(.trailing, 5)
                            Text("**Open** will be displayed on Thursdays when you have free time instead of **Advising**")
                                .font(.system(size: 15))
                            Spacer()
                        }
                    }.tintedCellStyle(color: color)
                } else if course.id == "X-Block" {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(Color(hexString: getCoursefromID(courseID: "X-Block", courses: courses).color))
                                .font(.system(size: 20))
                                .frame(width: 25, height: 25)
                                .padding(.trailing, 5)
                            Text("**Open** will be displayed on Mondays when you have free time instead of **X-Block**")
                                .font(.system(size: 15))
                            Spacer()
                        }
                    }.tintedCellStyle(color: Color(hexString: getCoursefromID(courseID: "X-Block", courses: courses).color))
                }
                VStack {
                    HStack {
                        Text("STYLE").fontWeight(.medium).foregroundStyle(.gray)
                        Spacer()
                    }.padding(.leading)
                    VStack(spacing: 0) {
                        if isFreePeriod {
                            HStack {
                                Text("Color").font(.system(size: 15))
                                Spacer()
                                ColorPicker("Color", selection: .constant(Color(.gray)), supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                                    .opacity(0.5)
                                    .disabled(true)
                            }
                            .padding(.bottom)
                        } else {
                            HStack {
                                Text("Color").font(.system(size: 15))
                                Spacer()
                                ColorPicker("Color", selection: $color, supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            }
                            .padding(.bottom)
                        }
                        Divider()
                        HStack {
                            Button(action: {
                                openURL(URL(string: "cpscampus://settings/palettes")!)
                            }, label: {
                                Text("Palettes")
                            })
                            Spacer()
                        }.padding(.top)
                    }.borderedCellStyle()
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(course.id)
        .background(Color("SystemWindow"))
        .onDisappear(perform: {
            course.name = name
            course.teacher = teacher
            course.room = room
            WidgetCenter.shared.reloadAllTimelines()
        })
        .onChange(of: color, perform: { _ in
            course.color = NSColor(color).toHexString()
            WidgetCenter.shared.reloadAllTimelines()
        })
        .onChange(of: compassBlock) { _ in
            course.compassBlock = compassBlock
        }
        .onChange(of: visibleRotations) { _ in
            if visibleRotations != 0 {
                isFreePeriod = false
            }
            course.visibleRotations = visibleRotations
        }
        .onChange(of: isFreePeriod, perform: { _ in
            if isFreePeriod {
                visibleRotations = 0
            }
            course.isFreePeriod = isFreePeriod
        })
    }
}
