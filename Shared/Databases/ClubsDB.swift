//
//  ClubsDatabase.swift
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

//MARK: - Clubs
struct Club: Codable, Equatable {
    var name: String = ""
    var nickname: String = ""
    var category: String = ""
    var description: String = ""
    var leaders: [String]? = []
    var links: [String: QuickLink]? = [:]
    var color: String = ""
    var image: String = ""
}

struct Email: Codable, Equatable, Identifiable {
    var id = UUID().uuidString
    var to: [String]
    var cc: [String]
    var bcc: [String]
    var replyTo: [String]
    var subject: String
    var body: String
    var type: String
}

class ClubsFetcher: ObservableObject, Equatable {
    
    static func == (lhs: ClubsFetcher, rhs: ClubsFetcher) -> Bool {
        return lhs.clubs == rhs.clubs
    }
    
    @Published var clubs: [Club] = []
    
    init() {
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-clubs.firebaseio.com/").reference()
        
        reference.observe(.value) { _ in
            reference.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let value = snapshot.value else { return }
                do {
                    let products = try FirebaseDecoder().decode([String: Club].self, from: value)
                    self.clubs = products.values.map{$0}
                    databaseLogger.log("club data initialized")
                } catch let error {
                    databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
                }
            })
        }
    }
    
    func fetchData(completion: @escaping ([Club]?)->()) {
        
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-clubs.firebaseio.com/").reference()
        
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                let products = try FirebaseDecoder().decode([String: Club].self, from: value)
                completion(products.values.map{$0})
                databaseLogger.log("club data fetched")
            } catch let error {
                completion(nil)
                databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
            }
        })
    }
}

func fetchClubMembers(club: String, clubLeaders: [String], includeAnonymous: Bool, completion: @escaping ([User])->()) {
    var reference: DatabaseReference!
    reference = Database.database(url: "https://cps-campus-users.firebaseio.com/").reference().child("users")
    
    reference.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
            let decodedUsers = try FirebaseDecoder().decode([String: User].self, from: value)
            completion(decodedUsers.filter{$0.value.clubs?.contains(where: {$0.key == club && ($0.value == true || includeAnonymous )}) ?? false && !clubLeaders.contains($0.value.id)}.values.map({$0}))
            databaseLogger.log("user data fetched")
        } catch let error {
            completion([])
            databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
        }
    })
}

func fetchClubLeaders(leaders: [String], completion: @escaping ([User])->()) {
    var reference: DatabaseReference!
    reference = Database.database(url: "https://cps-campus-users.firebaseio.com/").reference().child("users")
    
    reference.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
            let decodedUsers = try FirebaseDecoder().decode([String: User].self, from: value)
            completion(decodedUsers.filter{leaders.contains($0.value.id)}.values.map({$0}))
            databaseLogger.log("user data fetched")
        } catch let error {
            completion([])
            databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
        }
    })
}

func sendEmail(email: Email, completion: @escaping ()->()) {
    let sendGridURL = "https://api.sendgrid.com/v3/mail/send"
    let sendGridAPIKey = ""
    
    var request = URLRequest(url: URL(string: sendGridURL)!)
    request.httpMethod = "POST"
    
    request.addValue("Bearer \(sendGridAPIKey)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    var replyTo = [[String: String]]()
    for email in email.replyTo {
        replyTo.append(["email": email])
    }
    
    let json: [String:Any] = [
        "personalizations":[["to": [["email": email.to[0]]]]],
        "from": ["name":"CPS Campus", "email": "appdev@thecollegepreparatoryschool.org"],
        "reply_to_list": replyTo,
        "subject": email.subject,
        "content": [["type":"text/html", "value": email.body]]
    ]
    
    do {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        request.httpBody = data
    } catch {
        databaseLogger.error("email send error > \(error, privacy: .public)")
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 202 {
                databaseLogger.log("club event request sent")
                completion()
            }
        }
    }.resume()
}

func publishClubLink(link: QuickLink, clubName: String) {
    var reference: DatabaseReference!
    reference = Database.database(url: "https://cps-campus-clubs.firebaseio.com/").reference().child(cleanFirebaseKey(input: clubName)).child("links")
    
    let key = String(link.id)
    let updatedData: [String: Any] = ["id": link.id,
                                      "name": link.name,
                                      "icon": link.icon,
                                      "visible": true]
    reference.child(cleanFirebaseKey(input: key)).setValue(updatedData)
    databaseLogger.log("club link published")
}

