//
//  ComClassDB.swift
//  CPS Campus (Shared)
//
//  1/3/2023
//  Designed by Rahim Malik in California.
//

import Foundation

struct CommonClassroom: Codable {
    let title, date, room: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "ccTitle"
        case date = "ccDate"
        case room = "ccRoom"
        case message = "ccMessage"
    }
}

func getUserCommonClassroom(userName: String, userEmail: String, completion: @escaping (CommonClassroom?)->()) {
    
    var requestComponents = URLComponents()
    requestComponents.scheme = "https"
    requestComponents.host = "cpscampus.com"
    requestComponents.path = "/_functions/userCommonClassroom"
    
    requestComponents.queryItems = [
        URLQueryItem(name: "userName", value: userName),
        URLQueryItem(name: "userEmail", value: userEmail)
    ]
    
    var requestURL = URLRequest(url: requestComponents.url!)
    requestURL.httpMethod = "GET"
    //cc_API_Key
    requestURL.setValue("", forHTTPHeaderField: "authorization")
    
    URLSession.shared.dataTask(with: requestURL) { data,response,error in
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let decoder = JSONDecoder()
                            let decoded = try decoder.decode(CommonClassroom.self, from: data)
                            completion(decoded)
                        } catch {
                            completion(nil)
                            databaseLogger.error("cc decode error > \(error, privacy: .public)")
                        }
                    }
                }
                guard error == nil else {
                    completion(nil)
                    databaseLogger.error("cc access error > \(error, privacy: .public)")
                    return
                }
            } else {
                databaseLogger.log("cc httpRespons > \(httpResponse, privacy: .public)")
            }
        }
    }.resume()
}
