//
//  SportsDatabase.swift
//  CPS Campus (Shared)
//
//  6/7/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseDatabase
import CodableFirebase

//MARK: - Sports

struct Sport: Codable, Equatable {
    var name: String = ""
    var gamePrefix: String = ""
    var gameRegex: String = ""
    var type: String = ""
    var season: String = ""
    var color: String = ""
    var image: String = ""
}

class SportsFetcher: ObservableObject, Equatable {
    
    static func == (lhs: SportsFetcher, rhs: SportsFetcher) -> Bool {
        return lhs.sports == rhs.sports
    }
    
    @Published var sports: [Sport] = []
    
    init() {
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-sports.firebaseio.com/").reference().child("teams")
        
        reference.observe(.value) { (snapshot) in
            reference.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let value = snapshot.value else { return }
                do {
                    let products = try FirebaseDecoder().decode([String: Sport].self, from: value)
                    self.sports = products.values.map{$0}
                    databaseLogger.log("sport data refreshed")
                } catch let error {
                    databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
                }
            })
        }
    }
    
    func fetchData(completion: @escaping ([Sport]?)->()) {
        
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-sports.firebaseio.com/").reference().child("teams")
        
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                let products = try FirebaseDecoder().decode([String: Sport].self, from: value)
                completion(products.values.map{$0})
                databaseLogger.log("sport data fetched")
            } catch let error {
                completion(nil)
                databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
            }
        })
    }
}

//MARK: - Sport Games

struct SportGame: Hashable, Codable, Equatable {
    let id: String
    let title: String
    let details: String
    let location: String
    let startDate: Date
    let endDate: Date
}

let sportsAPIKey = ""
let rhfSpreadsheetURL = URL(string: "")!

func fetchSportGames(sportGames: [SportGame], completion: @escaping ([SportGame]?)->()) {
    
    var output: [SportGame]?
    
    let myDateFormatterSports = DateFormatter()
    myDateFormatterSports.locale = Locale(identifier: "en_US_POSIX")
    myDateFormatterSports.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let calendarIDSports = "1ke61qdb02ac9qstko0apim4557odeos@import.calendar.google.com"
    
    var componentsSports = URLComponents()
    componentsSports.scheme = "https"
    componentsSports.host = "www.googleapis.com"
    componentsSports.path = "/calendar/v3/calendars/\(calendarIDSports)/events"
    componentsSports.queryItems = [
        URLQueryItem(name: "key", value: sportsAPIKey),
        URLQueryItem(name: "timeMin", value: myDateFormatterSports.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())),
        URLQueryItem(name: "timeMax", value: myDateFormatterSports.string(from: Calendar.current.date(byAdding: .weekOfYear, value: 12, to: Date()) ?? Date())),
        URLQueryItem(name: "showDeleted", value: "false"),
        URLQueryItem(name: "singleEvents", value: "true")
    ]
    
    let urlFormatSports = componentsSports.url
    
    URLSession.shared.dataTask(with: urlFormatSports!) { (data, response, error) in
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let test = try JSONDecoder().decode(EventCal.self, from: data)
                            if sportGames != mapCaltoGameArray(input: EventCalModel(model: test)) {
                                output = mapCaltoGameArray(input: EventCalModel(model: test))
                            }
                            completion(output)
                        } catch {
                            completion(nil)
                            databaseLogger.error("sport games > \(error, privacy: .public)")
                        }
                    }
                }
            }
        }
        guard error == nil else {
            completion(nil)
            databaseLogger.error("sport games > \(error, privacy: .public)")
            return
        }
    }.resume()
}

func mapCaltoGameArray(input: EventCalModel) -> [SportGame] {
    var output = [SportGame]()
    for item in input.items {
        output.append(SportGame(id: "\(item.summary)-\(item.description)-\(getCalendarDate(allday: item.start, dateTime: item.dateTime))-\(getCalendarDate(allday: item.end, dateTime: item.endDateTime))-\(item.location)", title: item.summary, details: item.description, location: item.location, startDate: getCalendarDate(allday: item.start, dateTime: item.dateTime), endDate: getCalendarDate(allday: item.end, dateTime: item.endDateTime)))
    }
    return output
}

func getSportfromGame(sports: [Sport], gameName: String) -> Sport? {
    var output: Sport? = nil
    for sport in sports {
        if gameName.contains(sport.gameRegex) || gameName.contains(sport.name) {
            output = sport
        }
    }
    return output
}

func getPredefinedSportfromGame(sport: Sport, gameName: String) -> Bool {
    var output = false
    if gameName.contains(sport.gameRegex) {
        output = true
    }
    return output
}

func cleanSummary(input: String) -> String {
    var input2 = input
    input2 = input2.replacingOccurrences(of: "- Game", with: "", options: .regularExpression)
    input2 = input2.replacingOccurrences(of: "High School", with: "", options: .regularExpression)
    input2 = input2.replacingOccurrences(of: "School", with: "", options: .regularExpression)
    input2 = input2.replacingOccurrences(of: "- Away", with: "", options: .regularExpression)
    input2 = input2.replacingOccurrences(of: "- Home", with: "", options: .regularExpression)
    input2 = input2.replacingOccurrences(of: "  ", with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
    if input2 == "" {
        return ("Opponent")
    } else {
        return ("\(input2)")
    }
}
