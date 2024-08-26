//
//  Definitions.swift
//  CPS Campus (Shared)
//
//  5/28/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI

//The following values need to be manually defined and updated when necessary

//MARK: - Role Groups
let freshClass = "2027"
let sophClass = "2026"
let juniorClass = "2025"
let seniorClass = "2024"

let compassGradYears = [freshClass, sophClass, juniorClass]

//MARK: - Date Groups
let fallYear = "2023"
let springYear = "2024"

let months: [(name: String, weeksOfYear: [Int], year: Int)] = [("August", Array(34...35), 2023), ("September", Array(36...39), 2023), ("October", Array(40...43), 2023), ("November", Array(44...48), 2023), ("December", Array(49...52), 2023), ("January", Array(2...5), 2024), ("February", Array(6...9), 2024), ("March", Array(10...13), 2024), ("April", Array(14...17), 2024), ("May", Array(18...22), 2024)]

//MARK: - Other Groups

let defaultQuickLinks = [QuickLink(name: "Common Classroom", id: "https://cpscampus.org/cc", icon: "rectangle.inset.filled.and.person.filled", visible: true), QuickLink(name: "Radar", id: "https://www.cpsradar.com", icon: "newspaper.fill", visible: false), QuickLink(name: "Library", id: "https://college-prep.libguides.com/home", icon: "books.vertical.fill", visible: false), QuickLink(name: "Submit Feedback", id: "https://forms.gle/VSV2u4X2LoTBd49U6", icon: "exclamationmark.bubble.fill", visible: true)]

let defaultForYouPage = [ForYouItem(id: "Map", icon: "map.fill", visible: true), ForYouItem(id: "Clubs", icon: "theatermask.and.paintbrush.fill", visible: true), ForYouItem(id: "Sports", icon: "sportscourt.fill", visible: true), ForYouItem(id: "RHF", icon: "figure.badminton", visible: true), ForYouItem(id: "Links", icon: "link", visible: true)]

let clubCategories = ["Affinities", "Activism", "Arts", "Fitness", "Humanities", "Lifestyle", "Politics/Economics", "STEM"]
let sportCategories = ["Basketball", "Soccer", "Volleyball", "Running", "Tennis", "Other"]

//MARK: - Course Groups
let defaultCourses = [Course(num: 0, id: "A-Block", canvasID: "", compassBlock: "A-Block", visibleRotations: 0, isFreePeriod: false, name: "A-Block", teacher: "", room: "", color: defaultPalette.colorsHex[0]),
                      Course(num: 1, id: "B-Block", canvasID: "", compassBlock: "B-Block", visibleRotations: 0, isFreePeriod: false, name: "B-Block", teacher: "", room: "", color: defaultPalette.colorsHex[1]),
                      Course(num: 2, id: "C-Block", canvasID: "", compassBlock: "C-Block", visibleRotations: 0, isFreePeriod: false, name: "C-Block", teacher: "", room: "", color: defaultPalette.colorsHex[2]),
                      Course(num: 3, id: "D-Block", canvasID: "", compassBlock: "D-Block", visibleRotations: 0, isFreePeriod: false, name: "D-Block", teacher: "", room: "", color: defaultPalette.colorsHex[3]),
                      Course(num: 4, id: "E-Block", canvasID: "", compassBlock: "E-Block", visibleRotations: 0, isFreePeriod: false, name: "E-Block", teacher: "", room: "", color: defaultPalette.colorsHex[4]),
                      Course(num: 5, id: "F-Block", canvasID: "", compassBlock: "F-Block", visibleRotations: 0, isFreePeriod: false, name: "F-Block", teacher: "", room: "", color: defaultPalette.colorsHex[5]),
                      Course(num: 6, id: "G-Block", canvasID: "", compassBlock: "G-Block", visibleRotations: 0, isFreePeriod: false, name: "G-Block", teacher: "", room: "", color: defaultPalette.colorsHex[6]),
                      Course(num: 7, id: "H-Block", canvasID: "", compassBlock: "H-Block", visibleRotations: 0, isFreePeriod: false, name: "H-Block", teacher: "", room: "", color: defaultPalette.colorsHex[7]),
                      Course(num: 8, id: "Compass", canvasID: "", compassBlock: "A-Block", visibleRotations: 1, isFreePeriod: false, name: "Wellness", teacher: "", room: "", color: defaultPalette.colorsHex[8]),
                      Course(num: 9, id: "X-Block", canvasID: "", compassBlock: "A-Block", visibleRotations: 0, isFreePeriod: false, name: "X-Block", teacher: "", room: "", color: defaultPalette.colorsHex[8]),
                      Course(num: 10, id: "Assembly", canvasID: "", compassBlock: "Assembly", visibleRotations: 0, isFreePeriod: false, name: "Assembly", teacher: "", room: "", color: defaultPalette.colorsHex[8]),
                      Course(num: 11, id: "Advising", canvasID: "", compassBlock: "Advising", visibleRotations: 0, isFreePeriod: false, name: "Advising", teacher: "", room: "", color: defaultPalette.colorsHex[8]),
                      Course(num: 12, id: "Common Classroom", canvasID: "", compassBlock: "Common Classroom", visibleRotations: 0, isFreePeriod: false, name: "CC", teacher: "", room: "", color: defaultPalette.colorsHex[8])]

