//
//  EventsView.swift
//  CPS Campus (iOS)
//
//  5/22/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import EventKit
import GoogleSignIn
import DynamicColor

//MARK: - Add Events View
struct AddEventsView: View {
    
    enum Semester { case fall; case spring }
    
    @Environment(\.presentationMode) var presentationMode
    @State var semester = Semester.fall
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBlocks = [Block]()
    
    @State var showOptions = false
    @State var showColors = false
    @State var allWeeks = false
    @State var showPortraitPDF = false
    @State var showLandscapePDF = false
    
    var body: some View {
        NavigationView {
            Form {
                if #available(iOS 16, *) {
                    Button(action: {
                        showPortraitPDF = true
                    }) {
                        Text("Export as Portrait PDF")
                    }.sheet(isPresented: $showPortraitPDF) {
                        PreviewController(url: render(portrait: true)).ignoresSafeArea(.all)
                    }
                    Button(action: {
                        showLandscapePDF = true
                    }) {
                        Text("Export as Landscape PDF")
                    }.sheet(isPresented: $showLandscapePDF) {
                        PreviewController(url: render(portrait: false)).ignoresSafeArea(.all)
                    }
                }
                Section(header: HStack {
                    Picker("Semester", selection: $semester) {
                        Text("Fall Semester").tag(Semester.fall)
                        Text("Spring Semester").tag(Semester.spring)
                    }
                    .labelsHidden()
                    .textCase(.none)
                    Spacer()
                }.padding(.leading, -10)) {
                    ForEach(scheduleBlocks.filter({$0.type == "HOLIDAY"}).sorted{convertStringtoDate(string: $0.dates.first ?? "", format: "M/d/yyyy") < convertStringtoDate(string: $1.dates.first ?? "", format: "M/d/yyyy")}, id: \.self) { event in
                        if (event.dates.first ?? "").contains(fallYear) && semester == .fall {
                            EventCell(event: CalendarEvent(title: event.title, startDate: convertStringtoDate(string: event.dates.sorted{convertStringtoDate(string: $0, format: "M/d/yyyy") < convertStringtoDate(string: $1, format: "M/d/yyyy")}.first ?? "", format: "M/d/yyyy"), endDate: convertStringtoDate(string: event.dates.sorted{convertStringtoDate(string: $0, format: "M/d/yyyy") < convertStringtoDate(string: $1, format: "M/d/yyyy")}.last ?? "", format: "M/d/yyyy"), isAllDay: true, location: "", notes: "", availability: 2))
                        } else if (event.dates.first ?? "").contains(springYear) && semester == .spring {
                            EventCell(event: CalendarEvent(title: event.title, startDate: convertStringtoDate(string: event.dates.sorted{convertStringtoDate(string: $0, format: "M/d/yyyy") < convertStringtoDate(string: $1, format: "M/d/yyyy")}.first ?? "", format: "M/d/yyyy"), endDate: convertStringtoDate(string: event.dates.sorted{convertStringtoDate(string: $0, format: "M/d/yyyy") < convertStringtoDate(string: $1, format: "M/d/yyyy")}.last ?? "", format: "M/d/yyyy"), isAllDay: true, location: "", notes: "", availability: 2))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Done").bold()
                    })
                }
            }
            .onAppear {
                if String(Calendar.current.component(.year, from: Date())) == springYear {
                    semester = .spring
                }
            }
        }
    }
    
    struct EventCell: View {
        
        let event: CalendarEvent
        
        @Environment(\.openURL) var openURL
        @State var showEvent = false
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .fontWeight(.medium)
                        .foregroundStyle(Color("SystemContrast"))
                    if event.startDate != event.endDate {
                        Text("\(convertDatetoString(date: event.startDate, format: "MMM d")) - \(convertDatetoString(date: event.endDate, format: "MMM d, YYYY"))")
                            .foregroundStyle(.gray)
                    } else {
                        Text(convertDatetoString(date: event.startDate, format: "MMMM d, YYYY"))
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
                Button(action: {
                    eventStore.requestAccess(to: .event, completion: {(granted: Bool, error: Error?) -> Void in })
                    showEvent = true
                }, label: {
                    Image(systemName: "calendar.badge.plus").font(.system(size: 22))
                })
            }
            .padding(.vertical, 7)
            .sheet(isPresented: $showEvent) {
                AddtoCalendarView(event: event)
            }
        }
    }
    
    @available(iOS 16.0, *)
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
}