func removeClubLink(linkID: String, clubName: String, completion: @escaping ()->()) {
    var reference: DatabaseReference!
    reference = Database.database(url: "https://cps-campus-clubs.firebaseio.com/").reference().child(cleanFirebaseKey(input: clubName)).child("links")
    
    reference.observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.hasChild(cleanFirebaseKey(input: linkID)) {
            reference.child(cleanFirebaseKey(input: linkID)).removeValue(completionBlock: { error, reference in
                completion()
            })
        } else {
            completion()
        }
    })
}

//MARK: - Club Meetings

struct ClubMeeting: Hashable, Codable, Equatable {
    let id: String
    let title: String
    let location: String
    let startDate: Date
    let endDate: Date
}

let clubsAPIKey = ""

func fetchClubMeetings(clubMeetings: [ClubMeeting], completion: @escaping ([ClubMeeting]?)->()) {
    
    var output: [ClubMeeting]?
    
    let myDateFormatterClubs = DateFormatter()
    myDateFormatterClubs.locale = Locale(identifier: "en_US_POSIX")
    myDateFormatterClubs.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let calendarIDClubs = "c_43f6979aeed78db1c826fca4e10b4b6c3aad4f22bdbe8326cffb5108ca80099a@group.calendar.google.com"
    
    var componentsClubs = URLComponents()
    componentsClubs.scheme = "https"
    componentsClubs.host = "www.googleapis.com"
    componentsClubs.path = "/calendar/v3/calendars/\(calendarIDClubs)/events"
    componentsClubs.queryItems = [
        URLQueryItem(name: "key", value: clubsAPIKey),
        URLQueryItem(name: "timeMin", value: myDateFormatterClubs.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())),
        URLQueryItem(name: "timeMax", value: myDateFormatterClubs.string(from: Calendar.current.date(byAdding: .weekOfYear, value: 3, to: Date()) ?? Date())),
        URLQueryItem(name: "showDeleted", value: "false"),
        URLQueryItem(name: "singleEvents", value: "true")
    ]
    
    let urlFormatClubs = componentsClubs.url
    
    URLSession.shared.dataTask(with: urlFormatClubs!) { (data, response, error) in
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let test = try JSONDecoder().decode(EventCal.self, from: data)
                            if clubMeetings != mapCaltoMeetingArray(input: EventCalModel(model: test)) {
                                output = mapCaltoMeetingArray(input: EventCalModel(model: test))
                            }
                            completion(output)
                        } catch {
                            completion(nil)
                            databaseLogger.error("club meetings > \(error, privacy: .public)")
                        }
                    }
                }
            }
        }
        guard error == nil else {
            completion(nil)
            databaseLogger.error("club meetings > \(error, privacy: .public)")
            return
        }
    }.resume()
}

func mapCaltoMeetingArray(input: EventCalModel) -> [ClubMeeting] {
    var output = [ClubMeeting]()
    for item in input.items {
        output.append(ClubMeeting(id: "\(item.summary)-\(item.description)-\(getCalendarDate(allday: item.start, dateTime: item.dateTime))-\(getCalendarDate(allday: item.end, dateTime: item.endDateTime))-\(item.location)", title: item.summary, location: item.location, startDate: getCalendarDate(allday: item.start, dateTime: item.dateTime), endDate: getCalendarDate(allday: item.end, dateTime: item.endDateTime)))
    }
    return output
}

func getClubfromMeeting(clubs: [Club], meetingName: String) -> Club? {
    var output: Club? = nil
    for club in clubs {
        if meetingName.lowercased().contains(club.name.lowercased()) {
            output = club
        }
        else if club.nickname != "" && meetingName.lowercased().contains(club.nickname.lowercased()) {
            output = club
        }
    }
    return output
}

func getPredefinedClubfromMeeting(club: Club, meetingName: String) -> Bool {
    var output = false
    if meetingName.lowercased().contains(club.name.lowercased()) {
        output = true
    }
    else if club.nickname != "" && meetingName.lowercased().contains(club.nickname.lowercased()) {
        output = true
    }
    return output
}
