//
//  TypeHelpers.swift
//  CPS Campus (Shared)
//
//  6/19/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import os // for loggers

//MARK: - Loggers
let authLogger = Logger(subsystem: "com.TheCollegePreparatorySchool.ScheduleApp", category: "authentication")
let databaseLogger = Logger(subsystem: "com.TheCollegePreparatorySchool.ScheduleApp", category: "databases")
let consoleLogger = Logger(subsystem: "com.TheCollegePreparatorySchool.ScheduleApp", category: "console")

//MARK: - Universal Models
struct Block: Codable, Hashable, Identifiable {
    var id: String
    var title: String
    var startTime: String
    var endTime: String
    var dates: [String]
    var type: String
}

struct Course: Codable, Identifiable, Hashable, Equatable {
    var num: Int
    var id: String
    var canvasID: String
    var compassBlock: String
    var visibleRotations: Int
    var isFreePeriod: Bool
    
    var name: String
    var teacher: String
    var room: String
    var color: String
}

struct Palette: Codable, Identifiable, Hashable {
    var id = UUID().uuidString
    var name: String
    var colorsHex: [String]
    var campusID: String
    var creator: String
}

struct PaletteCollection: Codable, Hashable {
    var name: String
    var palettes: [Palette]
}

struct CalendarEvent: Codable, Hashable, Identifiable {
    var id = UUID()
    var title: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var location: String
    var notes: String
    var availability: Int
}

struct ForYouItem: Hashable, Codable, Equatable {
    let id: String
    let icon: String
    var visible: Bool
}

struct QuickLink: Codable, Hashable, Identifiable {
    var name: String
    var id: String
    var icon: String
    var visible: Bool
}

struct RHFCell: Codable {
    let id, points: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case points = "Points"
    }
}

//MARK: - Date Manipulation
func reformatDateString(date: String, currentDateFormat: String, newDateFormat: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = currentDateFormat
    let finalDate = formatter.date(from: date) ?? Date()
    formatter.dateFormat = newDateFormat
    return(formatter.string(from: finalDate))
}

func convertDatetoString(date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return(formatter.string(from: date))
}

func convertStringtoDate(string: String, format: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return(formatter.date(from: string) ?? Date())
}

func createAllDayDate(weekday: Int, weekOfYear: Int, year: Int) -> Date {
    var output = Date()
    var dateComponents = DateComponents()
    dateComponents.weekday = weekday
    dateComponents.weekOfYear = weekOfYear
    dateComponents.year = year
    output = Calendar.current.date(from: dateComponents) ?? Date()
    return output
}

func getCalendarDate(allday: String, dateTime: String) -> Date {
    if dateTime.isEmpty == false {
        return (convertStringtoDate(string: dateTime, format: "yyyy-MM-dd'T'HH:mm:ssZ"))
    } else if allday.isEmpty == false {
        return (convertStringtoDate(string: allday, format: "yyyy-MM-dd"))
    } else {
        return(Date())
    }
}

//MARK: - String Manipulation
func extractURLS(input: String) -> [URL] {
    var array = [URL]()
    let types: NSTextCheckingResult.CheckingType = .link
    let detector = try? NSDataDetector(types: types.rawValue)
    let matches = detector!.matches(in: input, options: .reportCompletion, range: NSMakeRange(0, input.count))
    for match in matches {
        array.append(URL(string: match.url!.absoluteString.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "1600x1200", with: "800x600")) ?? URL(string: "https://college-prep.org")!)
    }
    return array
}

//MARK: - String Converters

func boolArraytoTrueCount(array: [Bool]) -> Int {
    var count = 0
    for bool in array {
        if bool {
            count += 1
        }
    }
    return count
}

//for phone number formatting
func format(phoneNumber sourcePhoneNumber: String) -> String? {
    // Remove any character that is not a number
    let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let length = numbersOnly.count
    let hasLeadingOne = numbersOnly.hasPrefix("1")
    
    // Check for supported phone number length
    guard length == 7 || (length == 10 && !hasLeadingOne) || (length == 11 && hasLeadingOne) else {
        return nil
    }
    
    let hasAreaCode = (length >= 10)
    var sourceIndex = 0
    
    // Leading 1
    var leadingOne = ""
    if hasLeadingOne {
        leadingOne = "+1 "
        sourceIndex += 1
    }
    
    // Area code
    var areaCode = ""
    if hasAreaCode {
        let areaCodeLength = 3
        guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
            return nil
        }
        areaCode = String(format: "(%@) ", areaCodeSubstring)
        sourceIndex += areaCodeLength
    }
    
    // Prefix, 3 characters
    let prefixLength = 3
    guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
        return nil
    }
    sourceIndex += prefixLength
    
    // Suffix, 4 characters
    let suffixLength = 4
    guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
        return nil
    }
    
    return leadingOne + areaCode + prefix + "-" + suffix
}

//MARK: - Type Extensions

extension String {
    func markdownToAttributed() -> AttributedString {
        do {
            return try AttributedString(markdown: self) /// convert to AttributedString
        } catch {
            return AttributedString("Error parsing markdown: \(error)")
        }
    }
}

extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension Dictionary: RawRepresentable where Key == String, Value: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([String:Value].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return result
    }
    
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension Color {
    public static let tintColor = Color("AccentColor")
}

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}

struct JSONCodingKeys: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

struct FailableCodableArray<Element : Codable> : Codable {
    
    var elements: [Element]
    
    init(from decoder: Decoder) throws {
        
        var container = try decoder.unkeyedContainer()
        
        var elements = [Element]()
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        
        while !container.isAtEnd {
            if let element = try container
                .decode(FailableDecodable<Element>.self).base {
                
                elements.append(element)
            }
        }
        
        self.elements = elements
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(elements)
    }
}

struct FailableDecodable<Base : Decodable> : Decodable {
    
    let base: Base?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

extension KeyedDecodingContainer {
    
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

//MARK: - Storage Removal
func ResetStores() {
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "ClassMinutes")
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "ClubMinutes")
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "SportsMinutes")
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "NotificationPreferences")
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "CommunityRole")
    
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "ScheduleBackups")
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "CourseBackups")
    
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "SettingsBadgeCount")
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "CompassAlert")
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "ScheduleBackups")
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "SetUpSheet")
    UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")?.removeObject(forKey: "Arrangement3")
}
