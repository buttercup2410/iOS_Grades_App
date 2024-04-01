//
//  Grade.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class Grade : Codable {
    var docId: String?
    var courseName: String?
    var courseNumber: String?
    var letterGrade: String?
    var courseHours: Double?
    var semester: String?
    var userUid: String?
//    var userName: String?
    
    init(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        self.docId = snapshot.documentID
        self.courseName = data["courseName"] as? String
        self.courseNumber = data["courseNumber"] as? String
        self.letterGrade = data["letterGrade"] as? String
        self.courseHours = data["creditHours"] as? Double 
        self.semester = data["semester"] as? String
        self.userUid = data["userUid"] as? String
//        self.userName = data["userName"] as? String

    }
}
