//
//  Review.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

//import Foundation
//import Firebase
//import FirebaseAuth
//import FirebaseFirestore
//
//class Review : Codable {
//    var id: String
//    var text: String
//    var userID: String
//    
//    init(snapshot: document) {
//        self.id = snapshot.documentID
//        let data = snapshot.data() ?? [:]
//        self.text = (data["text"] as? String)!
//        self.userID = (data["userID"] as? String)!
//    }
//}

import Foundation
import Firebase

class Review {
    var id: String
    var text: String
    var userID: String
    var userName: String
    var createdAt: Timestamp?

    init(id: String, text: String, userID: String, userName: String, createdAt: Timestamp?) {
        self.id = id
        self.text = text
        self.userID = userID
        self.userName = userName
        print(userName)
        self.createdAt = createdAt
    }
}
