//
//  SportsView.swift
//  CPS Campus (iOS)
//
//  6/7/2021
//  Designed by Rahim Malik in California.
//

import SwiftUI
import Foundation
import DynamicColor

struct SportsView: View {
    
    //MARK: Sport Data
    @AppStorage("FollowedSports", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var followedSports = [String: Bool]()
    @Binding var games: [SportGame]
    let sports: [Sport]
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) var ipad
    
    @State var selection: String? = ""
    @State var search: String = ""
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { mainValue in
                    if search == "" {
                        VStack(spacing: 10) {
                            SectionHeader(name: "Your Teams")
                                .padding(.leading, 15)
                                .padding(.top, 10)
                                .id("top")
                            ScrollViewReader { scrollView in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 0) {
                                        Spacer()
                                            .frame(width: 15)
                                            .padding(.trailing, ipad == .regular ? 5 : 0)
                                        if !followedSports.keys.map({$0}).contains(cleanFirebaseKey(input: selection ?? "NilSelection")) && selection != "" && selection != "Add Team" {
                                            SportIcon(sport: getSportfromGame(sports: sports, gameName: selection ?? "NilSelection") ?? Sport(), games: games, selection: $selection, search: $search)
                                                .id(selection)
                                                .padding(.trailing, ipad == .regular ? 5 : 0)
                                        }
                                        ForEach(sports.filter { sport in followedSports.keys.map({$0}).contains(cleanFirebaseKey(input: sport.name)) }.sorted { $0.name < $1.name }, id: \.name) { sport in
                                            SportIcon(sport: sport, games: games.filter { $0.endDate > Date() && getSportfromGame(sports: sports, gameName: $0.title) != nil }.sorted { $0.startDate < $1.startDate }, selection: $selection, search: $search)
                                                .id(sport.name)
                                                .padding(.trailing, ipad == .regular ? 5 : 0)
                                        }
                                        AddSportButton(selection: $selection)
                                            .padding(.trailing, ipad == .regular ? 5 : 0)
                                        Spacer().frame(width: 15)
                                    }
                                }
                                .onChange(of: selection) { _ in
                                    withAnimation {
                                        mainValue.scrollTo("top", anchor: .top)
                                        scrollView.scrollTo(selection, anchor: .center)
                                    }
                                }
                                .onAppear {
                                    withAnimation {
                                        scrollView.scrollTo(selection, anchor: .center)
                                    }
                                }
                                .padding(.top, 5)
                            }
                            if selection == "" {
                                VStack {
                                    if let gameArray = Optional(games.filter { getSportfromGame(sports: sports, gameName: $0.title) != nil }.filter({ $0.endDate > Date() }).sorted { $0.startDate < $1.startDate }) {
                                        ForEach(gameArray.indices, id: \.self) { index in
                                            if index == 0 {
                                                HStack { Text(convertDatetoString(date: gameArray[index].startDate, format: "EEEE, MMMM d")).fontWeight(.medium).font(.system(.body, design: .rounded)).textCase(.uppercase).foregroundStyle(Calendar.current.isDateInToday(gameArray[index].startDate) == true ? Color("AccentColor") : Color("SystemContrast2"));Spacer() }.padding(.leading, 10)
                                            }
                                            if index != 0 {
                                                if Calendar.current.isDate(gameArray[index-1].startDate, inSameDayAs: gameArray[index].startDate) == false {
                                                    Spacer().frame(height: 20)
                                                    HStack { Text(convertDatetoString(date: gameArray[index].startDate, format: "EEEE, MMMM d")).fontWeight(.medium).font(.system(.body, design: .rounded)).textCase(.uppercase).foregroundStyle(Calendar.current.isDateInToday(gameArray[index].startDate) == true ? Color("AccentColor") : Color("SystemContrast2"));Spacer() }.padding(.leading, 10)
                                                }
                                            }
                                            SportGameCell(game: gameArray[index], sport: getSportfromGame(sports: sports, gameName: gameArray[index].title) ?? Sport(), games: gameArray, selection: $selection)
                                        }
                                    }
                                }.padding()
                            } else if selection == "Add Team" {
                                LazyVStack {
                                    ForEach(sportCategories, id: \.self) { category in
                                        Section(header: SectionHeader(name: category)) {
                                            ForEach(sports.filter { category.contains($0.type) }.sorted { $0.name < $1.name }, id: \.name) { sport in
                                                SportCell(sport: sport, selection: $selection, search: $search)
                                            }
                                        }
                                        Spacer().frame(height: 20)
                                    }
                                }.padding()
                            } else {
                                SportsPage(sport: getSportfromGame(sports: sports, gameName: selection ?? "NilSelection") ?? Sport(), games: games, selection: $selection)
                            }
                            Spacer().frame(height: 10)
                        }
                    } else {
                        VStack(spacing: 10) {
                            LazyVStack {
                                Section(header: SectionHeader(name: "Teams")) {
                                    ForEach(sports.filter { sport in sport.name.lowercased().components(separatedBy: " ").first(where: {$0.starts(with: search.lowercased())}) != nil || sport.name.lowercased().starts(with: search.lowercased()) }.sorted { $0.name < $1.name }, id: \.name) { sport in
                                        SportCell(sport: sport, selection: $selection, search: $search)
                                    }
                                }
                            }.padding()
                            LazyVStack {
                                Section(header: SectionHeader(name: "Games")) {
                                    ForEach(games.filter { getSportfromGame(sports: sports, gameName: $0.title)?.name.lowercased().components(separatedBy: " ").first(where: {$0.starts(with: search.lowercased())}) != nil || $0.title.lowercased().components(separatedBy: " ").first(where: {$0.starts(with: search.lowercased())}) != nil }.filter({ $0.endDate > Date() }).sorted { $0.startDate < $1.startDate }, id: \.self) { game in
                                        SportGameCellPage(game: game, sport: getSportfromGame(sports: sports, gameName: game.title) ?? Sport())
                                    }
                                }
                            }.padding(.horizontal)
                            Spacer().frame(height: 10)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Sports")
        .navigationBarTitleDisplayMode(.automatic)
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for games and teams")
        .disableAutocorrection(true)
    }
}