let allAssignableCourses = ["A-Block", "B-Block", "C-Block", "D-Block", "E-Block", "F-Block", "G-Block", "H-Block", "X-Block", "Assembly", "Advising", "Common Classroom", "Compass"]
let coursesGroup = ["A-Block", "B-Block", "C-Block", "D-Block", "E-Block", "F-Block", "G-Block", "H-Block"]
let communityGroup = ["X-Block", "Assembly", "Advising", "Common Classroom"]

let rotation1and3Group = ["A-Block", "B-Block", "C-Block", "D-Block"]
let rotation2and4Group = ["E-Block", "F-Block", "G-Block", "H-Block"]

//arrays to tell CoursesView for which courses to not include certain fields
let noTeachers = ["X-Block", "Assembly", "Common Classroom"]
let noRooms = ["X-Block", "Assembly", "Common Classroom"]
let noFreePeriods = ["X-Block", "Assembly", "Advising", "Common Classroom", "Compass"]

//MARK: Palette Groups

let defaultPalette = Palette(name: "Mochi Madness", colorsHex: ["8B7272","58CAFF","F2BAC3","B0F56F","FBC5FF","FF89D0","FDA90F","0CCBE4","CBB5B5"], campusID: "rmalik", creator: "")

let defaultPalettes: [Palette] = [palette1, palette2, palette3, palette4, palette5, palette6, palette7, palette8, palette9, palette10, palette11, palette12]

let palette1 = Palette(name: "Mochi Madness", colorsHex: ["8B7272","58CAFF","F2BAC3","B0F56F","FBC5FF","FF89D0","FDA90F","0CCBE4","CBB5B5"], campusID: "appdev", creator: "")
let palette2 = Palette(name: "Strawberry Shortcake", colorsHex: ["d6d2d2","f1e4f3","f4bbd3","f686bd","fe5d9f","ffdde2","efd6d2","6f5e76","de369d"], campusID: "appdev", creator: "")
let palette3 = Palette(name: "Flamingo Safari", colorsHex: ["E980B1","d14081","ef798a","ffd4ca","A5E1FA","359DDD","42e2b8","f3dfbf","82d173"], campusID: "appdev", creator: "")
let palette4 = Palette(name: "Xenopus Tropicalis", colorsHex: ["8DEDEB","8AE9B1","67CFB2","4580B0","bee9e8","62b6cb","55AAD1","54928E","9ABDCF"], campusID: "appdev", creator: "")
let palette5 = Palette(name: "Squidward's House", colorsHex: ["896978","839791","BE7AB0","ffd4ca","efd5c3","f9a03f","284A6E","373C51","5A6174"], campusID: "appdev", creator: "")
let palette6 = Palette(name: "Laffy Taffy", colorsHex: ["FFCE75","FFF1DD","F80C97","FF89D0","89B2C0","FDA90F","FBC5FF","9FC6FF","6AA5FF"], campusID: "appdev", creator: "")
let palette7 = Palette(name: "Starfish Kisses", colorsHex: ["FF8054","FFC3A0","FDA90F","6DE8D7","72E0EF","99D3FF","0C75E4","FF89D0","CE38A6"], campusID: "appdev", creator: "")
let palette8 = Palette(name: "E. coli Incubator", colorsHex: ["3071C5","42bfdd","bbe6e4","ff66b3","A5848A","f7accf","DAE0F1","6874e8","00B1B8"], campusID: "appdev", creator: "")
let palette9 = Palette(name: "Boysenberry Jam", colorsHex: ["FF009F","F342BD","F685BB","C42CE4","4355FB","FF73E3","D279FF","892AFF","499BF1"], campusID: "appdev", creator: "")
let palette10 = Palette(name: "Salt-crusted Sea Bass", colorsHex: ["5a7d7c","dadff7","2e4756","a0c1d1","b5b2c2","ee4266","B3C9A7","B6DDDC","e55381"], campusID: "appdev", creator: "")
let palette11 = Palette(name: "Rocket Rabboon", colorsHex: ["b5b2c2","6f5e76","e88873","e0ac9d","809bce","95b8d1","b8e0d2","a37774","eac4d5"], campusID: "appdev", creator: "")
let palette12 = Palette(name: "Rainwing Tears", colorsHex: ["FD335B","FF786A","78D3F8","0C75E4","FDA90F","F80C97","D005D4","7244F5","40B7FF"], campusID: "appdev", creator: "Rahim, Zoya, and Aiza Malik")