//MARK: - Add to Calendar Sheet
struct AddtoCalendarView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    
    @State var event: CalendarEvent
    @SceneStorage("calendarID") var calendarID = eventStore.defaultCalendarForNewEvents?.calendarIdentifier ?? ""
    @SceneStorage("whichCalendar") var whichCalendar = "Apple"
    @SceneStorage("gCalID") var gCalID = "0"
    
    @State var sources = eventStore.sources
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var user = GIDSignIn.sharedInstance.currentUser
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $event.title)
                    TextField("Location or Meeting Link", text: $event.location)
                }
                Section {
                    Toggle("All-day", isOn: $event.isAllDay)
                    if event.isAllDay {
                        DatePicker("Starts", selection: $event.startDate, displayedComponents: .date)
                        DatePicker("Ends", selection: $event.endDate, displayedComponents: .date)
                    } else {
                        DatePicker("Starts", selection: $event.startDate, displayedComponents: [.date, .hourAndMinute])
                        DatePicker("Ends", selection: $event.endDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                .onChange(of: event.startDate) { _ in
                    if event.startDate > event.endDate {
                        event.endDate = event.startDate
                    }
                }
                .onChange(of: event.endDate) { _ in
                    if event.endDate < event.startDate {
                        event.startDate = event.endDate
                    }
                }
                Section(header: Text("**Calendar**"), footer: whichCalendar == "Apple" ? Text("CPS Campus will add the event to the selected calendar in the **Calendar** app.") : Text("CPS Campus will redirect this event to the selected Google Account in the **Google Calendar** app. You can further customize and save the event there.")) {
                    Picker("Type", selection: $whichCalendar) {
                        Text("Apple").tag("Apple")
                        Text("Google").tag("Google")
                    }.pickerStyle(.segmented)
                        .labelsHidden()
                        .padding(.vertical, 5)
                    if whichCalendar == "Google" {
                        Picker("Account", selection: $gCalID) {
                            if authViewModel.state == .signedIn {
                                HStack {
                                    AsyncImage(url: user?.profile?.imageURL(withDimension: 200)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color("AccentColor")
                                    }
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    Text("\((user?.profile?.email ?? "NilEmail").replacingOccurrences(of: "@thecollegepreparatoryschool.org", with: "@college-prep.org"))")
                                }.padding(.vertical, 5).tag(user?.profile?.email ?? "School")
                            } else {
                                Text("Default Account").tag("0")
                                Text("Secondary Account").tag("1")
                                Text("Tertiary Account").tag("2")
                            }
                        }.pickerStyle(.inline)
                            .labelsHidden()
                    }
                }
                if whichCalendar == "Apple" {
                    if EKEventStore.authorizationStatus(for: .event) != .authorized {
                        Section(footer: Text("Campus requires permission to add events to Calendar.")) {
                            Button(action: {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }, label: {
                                Text("Update Permissions in Settings")
                            })
                        }
                    } else {
                        ForEach(sources.filter{( $0.calendars(for: .event).filter({ $0.allowsContentModifications == true}).isEmpty == false )}.sorted(by: { $0.title.caseInsensitiveCompare($1.title) == .orderedAscending }), id: \.self) { source in
                            Section(header: Text(source.title)) {
                                ForEach(source.calendars(for: .event).filter({ $0.allowsContentModifications == true }).sorted(by: { $0.title.caseInsensitiveCompare($1.title) == .orderedAscending }), id: \.self) { calendar in
                                    Button(action: {
                                        calendarID = calendar.calendarIdentifier
                                    }, label: {
                                        HStack {
                                            Image(systemName: "app.fill")
                                                .foregroundStyle(Color(UIColor(cgColor: calendar.cgColor)))
                                            Text(calendar.title)
                                                .foregroundStyle(Color("SystemContrast"))
                                            if calendarID == calendar.calendarIdentifier {
                                                Spacer()
                                                Image(systemName: "checkmark").font(Font.body.weight(.medium))
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if whichCalendar == "Apple" {
                            createiCalendarEvent(input: event, calendarID: calendarID)
                        } else {
                            openURL(createGCalEvent(input: event, account: gCalID))
                        }
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Add").bold()
                    }).disabled(event.title.isEmpty)
                        .disabled(EKEventStore.authorizationStatus(for: .event) != .authorized && whichCalendar == "Apple")
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if user != nil {
                    authViewModel.signIn()
                }
            }
            user = GIDSignIn.sharedInstance.currentUser
            if authViewModel.state == .signedIn {
                gCalID = user?.profile?.email ?? "0"
            }
            eventStore.requestAccess(to: .event, completion: {(granted: Bool, error: Error?) -> Void in
                if granted {
                    sources = eventStore.sources
                } else {
                    consoleLogger.error("calendar access error > \(error, privacy: .public)")
                }
            })
        }
    }
}

struct AddtoClubsCalendarView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("ScheduleBlocks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var blocks = [Block]()
    
    let club: Club
    let leaders: [String]
    
    @State var title = ""
    @State var location = ""
    @State var bakeSale = false
    @State var time = "Lunch"
    
    @State var startTime = Date()
    @State var endTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @State var date = Date()
    
    @State var startDateString = convertDatetoString(date: Date(), format: "yyyy-MM-dd-")+convertDatetoString(date: Date(), format: "HH:mm")
    @State var endDateString = convertDatetoString(date: Date(), format: "yyyy-MM-dd-")+convertDatetoString(date: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(), format: "HH:mm")
    
    @Binding var campusID: User?
    @State var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(footer: Text("Your club's name will be automatically added to the event title if not included.")) {
                        HStack(spacing: 15) {
                            Image(systemName: "character.cursor.ibeam")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(Color(.white))
                                .frame(width: 32, height: 32)
                                .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color)))
                            TextField("Title", text: $title)
                                .font(Font.body.weight(.medium))
                                .submitLabel(.done)
                                .onChange(of: title) { _ in
                                    if !title.contains(club.name) && !title.contains(club.nickname) {
                                        title = club.nickname == "" ? club.name + " Meeting" : club.nickname + " Meeting"
                                    }
                                }
                                .disabled(bakeSale)
                                .foregroundStyle(bakeSale ? Color(.gray) : Color("SystemContrast"))
                        }.padding(.vertical, 5)
                        if !bakeSale {
                            HStack(spacing: 15) {
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color(.white))
                                    .frame(width: 32, height: 32)
                                    .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(Color(.gray)))
                                TextField("Proposed Room", text: $location)
                                    .font(Font.body.weight(.medium))
                            }.padding(.vertical, 5)
                        }
                        Toggle(isOn: $bakeSale, label: {
                            HStack(spacing: 15) {
                                Image(systemName: "birthday.cake.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color(.white))
                                    .frame(width: 32, height: 32)
                                    .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(Color(hexString: "FFABC1")))
                                Text("Bake Sale").fontWeight(.medium)
                            }.padding(.vertical, 5)
                        })
                        .onChange(of: bakeSale) { _ in
                            if bakeSale {
                                title = club.nickname == "" ? club.name + " Bake Sale" : club.nickname + " Bake Sale"
                            } else {
                                title = club.nickname == "" ? club.name + " Meeting" : club.nickname + " Meeting"
                            }
                        }
                    }
                    if !bakeSale {
                        Section {
                            Picker(selection: $time) {
                                if blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Lunch" }).count > 0 {
                                    Text("Lunch").tag("Lunch")
                                }
                                if blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Faculty Collab" }).count > 0 {
                                    Text("Faculty Collab").tag("Faculty Collab")
                                }
                                Text("Custom").tag("Custom")
                            } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(Color(.white))
                                        .frame(width: 32, height: 32)
                                        .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(Color(hexString: "FFD300")))
                                    VStack(alignment: .leading) {
                                        Text("Time").fontWeight(.medium)
                                        if time == "Custom" {
                                            HStack(spacing: 5) {
                                                DatePicker("Starts", selection: $startTime, displayedComponents: .hourAndMinute).labelsHidden()
                                                DatePicker("Ends", selection: $endTime, displayedComponents: .hourAndMinute).labelsHidden()
                                            }.scaleEffect(0.8, anchor: .topLeading).padding(.top, -7)
                                        }
                                    }
                                }.padding(.vertical, 5)
                            }
                            .pickerStyle(.menu)
                            .onChange(of: time) { _ in
                                if time == "Lunch" && blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Lunch" }).count == 0 {
                                    time = "Custom"
                                } else if time == "Lunch" {
                                    startDateString = convertDatetoString(date: date, format: "yyyy-MM-dd-")+blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Lunch" })[0].startTime
                                    endDateString = convertDatetoString(date: date, format: "yyyy-MM-dd-")+blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Lunch" })[0].endTime
                                }
                                if time == "Faculty Collab" && blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Faculty Collab" }).count == 0 {
                                    time = "Custom"
                                } else if time == "Faculty Collab" {
                                    startDateString = convertDatetoString(date: date, format: "yyyy-MM-dd-")+blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Faculty Collab" })[0].startTime
                                    endDateString = convertDatetoString(date: date, format: "yyyy-MM-dd-")+blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Faculty Collab" })[0].endTime
                                }
                            }
                            .onAppear {
                                if time == "Lunch" && blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Lunch" }).count == 0 {
                                    time = "Custom"
                                } else if time == "Lunch" {
                                    startDateString = convertDatetoString(date: date, format: "yyyy-MM-dd-")+blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Lunch" })[0].startTime
                                    endDateString = convertDatetoString(date: date, format: "yyyy-MM-dd-")+blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Lunch" })[0].endTime
                                }
                            }
                        }
                        .onChange(of: startTime) { _ in
                            if startTime > endTime {
                                endTime = startTime
                            }
                            startDateString = convertDatetoString(date: date, format: "yyyy-MM-dd-")+convertDatetoString(date: startTime, format: "HH:mm")
                        }
                        .onChange(of: endTime) { _ in
                            if endTime < startTime {
                                startTime = endTime
                            }
                            endDateString = convertDatetoString(date: date, format: "yyyy-MM-dd-")+convertDatetoString(date: endTime, format: "HH:mm")
                        }
                    }
                    Section {
                        HStack(spacing: 15) {
                            Image(systemName: "calendar")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(Color(.white))
                                .frame(width: 32, height: 32)
                                .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(Color("AccentColor")))
                            VStack(alignment: .leading) {
                                Text("Date").fontWeight(.medium)
                                Text(convertDatetoString(date: date, format: "EEEE, MMMM d, yyyy"))
                                    .font(.system(size: 14))
                            }
                        }.padding(.vertical, 5)
                        CalendarPicker(date: $date)
                            .frame(height: 400)
                            .padding(-15)
                    }
                }
                .tint(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                Button(action: {
                    var calendarLink = "https://www.calendar.google.com"
                    if bakeSale {
                        let recipient = "stevec@college-prep.org"
                        if bakeSale {
                            calendarLink = String("https://www.google.com/calendar/u/\(recipient)/event?action=TEMPLATE&dates=\(reformatDateString(date: startDateString, currentDateFormat: "yyyy-MM-dd-HH:mm", newDateFormat: "YYYYMMdd"))/\(reformatDateString(date: endDateString, currentDateFormat: "yyyy-MM-dd-HH:mm", newDateFormat: "YYYYMMdd"))&text=\(title.replacingOccurrences(of: " ", with: "+"))&location=\(location.replacingOccurrences(of: " ", with: "+"))")
                        } else {
                            calendarLink = String("http://www.google.com/calendar/u/\(recipient)/event?action=TEMPLATE&dates=\(reformatDateString(date: startDateString, currentDateFormat: "yyyy-MM-dd-HH:mm", newDateFormat: "YYYYMMdd'T'HHmm"))00%2F\(reformatDateString(date: endDateString, currentDateFormat: "yyyy-MM-dd-HH:mm", newDateFormat: "YYYYMMdd'T'HHmm"))00&text=\(title.replacingOccurrences(of: " ", with: "+"))&location=\(location.replacingOccurrences(of: " ", with: "+"))")
                        }
                        let emailBody = """
                        <p><a href="\(calendarLink)">Add Bake Sale to Clubs Calendar</a></p>
                        <p><strong>Bake Sale Details</strong></p>
                        <p>Club Name: \(club.name)<br />
                        Date: \(convertDatetoString(date: date, format: "EEEE, MMMM d, yyyy"))<br />
                        Leaders: \(club.leaders!.joined(separator: "@college-prep.org, "))@college-prep.org<br /><br />
                        Sent from CPS Campus<br />
                        Reply all to this email to contact the club<br />
                        Contact the <a href="mailto:iteam@thecollegepreparatoryschool.org">Innovation Team</a> for assistance</p>
                        """
                        sendEmail(email: Email(to: [recipient], cc: [], bcc: [], replyTo: leaders, subject: "\(club.nickname.isEmpty ? club.name : club.nickname) - Bake Sale Request", body: emailBody, type: "BAKE SALE REQUEST"), completion: {
                            showAlert = true
                        })
                    } else {
                        let recipient = "manisha@college-prep.org"
                        if bakeSale {
                            calendarLink = String("https://www.google.com/calendar/u/\(recipient)/event?action=TEMPLATE&dates=\(reformatDateString(date: startDateString, currentDateFormat: "yyyy-MM-dd-HH:mm", newDateFormat: "YYYYMMdd"))/\(reformatDateString(date: endDateString, currentDateFormat: "yyyy-MM-dd-HH:mm", newDateFormat: "YYYYMMdd"))&text=\(title.replacingOccurrences(of: " ", with: "+"))&location=\(location.replacingOccurrences(of: " ", with: "+"))")
                        } else {
                            calendarLink = String("http://www.google.com/calendar/u/\(recipient)/event?action=TEMPLATE&dates=\(reformatDateString(date: startDateString, currentDateFormat: "yyyy-MM-dd-HH:mm", newDateFormat: "YYYYMMdd'T'HHmm"))00%2F\(reformatDateString(date: endDateString, currentDateFormat: "yyyy-MM-dd-HH:mm", newDateFormat: "YYYYMMdd'T'HHmm"))00&text=\(title.replacingOccurrences(of: " ", with: "+"))&location=\(location.replacingOccurrences(of: " ", with: "+"))")
                        }
                        let emailBody = """
                        <p><a href="\(calendarLink)">Add Meeting to Clubs Calendar</a></p>
                        <p><strong>Meeting Details</strong></p>
                        <p>Club Name: \(club.name)<br />
                        Proposed Room: \(location)<br />
                        Date: \(convertDatetoString(date: date, format: "EEEE, MMMM d, yyyy"))<br />
                        Time: \(convertDatetoString(date: startTime, format: "h:mm")) - \(convertDatetoString(date: endTime, format: "h:mm"))<br />
                        Leaders: \(club.leaders!.joined(separator: "@college-prep.org, "))@college-prep.org<br /><br />
                        Sent from CPS Campus<br />
                        Reply all to this email to contact the club<br />
                        Contact the <a href="mailto:iteam@thecollegepreparatoryschool.org">Innovation Team</a> for assistance</p>
                        """
                        sendEmail(email: Email(to: [recipient], cc: [], bcc: [], replyTo: leaders, subject: "\(club.nickname.isEmpty ? club.name : club.nickname) - Club Meeting Request", body: emailBody, type: "CLUB MEETING REQUEST"), completion: {
                            showAlert = true
                        })
                    }
                }, label: {
                    HStack {
                        Spacer()
                        Text(bakeSale ? "Request Bake Sale" : "Request Meeting")
                            .bold()
                            .foregroundStyle(.white)
                            .dynamicTypeSize(.small ... .large)
                        Spacer()
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(hexString: club.color)))
                }).padding()
            }
            .navigationTitle(bakeSale ? "New Bake Sale" : "New Meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
            }
        }
        .navigationViewStyle(.stack)
        .alert(bakeSale ? "Bake Sale Requested" : "Meeting Requested", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        }, message: {
            Text("Please reach out to \(bakeSale ? "Steve Chabon" : "Manisha Kumar") if you have any questions or want to reschedule your request.")
        })
    }
}
