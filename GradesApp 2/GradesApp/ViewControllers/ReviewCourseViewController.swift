//
//  ReviewCourseViewController.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import UIKit
import Firebase

class ReviewCourseViewController: UIViewController {
    @IBOutlet weak var courseNumberLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseHoursLabel: UILabel!
    @IBOutlet weak var reviewTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var course: Course?
    var reviews = [Review]()
    var currentUserID: String?    
    var currentUserName: String?
    var firestore: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        firestore = Firestore.firestore()

        self.tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewTableViewCell")
        
        if let course = course{
            courseNameLabel.text = course.name
            courseNumberLabel.text = course.number
            courseHoursLabel.text = "\(course.hours!) Credit Hours"
            fetchReviews()
            
        }
        currentUserID = Auth.auth().currentUser?.uid
        
        if let currentUser = Auth.auth().currentUser {
                self.currentUserName = currentUser.displayName
            }
    }
    
    func fetchReviews() {
        guard let course = course else { return }
        let courseID = course.courseId

        firestore.collection("courses").document(courseID!).collection("reviews")
                .whereField("courseID", isEqualTo: course.courseId ?? "")
                .getDocuments { [weak self] (querySnapshot, error) in
                    guard let snapshot = querySnapshot, error == nil else {
                        print("Error fetching reviews: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    self?.reviews = snapshot.documents.compactMap { document in
                        let data = document.data()
                        guard let text = data["text"] as? String,
                              let userID = data["userID"] as? String,
                              let userName = data["userName"] as? String,
                              let createdAt = data["createdAt"] as? Timestamp else {
                            print("Error parsing review data from document")
                            return nil
                        }
                        return Review(id: document.documentID, text: text, userID: userID, userName: userName, createdAt: createdAt)
                    }
                    self?.tableView.reloadData() // Reload the table view after fetching reviews
                }
        }
    
    @IBAction func submitClicked(_ sender: Any) {
        guard let reviewText = reviewTextField.text, !reviewText.isEmpty,
                    let currentUserID = currentUserID,
                    let courseID = course?.courseId else {
                  showAlertWith(title: "Review Error", message: "Enter review text!", okAlertAction: nil)
                  return
              }
              
            // Set the current user's name
            if let currentUser = Auth.auth().currentUser {
                self.currentUserName = currentUser.displayName
            }
            
            let reviewData: [String: Any] = [
                "text": reviewText,
                "userID": currentUserID,
                "userName": currentUserName ?? "Blah", 
                "courseID": courseID,
                "createdAt": Timestamp(date: Date())
            ]
            
        firestore.collection("courses").document(courseID).collection("reviews").addDocument(data: reviewData) { [weak self] (error) in
                if let error = error {
                    print("Error adding review: \(error.localizedDescription)")
                } else {
                    print("Review added successfully")
                    self?.fetchReviews()
                    self?.reviewTextField.text = "" 
                }
            }
        }
    
    @IBAction func cancelClicked(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
//        NotificationCenter.default.post(name: Notification.Name("reloadTable"), object: nil)
    }
    
    func addReview() {
        fetchReviews()
    }
}



extension ReviewCourseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as! ReviewTableViewCell
            let review = reviews[indexPath.row]
            
            // Define an instance of ReviewDelegate
            let reviewDelegate: ReviewDelegate = self
        cell.bind(review: review, reviewDelegate: reviewDelegate, currentUserName: review.userName)
            
            return cell
    }
}

extension ReviewCourseViewController: ReviewDelegate{
        func deleteClicked(_ review: Review) {
            guard !review.id.isEmpty, let courseID = course?.courseId else {
                print("Review ID is empty")
                return
            }
            
            let reviewRef = firestore.collection("courses").document(courseID).collection("reviews").document(review.id)
            reviewRef.delete { error in
                if let error = error {
                    print("Error deleting review: \(error.localizedDescription)")
                } else {
                    print("Review deleted successfully")
                    self.fetchReviews()
                }
            }
        }
}
