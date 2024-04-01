//
//  AddCourseViewController.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import UIKit
import Firebase
import PKHUD
import Alamofire
import SwiftyJSON

class AddCourseViewController: UIViewController {
    var selectedSemester: Semester?
    var selectedGrade: LetterGrade?
    var selectedCourse: Course?{
        didSet {
            // When the selected course is set, update the UI with the course number
            if let courseNumber = selectedCourse?.number {
                courseLabel.text = courseNumber
                fetchCourseDetails(courseNumber: courseNumber) // Fetch course details
            }
        }
    }
    
    
    var db: Firestore!
    
    var onSubmit: ((Semester, Course, LetterGrade) -> Void)?
    
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var semesterLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedSelectedSemester(notification:)), name: Notification.Name("NotifySelectedSemester"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedSelectedGrade(notification:)), name: Notification.Name("NotifySelectedGrade"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedSelectedCourse(notification:)), name: Notification.Name("NotifySelectedCourse"), object: nil)
    }
    
    @objc func receivedSelectedSemester(notification: Notification){
        self.selectedSemester = notification.object as? Semester
        self.semesterLabel.text = self.selectedSemester!.name!
    }
    
    @objc func receivedSelectedGrade(notification: Notification){
        self.selectedGrade = notification.object as? LetterGrade
        self.gradeLabel.text = self.selectedGrade!.letter!
    }
    
    @objc func receivedSelectedCourse(notification: Notification){
        self.selectedCourse = notification.object as? Course
        self.courseLabel.text = self.selectedCourse!.number!
        fetchCourseDetails(courseNumber: self.selectedCourse!.number!)
    }

    func fetchCourseDetails(courseNumber: String) {
        db.collection("courses").whereField("number", isEqualTo: courseNumber).getDocuments() { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                            print("Error fetching course details: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let document = documents.first {
                let courseData = document.data()
                if let courseHours = courseData["hours"] as? Double {
                                // Update the selected course with credit hours
                    self?.selectedCourse?.hours = courseHours
                                
                                // Update UI
                    DispatchQueue.main.async {
                                    // Update any UI elements that depend on the course hours here
                                    // For example:
//                                     self?.creditHoursLabel.text = "\(courseHours) Credit Hours"
                    }
                }
            }
        }
        
//        db.collection("courses").whereField("number", isEqualTo: courseNumber)
//                .getDocuments() { [weak self] (querySnapshot, error) in
//                    guard let documents = querySnapshot?.documents else {
//                        print("Error fetching course details: \(error?.localizedDescription ?? "Unknown error")")
//                        return
//                    }
//
//                    if let document = documents.first {
//                        let courseData = document.data()
//                        if let courseHours = courseData["hours"] as? Double {
//                            // Update the selected course with credit hours
//                            self?.selectedCourse?.hours = courseHours
//                        }
//                    }
//            }
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        guard let selectedSemester = selectedSemester,
            let selectedCourse = selectedCourse,
            let selectedGrade = selectedGrade else {
            self.showAlertWith(title: "Create Course Error", message: "All fields are required!", okAlertAction: nil)
            return
        }
        let dbRef = db.collection ("grades").document()
                
        let data: [String: Any] = [
            "docId": dbRef.documentID,
            "courseName": selectedCourse.name ?? "",
            "courseNumber": selectedCourse.number ?? "",
            "letterGrade": selectedGrade.letter ?? "",
//            "numericGrade": selectedGrade.numericGrade ?? 0.0,
            "creditHours": selectedCourse.hours ?? 0.0,
            "semester": selectedSemester.name ?? "",
            "userUid": Auth.auth().currentUser?.uid ?? ""
        ]

                
        db.collection("grades").addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error)")
                self.showAlertWith(title: "Error", message: "Failed to save data. Please try again.", okAlertAction: nil)
            } else {
                print("Document added successfully!")
                self.onSubmit?(selectedSemester, selectedCourse, selectedGrade)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
