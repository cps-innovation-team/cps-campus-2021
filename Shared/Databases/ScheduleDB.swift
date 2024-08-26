//
//  ScheduleDatabase.swift
//  CPS Campus (Shared)
//
//  6/19/2022
//  Designed by Rahim Malik in California.
//

import Foundation
import Firebase
import FirebaseDatabase
import CodableFirebase

class BlocksFetcher: ObservableObject, Equatable {
    
    static func == (lhs: BlocksFetcher, rhs: BlocksFetcher) -> Bool {
        return lhs.blocks == rhs.blocks
    }
    
    @Published var blocks: [Block] = []
    
    init() {
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-schedule.firebaseio.com/").reference()
        
        reference.observe(.value) { (snapshot) in
            reference.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let value = snapshot.value else { return }
                do {
                    let products = try FirebaseDecoder().decode([String: Block].self, from: value)
                    self.blocks = products.values.map{$0}.sorted { convertStringtoDate(string: $0.startTime, format: "HH:mm") < convertStringtoDate(string: $1.startTime, format: "HH:mm") }
                    databaseLogger.log("schedule data initialized")
                } catch let error {
                    databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
                }
            })
        }
    }
    
    func fetchData(completion: @escaping ([Block]?)->()) {
        
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-schedule.firebaseio.com/").reference()
        
        var output = [Block]()
        
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                let products = try FirebaseDecoder().decode([String: Block].self, from: value)
                output = products.values.map{$0}.sorted { convertStringtoDate(string: $0.startTime, format: "HH:mm") < convertStringtoDate(string: $1.startTime, format: "HH:mm") }
                completion(output)
                databaseLogger.log("schedule data fetched")
            } catch let error {
                completion(nil)
                databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
            }
        })
    }
}
