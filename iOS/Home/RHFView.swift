//
//  RHFView.swift
//  CPS Campus (iOS)
//
//  8/25/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import Combine
import SwiftUI

struct RHFView: View {
    
    //Environment
    @Environment(\.openURL) var openURL
    @Binding var rhfCells: [RHFCell]
    @State var events = [ClubMeeting]()
    
    //Preferences
    @AppStorage("RHFID", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var rhfID = ""
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @FocusState var focused: Bool
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    LazyVGrid(columns: columns) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("ID")
                                    .textCase(.uppercase)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color("SystemContrast2"))
                                TextField("Input ID", text: $rhfID)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(Color("AccentColor"))
                                    .textFieldStyle(.plain)
                                    .focused($focused)
                                    .keyboardType(.numberPad)
                                    .frame(width: 100)
                            }
                            Spacer()
                        }.padding([.leading,.vertical])
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Points")
                                    .textCase(.uppercase)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color("SystemContrast2"))
                                if let cell = rhfCells.first(where: {$0.id ?? "0" == rhfID}) {
                                    if let points = cell.points {
                                        Text(points)
                                            .font(.system(size: 22, weight: .semibold))
                                            .padding(.vertical, 1)
                                    } else {
                                        Text("None")
                                            .font(.system(size: 22, weight: .semibold))
                                            .padding(.vertical, 1)
                                            .opacity(0.5)
                                    }
                                } else {
                                    Text("--")
                                        .font(.system(size: 22, weight: .semibold))
                                        .padding(.vertical, 1)
                                        .opacity(0.5)
                                }
                            }
                            Spacer()
                        }.padding([.leading,.vertical])
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
                    }
                    .padding(.bottom)
                    if let eventArray = Optional(events.filter { $0.endDate > Date() }.sorted { $0.startDate < $1.startDate }) {
                        ForEach(eventArray.indices, id: \.self) { index in
                            if index == 0 {
                                HStack { Text(convertDatetoString(date: eventArray[index].startDate, format: "EEEE, MMMM d")).font(.system(size: 16, weight: .medium, design: .rounded)).textCase(.uppercase).foregroundStyle(Calendar.current.isDateInToday(eventArray[index].startDate) == true ? Color("AccentColor") : Color("SystemContrast2"));Spacer() }.padding(.leading, 10)
                            }
                            if index != 0 {
                                if Calendar.current.isDate(eventArray[index-1].startDate, inSameDayAs: eventArray[index].startDate) == false {
                                    Spacer().frame(height: 20)
                                    HStack { Text(convertDatetoString(date: eventArray[index].startDate, format: "EEEE, MMMM d")).font(.system(size: 16, weight: .medium, design: .rounded)).textCase(.uppercase).foregroundStyle(Calendar.current.isDateInToday(eventArray[index].startDate) == true ? Color("AccentColor") : Color("SystemContrast2"));Spacer() }.padding(.leading, 10)
                                }
                            }
                            RHFDropInView(event: eventArray[index])
                        }
                    }
                }.padding()
            }
        }
        .navigationTitle("RHF")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button(action: {
                    focused = false
                }, label: {
                    Text("Done").bold()
                })
            }
        }
        .onAppear {
            URLSession.shared.dataTask(with: rhfSpreadsheetURL) { data,response,error in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let data = data {
                            DispatchQueue.main.async {
                                do {
                                    let decoder = JSONDecoder()
                                    let decodedLists = try decoder.decode(FailableCodableArray<RHFCell>.self, from: data)
                                    rhfCells = decodedLists.elements
                                } catch {
                                    databaseLogger.error("rhf decode error > \(error, privacy: .public)")
                                }
                            }
                        }
                        guard error == nil else {
                            databaseLogger.error("rhf access error > \(error, privacy: .public)")
                            return
                        }
                    }
                }
            }.resume()
            
            let myDateFormatterRHF = DateFormatter()
            myDateFormatterRHF.locale = Locale(identifier: "en_US_POSIX")
            myDateFormatterRHF.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let calendarIDRHF = "c_09d4ea1bffc9f5ae8eb1d79ca4fd43ae390ea29c408921a7a8a10901ec2a00b1@group.calendar.google.com"
            
            var componentsRHF = URLComponents()
            componentsRHF.scheme = "https"
            componentsRHF.host = "www.googleapis.com"
            componentsRHF.path = "/calendar/v3/calendars/\(calendarIDRHF)/events"
            componentsRHF.queryItems = [
                URLQueryItem(name: "key", value: sportsAPIKey),
                URLQueryItem(name: "timeMin", value: myDateFormatterRHF.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())),
                URLQueryItem(name: "timeMax", value: myDateFormatterRHF.string(from: Calendar.current.date(byAdding: .weekOfYear, value: 3, to: Date()) ?? Date())),
                URLQueryItem(name: "showDeleted", value: "false"),
                URLQueryItem(name: "singleEvents", value: "true")
            ]
            
            let urlFormat = componentsRHF.url
            
            URLSession.shared.dataTask(with: urlFormat!) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let data = data {
                            DispatchQueue.main.async {
                                do {
                                    let test = try JSONDecoder().decode(EventCal.self, from: data)
                                    events = mapCaltoMeetingArray(input: EventCalModel(model: test))
                                } catch {
                                    databaseLogger.error("rhf dropin error > \(error, privacy: .public)")
                                }
                            }
                        }
                    }
                }
                guard error == nil else {
                    databaseLogger.error("rhf dropin error > \(error, privacy: .public)")
                    return
                }
            }.resume()
        }
    }
}

