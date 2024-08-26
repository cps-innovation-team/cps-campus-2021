//
//  NotificationsViewModel.swift
//  CPS Campus (Shared)
//
//  5/28/2021
//  Designed by Rahim Malik in California.
//

import SwiftUI
import UserNotifications

//MARK: - Schedule Notifications
func generateAllNotifications(courses: [Course], blocks: [Block], notificationSettings: [String: Double], gradYear: String) {
    var minutes = 5.0
    if let value = notificationSettings["ClassMinutes"] {
        minutes = value
    }
    UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
        for request in requests {
            if request.identifier.contains("Class") {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
            }
        }
    })
    //creates queue of all schedule notifications adjusted for user's settings
    for block in blocks.filter({ $0.startTime != "all-day"}) {
        for date in block.dates.filter({ weekofyearNotificationChecker(input: convertStringtoDate(string: "\(block.startTime) \($0)", format: "HH:mm M/d/yyyy")) }) {
            if allAssignableCourses.contains(block.title) {
                if notificationSettings["ClassStarts"] == 1.0 {
                    if Calendar.current.date(byAdding: .minute, value: -1*Int(minutes), to: convertStringtoDate(string: "\(block.startTime) \(date)", format: "HH:mm M/d/yyyy")) ?? Date() > Date() {
                        if checkCompass(compass: getCoursefromID(courseID: "Compass", courses: courses), gradYear: gradYear, block: block, blocks: blocks, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(date) }), inheritedDate: date) {
                            generateNotificationSchedule(course: getCoursefromID(courseID: "Compass", courses: courses), date: Calendar.current.date(byAdding: .minute, value: -1*Int(minutes), to: convertStringtoDate(string: "\(block.startTime) \(date)", format: "HH:mm M/d/yyyy")) ?? Date(), minutes: Int(minutes), start: true)
                        } else if block.title == "Advising" && checkAdvising(gradYear: gradYear, inheritedDate: date, blocks: blocks) == false {
                            generateNotificationUniversal(title: "Open", subtitle: nil, body: nil, sound: UNNotificationSound(named: UNNotificationSoundName(rawValue: "cling.mp3")), date: Calendar.current.date(byAdding: .minute, value: -1*Int(minutes), to: convertStringtoDate(string: "\(block.startTime) \(date)", format: "HH:mm M/d/yyyy")) ?? Date(), minutes: Int(minutes), start: true)
                        } else if checkCoursebyRotation(course: getCoursefromID(courseID: block.title, courses: courses), block: block, blocks: blocks.filter { $0.dates.contains(date) }) {
                            generateNotificationSchedule(course: getCoursefromID(courseID: block.title, courses: courses), date: Calendar.current.date(byAdding: .minute, value: -1*Int(minutes), to: convertStringtoDate(string: "\(block.startTime) \(date)", format: "HH:mm M/d/yyyy")) ?? Date(), minutes: Int(minutes), start: true)
                        } else {
                            generateNotificationUniversal(title: "Free Period", subtitle: nil, body: nil, sound: UNNotificationSound(named: UNNotificationSoundName(rawValue: "cling.mp3")), date: Calendar.current.date(byAdding: .minute, value: -1*Int(minutes), to: convertStringtoDate(string: "\(block.startTime) \(date)", format: "HH:mm M/d/yyyy")) ?? Date(), minutes: Int(minutes), start: true)
                        }
                    }
                }
                if notificationSettings["ClassEnds"] == 1.0 {
                    if convertStringtoDate(string: "\(block.endTime) \(date)", format: "HH:mm M/d/yyyy") > Date() {
                        if checkCompass(compass: getCoursefromID(courseID: "Compass", courses: courses), gradYear: gradYear, block: block, blocks: blocks, rotation: getRotation(blocks: blocks.filter { $0.dates.contains(date) }), inheritedDate: date) {
                            generateNotificationSchedule(course: getCoursefromID(courseID: "Compass", courses: courses), date: convertStringtoDate(string: "\(block.endTime) \(date)", format: "HH:mm M/d/yyyy"), minutes: Int(minutes), start: false)
                        } else if block.title == "Advising" && checkAdvising(gradYear: gradYear, inheritedDate: date, blocks: blocks) == false {
                            generateNotificationUniversal(title: "Open", subtitle: nil, body: nil, sound: UNNotificationSound(named: UNNotificationSoundName(rawValue: "cling.mp3")), date: convertStringtoDate(string: "\(block.endTime) \(date)", format: "HH:mm M/d/yyyy"), minutes: Int(minutes), start: false)
                        } else if checkCoursebyRotation(course: getCoursefromID(courseID: block.title, courses: courses), block: block, blocks: blocks.filter { $0.dates.contains(date) }) {
                            generateNotificationSchedule(course: getCoursefromID(courseID: block.title, courses: courses), date: convertStringtoDate(string: "\(block.endTime) \(date)", format: "HH:mm M/d/yyyy"), minutes: Int(minutes), start: false)
                        } else {
                            generateNotificationUniversal(title: "Free Period", subtitle: nil, body: nil, sound: UNNotificationSound(named: UNNotificationSoundName(rawValue: "cling.mp3")), date: convertStringtoDate(string: "\(block.endTime) \(date)", format: "HH:mm M/d/yyyy"), minutes: Int(minutes), start: false)
                        }
                    }
                }
            } else if block.type == "FREE" {
                if notificationSettings["ClassStarts"] == 1.0 {
                    if convertStringtoDate(string: "\(block.startTime) \(date)", format: "HH:mm M/d/yyyy") > Date() {
                        generateNotificationUniversal(title: block.title, subtitle: nil, body: nil, sound: UNNotificationSound(named: UNNotificationSoundName(rawValue: "cling.mp3")), date: Calendar.current.date(byAdding: .minute, value: -1*Int(0), to: convertStringtoDate(string: "\(block.startTime) \(date)", format: "HH:mm M/d/yyyy")) ?? Date(), minutes: Int(0), start: true)
                    }
                }
                if notificationSettings["ClassEnds"] == 1.0 {
                    if convertStringtoDate(string: "\(block.endTime) \(date)", format: "HH:mm M/d/yyyy") > Date() {
                        generateNotificationUniversal(title: block.title, subtitle: nil, body: nil, sound: UNNotificationSound(named: UNNotificationSoundName(rawValue: "cling.mp3")), date: convertStringtoDate(string: "\(block.endTime) \(date)", format: "HH:mm M/d/yyyy"), minutes: Int(minutes), start: false)
                    }
                }
            }
        }
    }
}

