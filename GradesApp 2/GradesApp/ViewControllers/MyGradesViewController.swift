//
//  MyGradesViewController.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import UIKit
import Firebase

class MyGradesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var gpaLabel: UILabel!
    
    var grades = [Grade]()
    var firestore: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
        tableView.register(UINib(nibName: "GradesTableViewCell", bundle: nil), forCellReuseIdentifier: "GradesTableViewCell")
        fetchGrades()
    }
    
    func showAddCourseViewController() {
            let addCourseVC = AddCourseViewController()
            addCourseVC.onSubmit = { [weak self] semester, course, grade in
                // Handle the submitted values here
                // Example: Update UI or send data to Firestore
                print("Selected Semester: \(String(describing: semester.name)), Course: \(String(describing: course.number)), Grade: \(String(describing: grade.letter))")
        }
        navigationController?.pushViewController(addCourseVC, animated: true)
    }
    func fetchGrades() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
                return
            }

            firestore.collection("grades")
                .whereField("userUid", isEqualTo: currentUserID)
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching grades: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }

                    self?.grades.removeAll()
                    var totalCreditHours = 0.0
                    var totalGradePoints = 0.0
                    for document in documents {
                        let grade = Grade(snapshot: document)
                        self?.grades.append(grade)
                                        
                        if let gradePoints = self?.gradePoints(for: grade.letterGrade!) {
                            let gradePoint = gradePoints * (grade.courseHours ?? 0.0)
                            totalGradePoints += gradePoint
                            totalCreditHours += grade.courseHours ?? 0.0
                        }
                    }

                    self?.hoursLabel.text = String(format: "Hours: %.1f", totalCreditHours)
                                    
                    let gpa = totalGradePoints / totalCreditHours
                    self?.gpaLabel.text = String(format: "GPA: %.1f", gpa)

                    self?.tableView.reloadData()
            }
    }
    
    private func gradePoints(for letterGrade: String) -> Double {
            switch letterGrade {
            case "A":
                return 4.0
            case "B":
                return 3.0
            case "C":
                return 2.0
            case "D":
                return 1.0
            case "F":
                return 0.0
            default:
                return 0.0 
            }
        }
    
    @IBAction func logoutClicked(_ sender: Any) {
    
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            SceneDelegate.showLogin()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
            showAlertWith(title: "Logout Error", message: signOutError.localizedDescription, okAlertAction: nil)
        }
        
    }
}

extension MyGradesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grades.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GradesTableViewCell", for: indexPath) as! GradesTableViewCell
        let grade = self.grades[indexPath.row]
        cell.bind(grade: grade, gradeDelegage: self)
        
        cell.letterGradeLabel.text = grade.letterGrade!
        cell.courseNumberLabel.text = grade.courseNumber!
        cell.courseNameLabel.text = grade.courseName!
        cell.semesterLabel.text = grade.semester!
        cell.creditHoursLabel.text = "\(grade.courseHours ?? 0.0) Credit Hours"

        return cell
    }
}

extension MyGradesViewController: GradesDelegate {
    func deleteClicked(_ grade: Grade) {
        let gradeRef = firestore.collection("grades").document(grade.docId!)
        gradeRef.delete { [weak self] error in
            if let error = error {
                print("Error deleting grade: \(error.localizedDescription)")
            } else {
                print("Grade deleted successfully")
                self?.fetchGrades() // Refresh grades after deletion
            }
        }
    }
}
