//
//  SportsViewModel.swift
//  CPS Campus (iOS)
//
//  6/9/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI

struct SportGameCell: View {
    
    @Environment(\.openURL) var openURL
    
    @AppStorage("FollowedSports", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var followedSports = [String: Bool]()
    let game: SportGame
    let sport: Sport
    let games: [SportGame]
    
    @Binding var selection: String?
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selection = sport.name
                }, label: {
                    AsyncImage(url: URL(string: sport.image)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ZStack {
                            Color(hexString: sport.color)
                            ProgressView()
                        }
                    }
                    .saturation(1.1)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                })
                .buttonStyle(ScaleButtonStyle())
                VStack(alignment: .leading, spacing: 2.5) {
                    Text("\(sport.gamePrefix) - \(cleanSummary(input: game.title.replacingOccurrences(of: sport.gameRegex, with: "")))")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("SystemContrast"))
                        .multilineTextAlignment(.leading)
                    if "\(convertDatetoString(date: game.startDate, format: "h:mm")) - \(convertDatetoString(date: game.endDate, format: "h:mm"))" == "12:00 - 12:00" {
                        Text("all-day")
                            .fontWeight(.medium)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color("SystemContrast2"))
                    } else {
                        Text("\(convertDatetoString(date: game.startDate, format: "h:mm")) - \(convertDatetoString(date: game.endDate, format: "h:mm"))")
                            .fontWeight(.medium)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color("SystemContrast2"))
                    }
                }
                Spacer()
                if game.title.contains("Home") {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hexString: sport.color))
                        .padding(.leading)
                } else {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hexString: sport.color))
                        .padding(.leading)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
        .contextMenu(ContextMenu(menuItems: {
            if game.location != "" {
                if game.title.contains("Home") {
                    Button(action: {
                        if let url = URL(string: "https://maps.apple.com/?q=\(game.location.replacingOccurrences(of: " - Baldwin Gymnasium", with: "").replacingOccurrences(of: " ", with: "+"))") {
                            openURL(url)
                        }
                    }, label: {
                        if game.location.contains("Baldwin Gymnasium") {
                            Label("Baldwin Gymnasium", systemImage: "house")
                        } else {
                            Label(game.location, systemImage: "house")
                        }
                    })
                } else {
                    Button(action: {
                        if let url = URL(string: "https://maps.apple.com/?q=\(game.location.replacingOccurrences(of: " - Baldwin Gymnasium", with: "").replacingOccurrences(of: " ", with: "+"))") {
                            openURL(url)
                        }
                    }, label: {
                        if game.location.contains("Baldwin Gymnasium") {
                            Label("Baldwin Gymnasium", systemImage: "house")
                        } else {
                            Label(game.location, systemImage: "location")
                        }
                    })
                }
                Divider()
            }
            Button(action: {
                withAnimation {
                    selection = sport.name
                }
            }, label: {
                Label("Team Info", systemImage: "info.circle")
            })
            Button(action: {
                withAnimation {
                    if followedSports.keys.map({$0}).contains(cleanFirebaseKey(input: sport.name)) {
                        followedSports.removeValue(forKey: cleanFirebaseKey(input: sport.name))
                    } else {
                        followedSports.updateValue(true, forKey: cleanFirebaseKey(input: sport.name))
                    }
                }
            }, label: {
                if followedSports.keys.map({$0}).contains(cleanFirebaseKey(input: sport.name)) {
                    Label("Unfollow Team", systemImage: "star.slash")
                } else {
                    Label("Follow Team", systemImage: "star")
                }
            })
        }))
    }
}

struct SportGameCellPage: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let game: SportGame
    let sport: Sport
    
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: sport.image)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        Color(hexString: sport.color)
                        ProgressView()
                    }
                }
                .saturation(1.1)
                .frame(width: 55, height: 55)
                .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2.5) {
                    Text("\(sport.gamePrefix) - \(cleanSummary(input: game.title.replacingOccurrences(of: sport.gameRegex, with: "")))")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("SystemContrast"))
                        .multilineTextAlignment(.leading)
                    if "\(convertDatetoString(date: game.startDate, format: "h:mm")) - \(convertDatetoString(date: game.endDate, format: "h:mm"))" == "12:00 - 12:00" {
                        Text("\(convertDatetoString(date: game.startDate, format: "M/d")) all-day")
                            .fontWeight(.medium)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color("SystemContrast2"))
                    } else {
                        Text("\(convertDatetoString(date: game.startDate, format: "M/d")) \(convertDatetoString(date: game.startDate, format: "h:mm")) - \(convertDatetoString(date: game.endDate, format: "h:mm"))")
                            .fontWeight(.medium)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color("SystemContrast2"))
                    }
                }
                Spacer()
                if game.title.contains("Home") {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hexString: sport.color))
                        .padding(.leading)
                } else {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hexString: sport.color))
                        .padding(.leading)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
        .contextMenu(ContextMenu(menuItems: {
            if game.location != "" {
                if game.title.contains("Home") {
                    Button(action: {
                        if let url = URL(string: "https://maps.apple.com/?q=\(game.location.replacingOccurrences(of: " - Baldwin Gymnasium", with: "").replacingOccurrences(of: " ", with: "+"))") {
                            openURL(url)
                        }
                    }, label: {
                        if game.location.contains("Baldwin Gymnasium") {
                            Label("Baldwin Gymnasium", systemImage: "house")
                        } else {
                            Label(game.location, systemImage: "house")
                        }
                    })
                } else {
                    Button(action: {
                        if let url = URL(string: "https://maps.apple.com/?q=\(game.location.replacingOccurrences(of: " - Baldwin Gymnasium", with: "").replacingOccurrences(of: " ", with: "+"))") {
                            openURL(url)
                        }
                    }, label: {
                        if game.location.contains("Baldwin Gymnasium") {
                            Label("Baldwin Gymnasium", systemImage: "house")
                        } else {
                            Label(game.location, systemImage: "location")
                        }
                    })
                }
            }
        }))
    }
}