//Schedules notification for a class with a Course
func generateNotificationSchedule(course: Course, date: Date, minutes: Int, start: Bool) {
    let content = UNMutableNotificationContent()
    if course.isFreePeriod {
        if start {
            if minutes == 0 {
                content.title = String("Free Period has started")
            } else {
                content.title = String("Free Period in \(minutes) min")
            }
        } else {
            content.title = String("Free Period has ended")
        }
    } else {
        if start {
            if minutes == 0 {
                content.title = String("\(course.name) has started")
            } else {
                content.title = String("\(course.name) in \(minutes) min")
            }
            if course.id == "Common Classroom" {
                content.body = "Tap to check your CC this week"
            }
            if course.teacher != "" && course.room != "" {
                content.body = course.teacher + " | " + course.room
            } else if course.teacher != "" {
                content.body = course.teacher
            } else if course.room != "" {
                content.body = course.room
            }
        } else {
            content.title = String("\(course.name) has ended")
        }
    }
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "cling.mp3"))
    content.categoryIdentifier = "Class"
    content.interruptionLevel = .timeSensitive
    
    // show this notification five seconds from now
    let triggerComponents = Calendar.current.dateComponents([.minute,.hour,.day,.month,.year], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
    
    // choose a random identifier
    let request = UNNotificationRequest(identifier: "Class-\(UUID().uuidString)", content: content, trigger: trigger)
    
    // add our notification request
    UNUserNotificationCenter.current().add(request)
}

//Schedules a notification for classes without Course
func generateNotificationUniversal(title: String, subtitle: String?, body: String?, sound: UNNotificationSound, date: Date, minutes: Int, start: Bool) {
    let content = UNMutableNotificationContent()
    if start {
        if minutes == 0 {
            content.title = String("\(title) has started")
        } else {
            content.title = String("\(title) in \(minutes) min")
        }
    } else {
        content.title = String("\(title) has ended")
    }
    if body?.isEmpty == false {
        content.body = body ?? ""
    }
    content.sound = sound
    content.categoryIdentifier = "Class"
    content.interruptionLevel = .timeSensitive
    
    // show this notification five seconds from now
    let triggerComponents = Calendar.current.dateComponents([.minute,.hour,.day,.month,.year], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
    
    // choose a random identifier
    let request = UNNotificationRequest(identifier: "Class-\(UUID().uuidString)", content: content, trigger: trigger)
    
    // add our notification request
    UNUserNotificationCenter.current().add(request)
}

//MARK: - Club Notifications
func generateAllNotificationsClubs(clubs: [Club], joinedClubs: [String: Bool], clubMeetings: [ClubMeeting], minutes: Double) {
    UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
        for request in requests {
            if request.identifier.contains("Club Meeting") {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
            }
        }
    })
    for meeting in clubMeetings {
        if let club = getClubfromMeeting(clubs: clubs, meetingName: meeting.title) {
            if joinedClubs.keys.map({$0}).contains(club.name) {
                if Calendar.current.date(byAdding: .minute, value: -Int(minutes), to: meeting.startDate) ?? Date() > Date() {
                    generateNotificationClubMeeting(club: club, meeting: meeting, minutes: Int(minutes))
                }
            }
        }
    }
    databaseLogger.log("club notifications generated")
}


