//
//  ClubsViewModel.swift
//  CPS Campus (iOS)
//
//  6/9/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import DynamicColor

struct ClubMeetingCell: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("JoinedClubs", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var joinedClubs = [String: Bool]()
    let meeting: ClubMeeting
    let club: Club
    let meetings: [ClubMeeting]
    
    @Binding var selection: String?
    @Binding var campusID: User?
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selection = club.name
                }, label: {
                    if meeting.title.lowercased().contains("bake sale") && club.name == "" {
                        AsyncImage(url: URL(string: "https://i.postimg.cc/Nfy7cBcV/Bake-Sale.png")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ZStack {
                                Color(hexString: club.color)
                                ProgressView()
                            }
                        }
                        .saturation(1.1)
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                    } else {
                        AsyncImage(url: URL(string: club.image)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ZStack {
                                Color(hexString: club.color)
                                ProgressView()
                            }
                        }
                        .saturation(1.1)
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                    }
                })
                .buttonStyle(ScaleButtonStyle())
                .disabled(club.name == "")
                VStack(alignment: .leading, spacing: 3.5) {
                    Text(meeting.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("SystemContrast"))
                        .multilineTextAlignment(.leading)
                    if "\(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))" == "12:00 - 12:00" {
                        Text(meeting.location.isEmpty ? "all-day" : "\(meeting.location) all-day")
                            .fontWeight(.medium)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color("SystemContrast2"))
                    } else {
                        Text(meeting.location.isEmpty ? "\(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))" : "\(meeting.location) @ \(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))")
                            .fontWeight(.medium)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color("SystemContrast2"))
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
        .contextMenu(ContextMenu(menuItems: {
            if club.name != "" {
                Button(action: {
                    withAnimation {
                        selection = club.name
                    }
                }, label: {
                    Label("Club Info", systemImage: "info.circle")
                })
                if club.leaders?.contains(campusID?.id ?? "NilEmail") == false {
                    Button(action: {
                        withAnimation {
                            if joinedClubs.keys.map({$0}).contains(cleanFirebaseKey(input: club.name)) {
                                joinedClubs.removeValue(forKey: cleanFirebaseKey(input: club.name))
                                selection = ""
                            } else {
                                joinedClubs.updateValue(true, forKey: cleanFirebaseKey(input: club.name))
                                selection = club.name
                            }
                        }
                    }, label: {
                        if joinedClubs.keys.map({$0}).contains(cleanFirebaseKey(input: club.name)) {
                            Label("Unjoin Club", systemImage: "person.badge.minus")
                        } else {
                            Label("Join Club", systemImage: "person.badge.plus")
                        }
                    })
                    if club.category == "affinities" && !joinedClubs.keys.map({$0}).contains(cleanFirebaseKey(input: club.name)) {
                        Button(action: {
                            withAnimation {
                                joinedClubs.updateValue(false, forKey: cleanFirebaseKey(input: club.name))
                                selection = club.name
                            }
                        }, label: {
                            Label("Join Club Anonymously", systemImage: "person.badge.plus")
                        })
                    }
                }
            }
        }))
    }
}

struct ClubMeetingCellPage: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let meeting: ClubMeeting
    let club: Club
    
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: club.image)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        Color(hexString: club.color)
                        ProgressView()
                    }
                }
                .saturation(1.1)
                .frame(width: 55, height: 55)
                .clipShape(Circle())
                VStack(alignment: .leading, spacing: 3.5) {
                    Text(meeting.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("SystemContrast"))
                        .multilineTextAlignment(.leading)
                    if "\(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))" == "12:00 - 12:00" {
                        Text(meeting.location.isEmpty ? "\(convertDatetoString(date: meeting.startDate, format: "M/d")) all-day" : "\(meeting.location) \(convertDatetoString(date: meeting.startDate, format: "M/d")) all-day")
                            .fontWeight(.medium)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color("SystemContrast2"))
                    } else {
                        Text(meeting.location.isEmpty ? "\(convertDatetoString(date: meeting.startDate, format: "M/d h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))" : "\(meeting.location) @ \(convertDatetoString(date: meeting.startDate, format: "M/d h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))")
                            .fontWeight(.medium)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color("SystemContrast2"))
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
    }
}

