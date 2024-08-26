//
//  UserDB.swift
//  CPS Campus (iPadOS)
//
//  6/8/2023
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseDatabase
import CodableFirebase

struct User: Codable, Hashable, Identifiable {
    var id: String
    var name: String
    var gradYear: String
    var imageLink: String
    var pronouns: String?
    var socials: [String: String]?
    var privacy: [String: Bool]?
    var clubs: [String: Bool]?
    var sports: [String: Bool]?
    var tags: [String: String]?
}

struct Social: Codable, Hashable {
    var key: String
    var value: String
}

let socialOptions = [Social(key: "Phone", value: ""), Social(key: "Instagram", value: ""), Social(key: "Discord", value: ""), Social(key: "Snapchat", value: ""), Social(key: "TikTok", value: "")]

class UserFetcher: ObservableObject, Equatable {
    
    static func == (lhs: UserFetcher, rhs: UserFetcher) -> Bool {
        return lhs.user == rhs.user
    }
    
    @Published var user: User? = nil
    @Published var courses: [String: Course]? = nil
    
    init() {
        databaseLogger.log("user object initialized")
    }
    
    func observeData(emailID: String) {
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-users.firebaseio.com/").reference().child("users").child(cleanFirebaseKey(input: emailID))
        
        reference.observe(.value) { _ in
            reference.observeSingleEvent(of: .value) { (snapshot) in
                guard let value = snapshot.value else { return }
                do {
                    let decodedUser = try FirebaseDecoder().decode(User.self, from: value)
                    self.user = decodedUser
                    databaseLogger.log("user data observed")
                } catch let error {
                    databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
                }
            }
        }
    }
    
    func observeCourses(emailID: String) {
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-users.firebaseio.com/").reference().child("courses").child(cleanFirebaseKey(input: emailID))
        
        reference.observe(.value) { _ in
            reference.observeSingleEvent(of: .value) { (snapshot) in
                guard let value = snapshot.value else { return }
                do {
                    let decodedCourses = try FirebaseDecoder().decode([String: Course].self, from: value)
                    self.courses = decodedCourses
                    databaseLogger.log("course data observed")
                } catch let error {
                    databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
                }
            }
        }
    }
}


func fetchCurrentUser(emailID: String, completion: @escaping (User?)->()) {
    if !emailID.contains("@thecollegepreparatoryschool.org") || emailID.contains("@college-prep.org") {
        completion(nil)
    }
    
    var reference: DatabaseReference!
    reference = Database.database(url: "https://cps-campus-users.firebaseio.com/").reference().child("users").child(cleanFirebaseKey(input: emailID))
    
    reference.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
            let decodedUser = try FirebaseDecoder().decode(User.self, from: value)
            completion(decodedUser)
            databaseLogger.log("current user data fetched")
        } catch let error {
            completion(nil)
            databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
        }
    })
}

func fetchCourses(emailID: String, completion: @escaping ([String: Course]?)->()) {
    var reference: DatabaseReference!
    reference = Database.database(url: "https://cps-campus-users.firebaseio.com/").reference().child("courses").child(cleanFirebaseKey(input: emailID))
    
    reference.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
            let decodedCourses = try FirebaseDecoder().decode([String: Course].self, from: value)
            completion(decodedCourses)
            databaseLogger.log("course data fetched")
        } catch let error {
            completion(nil)
            databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
        }
    })
}

func fetchAllUsers(completion: @escaping ([User])->()) {
    var reference: DatabaseReference!
    reference = Database.database(url: "https://cps-campus-users.firebaseio.com/").reference().child("users")
    
    reference.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value else { return }
        do {
            let decodedUsers = try FirebaseDecoder().decode([String: User].self, from: value)
            completion(decodedUsers.values.map({$0}))
            databaseLogger.log("user data fetched")
        } catch let error {
            completion([])
            databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
        }
    })
}

func updateCurrentUser(emailID: String, user: User) {
    var reference: DatabaseReference!
    reference = Database.database(url: "https://cps-campus-users.firebaseio.com/").reference().child("users").child(cleanFirebaseKey(input: emailID))
    
    let updatedData: [String: Any] = ["id": user.id,
                                      "name": user.name,
                                      "gradYear": user.gradYear,
                                      "imageLink": user.imageLink,
                                      "pronouns": user.pronouns ?? "",
                                      "socials": user.socials ?? [:],
                                      "privacy": user.privacy ?? [:],
                                      "clubs": user.clubs ?? [:],
                                      "sports": user.sports ?? [:],
                                      "tags": user.tags ?? [:]]
    reference.setValue(updatedData)
}

func updateCurrentCourses(emailID: String, courses: [Course]) {
    var reference: DatabaseReference!
    reference = Database.database(url: "https://cps-campus-users.firebaseio.com/").reference().child("courses").child(cleanFirebaseKey(input: emailID))
    
    var courseDictionary = [String: [String: Any]]()
    for course in courses {
        let updatedData: [String: Any] = ["num": course.num,
                                          "id": course.id,
                                          "canvasID": course.canvasID,
                                          "compassBlock": course.compassBlock,
                                          "visibleRotations": course.visibleRotations,
                                          "isFreePeriod": course.isFreePeriod,
                                          "name": course.name,
                                          "teacher": course.teacher,
                                          "room": course.room,
                                          "color": course.color]
        courseDictionary.updateValue(updatedData, forKey: course.id)
    }
    reference.setValue(courseDictionary)
}

func cleanFirebaseKey(input: String) -> String {
    return input.replacingOccurrences(of: "@thecollegepreparatoryschool.org", with: "").replacingOccurrences(of: "@college-prep.org", with: "").replacingOccurrences(of: "@", with: "").replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "/", with: "")
}