struct SportsPage: View {
    
    //MARK: Sport Data
    @AppStorage("FollowedSports", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var followedSports = [String: Bool]()
    let sport: Sport
    let games: [SportGame]
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var selection: String?
    
    var body: some View {
        VStack {
            if !followedSports.keys.map({$0}).contains(cleanFirebaseKey(input: sport.name)) {
                Button(action: {
                    followedSports.updateValue(true, forKey: cleanFirebaseKey(input: sport.name))
                    let haptics = UIImpactFeedbackGenerator(style: .light)
                    haptics.impactOccurred()
                }, label: {
                    HStack(spacing: 5) {
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(colorScheme == .light && UIColor(hexString: sport.color).luminance > 0.5 ? Color(UIColor(hexString: sport.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: sport.color))
                        Text("Follow Team")
                            .fontWeight(.semibold)
                            .foregroundStyle(colorScheme == .light && UIColor(hexString: sport.color).luminance > 0.5 ? Color(UIColor(hexString: sport.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: sport.color))
                        Spacer()
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(hexString: sport.color).opacity(0.25)))
                })
                .padding(.bottom)
            }
            HStack {
                SectionHeader(name: "Games")
                Text("#"+sport.season.lowercased())
                    .fontWeight(.medium)
                    .foregroundStyle(colorScheme == .light && UIColor(hexString: sport.color).luminance > 0.5 ? Color(UIColor(hexString: sport.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: sport.color))
            }
            if games.filter({ getPredefinedSportfromGame(sport: sport, gameName: $0.title) && $0.endDate > Date() }) != [] {
                VStack {
                    ForEach(games.filter { getPredefinedSportfromGame(sport: sport, gameName: $0.title) && $0.endDate > Date() }.sorted { $0.startDate < $1.startDate }, id: \.id) { game in
                        SportGameCellPage(game: game, sport: sport)
                    }
                }
            } else {
                HStack {
                    Spacer()
                    Text("No Upcoming Games")
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(.systemGray6)))
            }
        }.padding()
            .navigationBarTitle(sport.name)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if followedSports.keys.map({$0}).contains(cleanFirebaseKey(input: sport.name)) {
                            followedSports.removeValue(forKey: cleanFirebaseKey(input: sport.name))
                            selection = ""
                        } else {
                            followedSports.updateValue(true, forKey: cleanFirebaseKey(input: sport.name))
                            selection = sport.name
                        }
                        let haptics = UIImpactFeedbackGenerator(style: .light)
                        haptics.impactOccurred()
                    }, label: {
                        if followedSports.keys.map({$0}).contains(cleanFirebaseKey(input: sport.name)) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(colorScheme == .light && UIColor(hexString: sport.color).luminance > 0.5 ? Color(UIColor(hexString: sport.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: sport.color))
                        } else {
                            Image(systemName: "star")
                                .foregroundStyle(colorScheme == .light && UIColor(hexString: sport.color).luminance > 0.5 ? Color(UIColor(hexString: sport.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: sport.color))
                        }
                    })
                }
            }
    }
}
