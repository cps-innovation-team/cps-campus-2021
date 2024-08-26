//
//  ScheduleView.swift
//  CPS Campus (iOS)
//
//  5/15/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import EventKit

struct ScheduleView: View {
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @State var date = Date()
    @State var weekday = Calendar.current.component(.weekday, from: Date())
    
    @State var showHolidays = false
    
    //MARK: Data Storage
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    
    //MARK: Preferences
    @AppStorage("ScheduleMode", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var mode = "Month"
    @AppStorage("PreservedScheduleMode", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var preservedMode = "Day"
    
    //MARK: Display Constants
    let weekwidth = CGFloat(125)
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if mode == "Day" {
                        TabView(selection: $weekday) {
                            VStack(spacing: 5) {
                                Text("It's the weekend!")
                                    .fontWeight(.bold)
                                    .font(.system(size: 30))
                                weekendDateHeader(weekday: 1, date: date)
                                Image("Geoffrey")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 300)
                                    .padding(.top)
                                Button(action: {
                                    date = weekRegress(date: date)
                                    let haptics = UIImpactFeedbackGenerator(style: .medium)
                                    haptics.impactOccurred()
                                }, label: {
                                    Text("Go back to last week")
                                        .fontWeight(.medium)
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color("AccentColor"))
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(idiom == .pad ? .systemGray5 : .systemGray6)))
                                }).buttonStyle(ScaleButtonStyle())
                            }.padding()
                                .tag(1)
                            SchedulePage(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 2, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 2)
                                .tag(2)
                            SchedulePage(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 3, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 3)
                                .tag(3)
                            SchedulePage(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 4, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 4)
                                .tag(4)
                            SchedulePage(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 5, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 5)
                                .tag(5)
                            SchedulePage(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 6, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 6)
                                .tag(6)
                            VStack(spacing: 5) {
                                Text("It's the weekend!")
                                    .fontWeight(.bold)
                                    .font(.system(size: 30))
                                weekendDateHeader(weekday: 7, date: date)
                                Image("Geoffrey")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 300)
                                    .padding(.top)
                                Button(action: {
                                    date = weekAdvance(date: date)
                                    let haptics = UIImpactFeedbackGenerator(style: .medium)
                                    haptics.impactOccurred()
                                }, label: {
                                    Text("Jump to next week")
                                        .fontWeight(.medium)
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color("AccentColor"))
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(idiom == .pad ? .systemGray5 : .systemGray6)))
                                }).buttonStyle(ScaleButtonStyle())
                            }.padding()
                                .tag(7)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                    else if mode == "Week" {
                        ScrollView(.horizontal, showsIndicators: false) {
                            ScrollViewReader { scrollView in 
                                HStack(spacing: 10) {
                                    ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 2, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 2)
                                        .frame(width: weekwidth)
                                        .id(2)
                                    ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 3, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 3)
                                        .frame(width: weekwidth)
                                        .id(3)
                                    ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 4, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 4)
                                        .frame(width: weekwidth)
                                        .id(4)
                                    ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 5, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 5)
                                        .frame(width: weekwidth)
                                        .id(5)
                                    ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 6, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 6)
                                        .frame(width: weekwidth)
                                        .id(6)
                                }.padding(.horizontal)
                                    .onAppear {
                                        withAnimation {
                                            if weekday > 4 {
                                                scrollView.scrollTo(weekday, anchor: .trailing)
                                            } else if weekday < 4 {
                                                scrollView.scrollTo(weekday, anchor: .center)
                                            } else {
                                                scrollView.scrollTo(weekday, anchor: .center)
                                            }
                                        }
                                    }
                            }
                            //                            .onChange(of: date) { _ in
                            //                                withAnimation {
                            //                                    if weekday > 4 {
                            //                                        scrollView.scrollTo(weekday, anchor: .trailing)
                            //                                    } else if weekday < 4 {
                            //                                        scrollView.scrollTo(weekday, anchor: .trailing)
                            //                                    } else {
                            //                                        scrollView.scrollTo(weekday, anchor: .center)
                            //                                    }
                            //                                }
                            //                            }
                        }
                    }
                    else if mode == "Month" {
                        CalendarPicker(date: $date)
                    }
                }
            }
            .onChange(of: mode) { _ in
                if mode != "Month" {
                    preservedMode = mode
                }
            }
            .onChange(of: date, perform: { _ in
                weekday = Calendar.current.component(.weekday, from: date)
                mode = preservedMode
            })
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(id: "Today", placement: .navigationBarLeading, showsByDefault: true) {
                    Button(action: {
                        date = Date()
                        let haptics = UIImpactFeedbackGenerator(style: .medium)
                        haptics.impactOccurred()
                    }, label: {
                        Text("Today").fontWeight(.medium)
                    })
                }
                ToolbarItem(id: "Mode", placement: .principal, showsByDefault: true) {
                    Picker("Mode", selection: $mode, content: {
                        Text("Day").tag("Day")
                        Text("Week").tag("Week")
                        Text("Month").tag("Month")
                    })
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .frame(width: 225)
                }
                ToolbarItem(id: "Add to Calendar", placement: .navigationBarTrailing, showsByDefault: true) {
                    HStack {
                        Button(action: {
                            showHolidays = true
                        }, label: {
                            Image(systemName: "square.and.arrow.up").font(Font.body.weight(.medium))
                        })
                    }
                }
            }
            .sheet(isPresented: $showHolidays) {
                AddEventsView()
            }
        }
    }
}