struct RHFDropInView: View {
    let event: ClubMeeting
    
    var body: some View {
        VStack {
            HStack {
                if event.title.components(separatedBy: " - ").count > 2 {
                    switch event.title.components(separatedBy: " - ")[1] {
                    case let str where str.lowercased().contains("badminton"): ZStack {
                        Circle()
                            .frame(width: 55, height: 55)
                            .foregroundStyle(Color("AccentColor"))
                        Image("figure.badminton")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(.black))
                    }
                    case let str where str.lowercased().contains("fitness"): ZStack {
                        Circle()
                            .frame(width: 55, height: 55)
                            .foregroundStyle(Color("AccentColor"))
                        Image("figure.indoor.cycle")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(.black))
                    }
                    case let str where str.lowercased().contains("climb"): ZStack {
                        Circle()
                            .frame(width: 55, height: 55)
                            .foregroundStyle(Color("AccentColor"))
                        Image("figure.climbing")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(.black))
                    }
                    case let str where str.lowercased().contains("hike") || str.lowercased().contains("hiking") : ZStack {
                        Circle()
                            .frame(width: 55, height: 55)
                            .foregroundStyle(Color("AccentColor"))
                        Image("figure.hiking")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(.black))
                    }
                    case let str where str.lowercased().contains("yoga"): ZStack {
                        Circle()
                            .frame(width: 55, height: 55)
                            .foregroundStyle(Color("AccentColor"))
                        Image("figure.yoga")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(.black))
                    }
                    default: ZStack {
                        Circle()
                            .frame(width: 55, height: 55)
                            .foregroundStyle(Color("AccentColor"))
                        Image("figure.highintensity.intervaltraining")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(.black))
                    }
                    }
                    VStack(alignment: .leading) {
                        Text("\(event.title.components(separatedBy: " - ")[1]) - \(event.title.components(separatedBy: " - ")[2])")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("SystemContrast"))
                        if "\(convertDatetoString(date: event.startDate, format: "h:mm")) - \(convertDatetoString(date: event.endDate, format: "h:mm"))" == "12:00 - 12:00" {
                            Text(event.title.components(separatedBy: " - ")[0])
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(Color("SystemContrast2"))
                        } else {
                            Text("\(event.title.components(separatedBy: " - ")[0]) @ \(convertDatetoString(date: event.startDate, format: "h:mm")) - \(convertDatetoString(date: event.endDate, format: "h:mm"))")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(Color("SystemContrast2"))
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
    }
}
