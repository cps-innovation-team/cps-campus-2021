//
//  CalendarModel.swift
//  CPS Campus (Shared) - CPS Schedule Legacy
//
//  7/11/2020
//  Designed by Rahim Malik in California.
//

import Foundation

struct EventCalModel: Equatable {
    static func == (lhs: EventCalModel, rhs: EventCalModel) -> Bool {
        return lhs.items == rhs.items
    }
    
    var items: [Item]
    
    struct Item: Codable, Equatable  {
        let id: String
        let status: String
        let summary: String
        let description: String
        let location: String
        let start: String
        let dateTime: String
        let timeZone: String
        let end: String
        let endDateTime: String
        let sort: String
    }
    
    init() {
        self.items = [Item]()
    }
    
    init(model: EventCal) {
        self.init()
        
        for index in 0..<model.items.count {
            let id = model.items[index].id
            let status = model.items[index].status
            let summary = model.items[index].summary ?? ""
            let description = model.items[index].description ?? ""
            let location = model.items[index].location ?? ""
            let start = model.items[index].start?.date ?? ""
            let dateTime = model.items[index].start?.dateTime ?? ""
            let timeZone = model.items[index].start?.timeZone ?? ""
            let end = model.items[index].end?.date ?? ""
            let endDateTime = model.items[index].end?.dateTime ?? ""
            let sort = model.items[index].start?.date ?? model.items[index].start?.dateTime
            if model.items[index].status == "cancelled" {
                
            } else {
                var sorted = ""
                if start == "" {
                    sorted = internalConvertDate(currentFormat: "yyyy-MM-dd'T'HH:mm:ssZ", newFormat: "dd", date: sort!)
                } else if dateTime == "" {
                    sorted = internalConvertDate(currentFormat: "yyyy-MM-dd", newFormat: "dd", date: sort!)
                }
                self.items.append(Item(id: id, status: status, summary: summary, description: description, location: location, start: start, dateTime: dateTime, timeZone: timeZone, end: end, endDateTime: endDateTime, sort: sorted))
            }
        }
    }
    
    func internalConvertDate(currentFormat: String, newFormat: String, date: String ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = currentFormat
        let newDate = formatter.date(from: date)
        formatter.dateFormat = newFormat
        let dateString = formatter.string(from: newDate!)
        
        return dateString
    }
}

// MARK: - EventCal
struct EventCal: Codable {
    var items: [Item]
}

// MARK: EventCal convenience initializers and mutators

extension EventCal {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(EventCal.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        items: [Item]? = nil
    ) -> EventCal {
        return EventCal(
            items: items ?? self.items
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Item
struct Item: Codable {
    var id, status: String
    var summary: String?
    var description: String?
    var start: Start?
    var end: End?
    var location: String?
    
}

// MARK: Item convenience initializers and mutators

extension Item {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Item.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        id: String? = nil,
        status: String? = nil,
        summary: String?? = nil,
        start: Start?? = nil,
        iCalUID: String? = nil
    ) -> Item {
        return Item(
            id: id ?? self.id,
            status: status ?? self.status,
            summary: summary ?? self.summary,
            start: start ?? self.start
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Start
struct Start: Codable {
    var date: String?
    var dateTime: String?
    var timeZone: String?
}

// MARK: Start convenience initializers and mutators

extension Start {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Start.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        date: String?? = nil,
        dateTime: String?? = nil,
        timeZone: String?? = nil
    ) -> Start {
        return Start(
            date: date ?? self.date,
            dateTime: dateTime ?? self.dateTime,
            timeZone: timeZone ?? self.timeZone
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Start
struct End: Codable {
    var date: String?
    var dateTime: String?
    var timeZone: String?
}

// MARK: Start convenience initializers and mutators

extension End {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(End.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        date: String?? = nil,
        dateTime: String?? = nil,
        timeZone: String?? = nil
    ) -> Start {
        return Start(
            date: date ?? self.date,
            dateTime: dateTime ?? self.dateTime,
            timeZone: timeZone ?? self.timeZone
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