struct ClubMeetingCellHome: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let meeting: ClubMeeting
    let club: Club
    let tomorrow: Bool
    
    var body: some View {
        VStack {
            HStack {
                if meeting.title.lowercased().contains("bake sale") && club.name == "" {
                    AsyncImage(url: URL(string: "https://i.postimg.cc/Nfy7cBcV/Bake-Sale.png")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ZStack {
                            Color(hexString: club.color)
                            ProgressView()
                        }
                    }
                    .saturation(1.1)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                } else {
                    AsyncImage(url: URL(string: club.image)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ZStack {
                            Color(hexString: club.color)
                            ProgressView()
                        }
                    }
                    .saturation(1.1)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                }
                VStack(alignment: .leading, spacing: 3.5) {
                    Text(meeting.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("SystemContrast"))
                        .multilineTextAlignment(.leading)
                    if tomorrow {
                        Text("TOMORROW")
                            .fontWeight(.medium)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color("SystemContrast2"))
                    } else {
                        if "\(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))" == "12:00 - 12:00" {
                            Text(meeting.location.isEmpty ? "all-day" : "\(meeting.location) all-day")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(Color("SystemContrast2"))
                        } else {
                            Text(meeting.location.isEmpty ? "\(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))" : "\(meeting.location) @ \(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(Color("SystemContrast2"))
                        }
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
    }
}

struct ClubIcon: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let club: Club
    let meetings: [ClubMeeting]
    
    @Binding var selection: String?
    @Binding var search: String
    
    var body: some View {
        Button(action: {
            search = ""
            if selection == club.name {
                selection = ""
            } else {
                selection = club.name
            }
        }, label: {
            VStack(alignment: .center) {
                AsyncImage(url: URL(string: club.image)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        Color(hexString: club.color)
                        ProgressView()
                    }
                }
                .saturation(1.1)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .padding(3)
                .overlay(selection == club.name ?
                         Circle().stroke(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color), lineWidth: 3)
                         : Circle().stroke(.clear, lineWidth: 3)
                )
                VStack {
                    Text(club.nickname != "" ? club.nickname : club.name)
                        .fontWeight(.medium)
                        .font(.system(size: 13))
                        .foregroundStyle(selection == club.name ? Color("SystemContrast") : Color("SystemContrast2"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                    Spacer()
                }.frame(width: 80)
            }
            .padding(5)
        }).buttonStyle(ScaleButtonStyle())
    }
}

struct AddClubButton: View {
    
    @Binding var selection: String?
    
    var body: some View {
        Button(action: {
            if selection == "Add Club" {
                selection = ""
            } else {
                selection = "Add Club"
            }
        }, label: {
            VStack {
                Image(systemName: "plus")
                    .foregroundStyle(Color("AccentColor"))
                    .font(.system(size: 37.5, weight: .semibold))
                    .background(Circle().foregroundStyle(Color("AccentColor").opacity(0.25)).frame(width: 80, height: 80, alignment: .center))
                    .frame(width: 80, height: 80, alignment: .center)
                    .padding(3)
                    .overlay(selection == "Add Club" ?
                             Circle().stroke(Color("AccentColor"), lineWidth: 3)
                             : Circle().stroke(.clear, lineWidth: 3)
                    )
                VStack {
                    Text("Add Club")
                        .fontWeight(.medium)
                        .font(.system(size: 13))
                        .foregroundStyle(Color("AccentColor"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                    Spacer()
                }.frame(width: 80)
            }
            .padding(5)
        })
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ClubCell: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let club: Club
    
    @Binding var selection: String?
    @Binding var search: String
    
    var body: some View {
        Button(action: {
            search = ""
            selection = club.name
        }, label: {
            VStack {
                HStack {
                    AsyncImage(url: URL(string: club.image)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ZStack {
                            Color(hexString: club.color)
                            ProgressView()
                        }
                    }
                    .saturation(1.1)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text(club.name)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("SystemContrast"))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
        })
    }
}
