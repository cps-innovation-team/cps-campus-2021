//
//  EventsView.swift
//  CPS Campus (macOS)
//
//  7/12/2022
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import GoogleSignIn
import EventKit
import DynamicColor

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
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    VStack {
                        TextField("Name", text: $event.title)
                            .textFieldStyle(.roundedBorder)
                            .labelsHidden()
                        TextField("Location or Meeting Link", text: $event.location)
                            .textFieldStyle(.roundedBorder)
                            .labelsHidden()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("SystemEnvironment").opacity(0.25)))
                    VStack {
                        HStack {
                            Text("All-day")
                            Spacer()
                            Toggle("All-day", isOn: $event.isAllDay)
                                .toggleStyle(.switch)
                                .labelsHidden()
                        }
                        if event.isAllDay {
                            HStack {
                                Text("Starts")
                                Spacer()
                                DatePicker("Starts", selection: $event.startDate, displayedComponents: .date)
                                    .frame(maxWidth: 150)
                                    .labelsHidden()
                            }
                            HStack {
                                Text("Ends")
                                Spacer()
                                DatePicker("Ends", selection: $event.endDate, displayedComponents: .date)
                                    .frame(maxWidth: 150)
                                    .labelsHidden()
                            }
                        } else {
                            HStack {
                                Text("Starts")
                                Spacer()
                                DatePicker("Starts", selection: $event.startDate, displayedComponents: [.date, .hourAndMinute])
                                    .frame(maxWidth: 150)
                                    .labelsHidden()
                            }
                            HStack {
                                Text("Ends")
                                Spacer()
                                DatePicker("Ends", selection: $event.endDate, displayedComponents: [.date, .hourAndMinute])
                                    .frame(maxWidth: 150)
                                    .labelsHidden()
                            }
                        }
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("SystemEnvironment").opacity(0.25)))
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
                    VStack {
                        Picker("Type", selection: $whichCalendar) {
                            Text("Apple").tag("Apple")
                            Text("Google").tag("Google")
                        }.pickerStyle(.segmented)
                            .labelsHidden()
                        if whichCalendar == "Google" {
                            VStack(spacing: 0) {
                                if authViewModel.state == .signedIn {
                                    Button(action: {
                                        gCalID = user?.profile?.email ?? "0"
                                    }, label: {
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
                                            Spacer()
                                            Image(systemName: "checkmark")
                                                .font(Font.title3.weight(.semibold))
                                                .foregroundStyle(Color("AccentColor"))
                                        }
                                        .padding(12.5)
                                        .background(Color("SystemEnvironment").opacity(0.25))
                                    }).buttonStyle(.plain)
                                } else {
                                    ForEach([(label: "Default Account", value: "0"), (label: "Secondary Account", value: "1"), (label: "Tertiary Account", value: "2")], id: \.label) { account in
                                        Button(action: {
                                            gCalID = account.value
                                        }, label: {
                                            HStack {
                                                Text(account.label)
                                                Spacer()
                                                if gCalID == account.value {
                                                    Image(systemName: "checkmark")
                                                        .font(Font.title3.weight(.semibold))
                                                        .foregroundStyle(Color("AccentColor"))
                                                }
                                            }
                                            .padding(12.5)
                                            .background(Color("SystemEnvironment").opacity(0.25))
                                        }).buttonStyle(.plain)
                                        if account.label != "Tertiary Account" {
                                            Divider()
                                        }
                                    }
                                }
                            }.clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                .padding(.vertical, 5)
                            HStack {
                                Text("CPS Campus will redirect this event to the selected Google Account in the **Google Calendar** app. You can further customize and save the event there.").font(.caption)
                                Spacer()
                            }.padding(.horizontal, 10)
                        }
                    }.padding(.vertical, 5)
                    if whichCalendar == "Apple" {
                        if EKEventStore.authorizationStatus(for: .event) != .authorized {
                            VStack {
                                Button(action: {
                                    openURL(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars")!)
                                }, label: {
                                    HStack {
                                        Text("Update Permissions in Settings").foregroundStyle(Color("AccentColor"))
                                        Spacer()
                                    }
                                })
                                .buttonStyle(.plain)
                                .padding(12.5)
                                .background(Color("SystemEnvironment").opacity(0.25))
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                HStack {
                                    Text("Campus requires permission to add events to Calendar.").font(.caption)
                                    Spacer()
                                }.padding(.horizontal, 10)
                                    .padding(.top, 5)
                            }
                        } else {
                            ForEach(sources.filter{( $0.calendars(for: .event).filter({ $0.allowsContentModifications == true}).isEmpty == false )}.sorted(by: { $0.title.caseInsensitiveCompare($1.title) == .orderedAscending }), id: \.self) { source in
                                VStack() {
                                    HStack {
                                        Text(source.title)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color("SystemContrast2"))
                                            .textCase(.uppercase)
                                        Spacer()
                                    }.padding(.horizontal)
                                    VStack(spacing: 0) {
                                        ForEach(source.calendars(for: .event).filter({ $0.allowsContentModifications == true }).sorted(by: { $0.title.caseInsensitiveCompare($1.title) == .orderedAscending }), id: \.self) { calendar in
                                            Button(action: {
                                                calendarID = calendar.calendarIdentifier
                                            }, label: {
                                                HStack {
                                                    Image(systemName: "app.fill")
                                                        .foregroundStyle(Color(calendar.color))
                                                    Text(calendar.title)
                                                    Spacer()
                                                    if calendarID == calendar.calendarIdentifier {
                                                        Image(systemName: "checkmark")
                                                            .font(Font.title3.weight(.semibold))
                                                            .foregroundStyle(Color("AccentColor"))
                                                    }
                                                }
                                                .padding(12.5)
                                                .background(Color("SystemEnvironment").opacity(0.25))
                                            }).buttonStyle(.plain)
                                            Divider()
                                        }
                                    }.clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                }.padding(.top, 5)
                            }
                            HStack {
                                Text("CPS Campus will add the event to the selected calendar in the **Calendar** app.").font(.caption)
                                Spacer()
                            }.padding(.horizontal, 10)
                                .padding(.top, 5)
                        }
                    }
                }.padding()
            }
            Divider()
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                })
                Spacer()
                Button(action: {
                    if whichCalendar == "Apple" {
                        createiCalendarEvent(input: event, calendarID: calendarID)
                    } else {
                        openURL(createGCalEvent(input: event, account: gCalID))
                    }
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Add Event")
                }).disabled(event.title.isEmpty)
                    .disabled(EKEventStore.authorizationStatus(for: .event) != .authorized && whichCalendar == "Apple")
                    .buttonStyle(.borderedProminent)
            }.padding()
        }
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
        VStack {
            ScrollView {
                VStack(spacing: 15) {
                    Spacer().frame(height: 5)
                    HStack {
                        TextField("Title", text: $title)
                            .textFieldStyle(.plain)
                            .font(Font.title.weight(.bold))
                            .minimumScaleFactor(0.75)
                            .padding(.leading)
                            .onChange(of: title) { _ in
                                if !title.contains(club.name) && !title.contains(club.nickname) {
                                    title = club.nickname == "" ? club.name + " Meeting" : club.nickname + " Meeting"
                                }
                            }
                            .disabled(bakeSale)
                            .foregroundStyle(bakeSale ? Color(.gray) : Color("SystemContrast"))
                        Spacer()
                    }.padding(.bottom, 5)
                    VStack(spacing: 0) {
                        if !bakeSale {
                            HStack(spacing: 15) {
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color(.white))
                                    .frame(width: 32, height: 32)
                                    .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(Color(.gray)))
                                TextField("Proposed Room", text: $location)
                                    .font(.system(size: 15, weight: .medium))
                                    .textFieldStyle(.plain)
                            }
                            Divider().padding(.vertical)
                        }
                        HStack(spacing: 15) {
                            Image(systemName: "birthday.cake.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(Color(.white))
                                .frame(width: 32, height: 32)
                                .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(Color(hexString: "FFABC1")))
                            Text("Bake Sale").fontWeight(.medium).font(.system(size: 15))
                            Spacer()
                            Toggle("", isOn: $bakeSale)
                                .labelsHidden()
                                .toggleStyle(.switch)
                        }
                        .onChange(of: bakeSale) { _ in
                            if bakeSale {
                                title = club.nickname == "" ? club.name + " Bake Sale" : club.nickname + " Bake Sale"
                            } else {
                                title = club.nickname == "" ? club.name + " Meeting" : club.nickname + " Meeting"
                            }
                        }
                    }.borderedCellStyle()
                    HStack {
                        Text("Your club's name will be automatically added to the event title if not included.")
                        Spacer()
                    }.padding([.leading,.bottom]).foregroundStyle(.gray).padding(.top, -5)
                    if !bakeSale {
                        HStack(spacing: 15) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(Color(.white))
                                .frame(width: 32, height: 32)
                                .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(Color(hexString: "FFD300")))
                            VStack(alignment: .leading) {
                                Text("Time").fontWeight(.medium).font(.system(size: 15))
                                if time == "Custom" {
                                    HStack(spacing: 5) {
                                        DatePicker("Starts", selection: $startTime, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .datePickerStyle(CompactDatePickerStyle())
                                        DatePicker("Ends", selection: $endTime, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .datePickerStyle(CompactDatePickerStyle())
                                    }.padding(.top, -5)
                                }
                            }
                            Spacer()
                            Picker("", selection: $time) {
                                if blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Lunch" }).count > 0 {
                                    Text("Lunch").tag("Lunch")
                                }
                                if blocks.filter({ $0.dates.contains(convertDatetoString(date: date, format: "M/d/yyyy")) && $0.title == "Faculty Collab" }).count > 0 {
                                    Text("Faculty Collab").tag("Faculty Collab")
                                }
                                Text("Custom").tag("Custom")
                            }.labelsHidden()
                        }
                        .borderedCellStyle()
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
                    VStack(spacing: 0) {
                        HStack(spacing: 15) {
                            Image(systemName: "calendar")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(Color(.white))
                                .frame(width: 32, height: 32)
                                .background(RoundedRectangle(cornerRadius: 7.5, style: .continuous).foregroundStyle(Color("AccentColor")))
                            VStack(alignment: .leading) {
                                Text("Date").fontWeight(.medium).font(.system(size: 15))
                                Text(convertDatetoString(date: date, format: "EEEE, MMMM d, yyyy"))
                            }
                            Spacer()
                        }
                        Divider().padding(.vertical)
                        CalendarPicker(date: $date).padding(-15)
                            .frame(height: 400)
                    }.borderedCellStyle()
                }.padding()
            }
            Divider()
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
                    Contact the <a href="mailto:iteam@thecollegepreparatoryschool.org">Innovation Team</a> for assistance</p><br />
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
                    Spacer()
                }.padding()
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(hexString: club.color)))
            }).padding().buttonStyle(ScaleButtonStyle())
        }.frame(minWidth: 400, minHeight: 700)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(bakeSale ? "Bake Sale Requested" : "Meeting Requested"), message: Text("Please reach out to \(bakeSale ? "Steve Chabon" : "Manisha Kumar") if you have any questions or want to reschedule your request."), dismissButton: .default(Text("OK")))
            }
    }
}