struct SportGameCellHome: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let game: SportGame
    let sport: Sport
    let tomorrow: Bool
    
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: sport.image)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        Color(hexString: sport.color)
                        ProgressView()
                    }
                }
                .saturation(1.1)
                .frame(width: 55, height: 55)
                .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2.5) {
                    Text("\(sport.gamePrefix) - \(cleanSummary(input: game.title.replacingOccurrences(of: sport.gameRegex, with: "")))")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("SystemContrast"))
                        .multilineTextAlignment(.leading)
                    if "\(convertDatetoString(date: game.startDate, format: "h:mm")) - \(convertDatetoString(date: game.endDate, format: "h:mm"))" != "12:00 - 12:00" {
                        if tomorrow {
                            Text("TMR @ \(convertDatetoString(date: game.startDate, format: "h:mm")) - \(convertDatetoString(date: game.endDate, format: "h:mm"))")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(Color("SystemContrast2"))
                        } else {
                            Text("TODAY @ \(convertDatetoString(date: game.startDate, format: "h:mm")) - \(convertDatetoString(date: game.endDate, format: "h:mm"))")
                                .fontWeight(.medium)
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(Color("SystemContrast2"))
                        }
                    } else {
                        Text(tomorrow ? "TOMORROW" : "TODAY")
                            .fontWeight(.medium)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color("SystemContrast2"))
                    }
                }
                Spacer()
                if game.title.contains("Home") {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hexString: sport.color))
                        .padding(.leading)
                } else {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hexString: sport.color))
                        .padding(.leading)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
        .contextMenu(ContextMenu(menuItems: {
            if game.location != "" {
                if game.title.contains("Home") {
                    Button(action: {
                        if let url = URL(string: "https://maps.apple.com/?q=\(game.location.replacingOccurrences(of: " - Baldwin Gymnasium", with: "").replacingOccurrences(of: " ", with: "+"))") {
                            openURL(url)
                        }
                    }, label: {
                        if game.location.contains("Baldwin Gymnasium") {
                            Label("Baldwin Gymnasium", systemImage: "house")
                        } else {
                            Label(game.location, systemImage: "house")
                        }
                    })
                } else {
                    Button(action: {
                        if let url = URL(string: "https://maps.apple.com/?q=\(game.location.replacingOccurrences(of: " - Baldwin Gymnasium", with: "").replacingOccurrences(of: " ", with: "+"))") {
                            openURL(url)
                        }
                    }, label: {
                        if game.location.contains("Baldwin Gymnasium") {
                            Label("Baldwin Gymnasium", systemImage: "house")
                        } else {
                            Label(game.location, systemImage: "location")
                        }
                    })
                }
            }
        }))
    }
}

struct SportIcon: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let sport: Sport
    let games: [SportGame]
    
    @Binding var selection: String?
    @Binding var search: String
    
    var body: some View {
        Button(action: {
            search = ""
            if selection == sport.name {
                selection = ""
            } else {
                selection = sport.name
            }
        }, label: {
            VStack(alignment: .center) {
                AsyncImage(url: URL(string: sport.image)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        Color(hexString: sport.color)
                        ProgressView()
                    }
                }
                .saturation(1.1)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .padding(3)
                .overlay(selection == sport.name ?
                         Circle().stroke(colorScheme == .light && UIColor(hexString: sport.color).luminance > 0.5 ? Color(UIColor(hexString: sport.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: sport.color), lineWidth: 3)
                         : Circle().stroke(.clear, lineWidth: 3)
                )
                VStack {
                    Text(sport.name.replacingOccurrences(of: sport.type, with: ""))
                        .fontWeight(.medium)
                        .font(.system(size: 13))
                        .foregroundStyle(selection == sport.name ? Color("SystemContrast") : Color("SystemContrast2"))
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

struct AddSportButton: View {
    
    @Binding var selection: String?
    
    var body: some View {
        Button(action: {
            if selection == "Add Team" {
                selection = ""
            } else {
                selection = "Add Team"
            }
        }, label: {
            VStack {
                Image(systemName: "plus")
                    .foregroundStyle(Color("AccentColor"))
                    .font(.system(size: 37.5, weight: .semibold))
                    .background(Circle().foregroundStyle(Color("AccentColor").opacity(0.25)).frame(width: 80, height: 80, alignment: .center))
                    .frame(width: 80, height: 80, alignment: .center)
                    .padding(3)
                    .overlay(selection == "Add Team" ?
                             Circle().stroke(Color("AccentColor"), lineWidth: 3)
                             : Circle().stroke(.clear, lineWidth: 3)
                    )
                VStack {
                    Text("Add Team")
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

struct SportCell: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let sport: Sport
    
    @Binding var selection: String?
    @Binding var search: String
    
    var body: some View {
        Button(action: {
            search = ""
            selection = sport.name
        }, label: {
            VStack {
                HStack {
                    AsyncImage(url: URL(string: sport.image)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ZStack {
                            Color(hexString: sport.color)
                            ProgressView()
                        }
                    }
                    .saturation(1.1)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text(sport.name)
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