struct ScheduleViewiPadOS: View {
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    @Environment(\.sizeCategory) var sizeCategory
    
    @SceneStorage("date") var date = Date()
    @State var weekday = Calendar.current.component(.weekday, from: Date())
    
    @State var showDatePicker = false
    @State var showHolidays = false
    
    //MARK: Data Storage
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    
    //MARK: Preferences
    @AppStorage("ScheduleMode", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var mode = "Day"
    @AppStorage("PreservedScheduleMode", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var preservedMode = "Day"
    
    //MARK: Display Constants
    let weekwidth = CGFloat(125)
    
    var body: some View {
        ZStack {
            HStack(spacing: 10) {
                ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 2, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 2)
                ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 3, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 3)
                ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 4, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 4)
                ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 5, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 5)
                ScheduleStack(blocks: scheduleBlocks, date: $date, inheritedDate: convertDatetoString(date: createAllDayDate(weekday: 6, weekOfYear: Calendar.current.component(.weekOfYear, from: date), year: Calendar.current.component(.year, from: date)), format: "M/d/yyyy"), weekday: 6)
                
            }.padding(.horizontal)
        }
        .onChange(of: date, perform: { _ in
            weekday = Calendar.current.component(.weekday, from: date)
            mode = preservedMode
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Schedule")
        .toolbar {
            ToolbarItem(id: "Previous Week", placement: .navigationBarTrailing, showsByDefault: true) {
                Button(action: {
                    var dateComponent = DateComponents()
                    dateComponent.weekOfYear = -1
                    date = Calendar.current.date(byAdding: dateComponent, to: date) ?? date
                }) {
                    Image(systemName: "chevron.left")
                }
                .keyboardShortcut(KeyEquivalent.leftArrow, modifiers: [])
                .help("Previous Week")
            }
            ToolbarItem(id: "Today", placement: .navigationBarTrailing, showsByDefault: true) {
                Button(action: {
                    date = Date()
                    let haptics = UIImpactFeedbackGenerator(style: .medium)
                    haptics.impactOccurred()
                }, label: {
                    Text("Today")
                })
                .keyboardShortcut(KeyEquivalent("t"), modifiers: [.command])
                .help("⌘T")
            }
            ToolbarItem(id: "Next Week", placement: .navigationBarTrailing, showsByDefault: true) {
                Button(action: {
                    var dateComponent = DateComponents()
                    dateComponent.weekOfYear = 1
                    date = Calendar.current.date(byAdding: dateComponent, to: date) ?? date
                }) {
                    Image(systemName: "chevron.right")
                }
                .keyboardShortcut(KeyEquivalent.rightArrow, modifiers: [])
                .help("Next Week")
            }
            ToolbarItem(id: "Date Picker", placement: .navigationBarTrailing, showsByDefault: true) {
                HStack {
                    Button(action: {
                        withAnimation {
                            showDatePicker.toggle()
                            let haptics = UIImpactFeedbackGenerator(style: .medium)
                            haptics.impactOccurred()
                        }
                    }, label: {
                        Image(systemName: "calendar").font(Font.body.weight(.medium))
                    })
                    .popover(isPresented: $showDatePicker, arrowEdge: .top) {
                        CalendarPicker(date: $date).frame(minWidth: 400)
                    }
                    Button(action: {
                        showHolidays = true
                    }, label: {
                        Image(systemName: "square.and.arrow.up").font(Font.body.weight(.medium))
                    })
                    .padding(.leading, 5)
                    .popover(isPresented: $showHolidays, arrowEdge: .top) {
                        AddEventsView().frame(minWidth: 400, minHeight: 600)
                    }
                }
            }
        }
    }
}