func generateNotificationClubMeeting(club: Club, meeting: ClubMeeting, minutes: Int) {
    //    var content = UNMutableNotificationContent()
    //    
    //    content.body = meeting.location
    //    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "cling.mp3"))
    //    content.categoryIdentifier = "Club Meeting"
    //    content.interruptionLevel = .timeSensitive
    //    
    //    let receiverPerson = INPerson(
    //        personHandle: INPersonHandle(value: "receiver", type: .unknown),
    //        nameComponents: nil,
    //        displayName: nil,
    //        image: nil,
    //        contactIdentifier: nil,
    //        customIdentifier: nil,
    //        isMe: true,
    //        suggestionType: .none
    //    )
    //    
    //    var clubNameComponents = PersonNameComponents()
    //    clubNameComponents.nickname = String("\(club.nickname != "" ? club.nickname : club.name) \(minutes == 0 ? "in \(minutes) minutes" : "has started")")
    //    
    //    let avatar = INImage(url: URL(string: club.image)!)
    //    
    //    let clubPerson = INPerson(
    //        personHandle: INPersonHandle(value: String("\(club.nickname != "" ? club.nickname : club.name) \(minutes == 0 ? "in \(minutes) minutes" : "has started")"), type: .unknown),
    //        nameComponents: clubNameComponents,
    //        displayName: String("\(club.nickname != "" ? club.nickname : club.name)"),
    //        image: avatar,
    //        contactIdentifier: nil,
    //        customIdentifier: nil,
    //        isMe: false,
    //        suggestionType: .none
    //    )
    //    
    //    let intent = INSendMessageIntent(
    //        recipients: [receiverPerson],
    //        outgoingMessageType: .outgoingMessageText,
    //        content: "Club Notification",
    //        speakableGroupName: INSpeakableString(spokenPhrase: "AAA"),
    //        conversationIdentifier: "Clubs",
    //        serviceName: nil,
    //        sender: clubPerson,
    //        attachments: nil
    //    )
    //    
    //    #if os(iOS)
    //    intent.setImage(avatar, forParameterNamed: \.sender)
    //    #endif
    //    
    //    let interaction = INInteraction(intent: intent, response: nil)
    //    interaction.direction = .incoming
    //    
    //    interaction.donate(completion: nil)
    //    
    //    do {
    //        content = try content.updating(from: intent) as! UNMutableNotificationContent
    //    } catch {
    //        
    //    }
    
    //MARK: content
    let content = UNMutableNotificationContent()
    if minutes == 0 {
        content.title = String("\(club.nickname != "" ? club.nickname : club.name) has started")
    } else {
        content.title = String("\(club.nickname != "" ? club.nickname : club.name) in \(minutes) min")
    }
    if meeting.location != "" {
        content.body = meeting.location
    }
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "cling.mp3"))
    content.categoryIdentifier = "Club Meeting"
    content.interruptionLevel = .timeSensitive
    
    //MARK: trigger
    let triggerComponents = Calendar.current.dateComponents([.minute,.hour,.day,.month,.year], from: Calendar.current.date(byAdding: .minute, value: -(minutes), to: meeting.startDate) ?? Date())
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
    
    //MARK: request
    let request = UNNotificationRequest(identifier: "Club Meeting-\(UUID().uuidString)", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
}

//MARK: - Sports Notifications
func generateAllNotificationsSports(sports: [Sport], followedSports: [String: Bool], sportGames: [SportGame], minutes: Double) {
    UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
        for request in requests {
            if request.identifier.contains("Sports Game") {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
            }
        }
    })
    for game in sportGames {
        if let sport = getSportfromGame(sports: sports, gameName: game.title) {
            if followedSports.keys.map({$0}).contains(sport.name) {
                if Calendar.current.date(byAdding: .minute, value: -Int(minutes), to: game.startDate) ?? Date() > Date() {
                    generateNotificationSportGame(sport: sport, game: game, minutes: Int(minutes))
                }
            }
        }
    }
    databaseLogger.log("sports notifications generated")
}

func generateNotificationSportGame(sport: Sport, game: SportGame, minutes: Int) {
    //MARK: content
    let content = UNMutableNotificationContent()
    if minutes == 0 {
        content.title = String("\(sport.name) - \(cleanSummary(input: game.title)) has started")
    } else if minutes == 60 {
        content.title = String("\(sport.name) - \(cleanSummary(input: game.title)) in 1 hour")
    } else {
        content.title = String("\(sport.name) - \(cleanSummary(input: game.title)) in \(minutes) min")
    }
    if game.location != "" {
        content.body = game.location
    }
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "cling.mp3"))
    content.categoryIdentifier = "Sports Game"
    content.interruptionLevel = .timeSensitive
    
    //MARK: trigger
    let triggerComponents = Calendar.current.dateComponents([.minute,.hour,.day,.month,.year], from: Calendar.current.date(byAdding: .minute, value: -(minutes), to: game.startDate) ?? Date())
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
    
    //MARK: request
    let request = UNNotificationRequest(identifier: "Sports Game-\(UUID().uuidString)", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
}

//Restricts notifications
func weekofyearNotificationChecker(input: Date) -> Bool {
    let weekofyearDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    if input < weekofyearDate  {
        return true
    } else {
        return false
    }
}
