//
//  CourseReviewsViewController.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON
import FirebaseFirestore
import FirebaseAuth

class CourseReviewsViewController: UIViewController {

    var courseReviews = [CourseReview]()
    var courses = [Course]()
    var currentUserID: String?
    var currentUserName: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool){
        self.tableView.reloadData()
    }
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "CourseReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseReviewTableViewCell")
        getCourses()
        currentUserID = Auth.auth().currentUser?.uid
        fetchCurrentUserName()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(
//        self.reloadMyTable(notification:)), name: Notification.Name("reloadTable"),
//        object: nil)
            
    }
    
//    func reloadMyTable(notification: Notification) {
//
//     self.tableView.reloadData()
//    }
    
    func getCourses(){
        courses.removeAll()
        HUD.show(.labeledProgress(title: "Loading Courses", subtitle: "Please Wait!"))
        AF.request("https://www.theappsdr.com/api/cci-courses")
            .validate(statusCode: 200..<300)
                .responseData { response in
                    HUD.hide()
                    switch response.result {
                    case .success:
                        if let data = response.data {
                            if let json = try? JSON(data: data) {
                                let coursesArray = json["courses"].arrayValue
                                for item in coursesArray {
                                    self.courses.append(Course(item))
                                }
                                self.tableView.reloadData()
                            } else {
                                self.showAlertWith(title: "Course Error", message: "Unable to load courses", okAlertAction: nil)
                            }
                        } else {
                            self.showAlertWith(title: "Course Error", message: "Unable to load courses", okAlertAction: nil)
                        }
                        
                    case let .failure(error):
                        print(error)
                        self.showAlertWith(title: "Course Error", message: "Unable to load courses", okAlertAction: nil)
                    }
                }
        
    }
    
    func fetchCurrentUserName() {
        guard let currentUser = Auth.auth().currentUser else { return }
        currentUser.reload { [weak self] error in
            if let error = error {
                print("Error reloading user: \(error.localizedDescription)")
                return
            }
                if let displayName = currentUser.displayName {
                self?.currentUserName = displayName
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoReviewCourseSegue" {
            let vc = segue.destination as! ReviewCourseViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            vc.course = self.courses[indexPath.row]
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}


extension CourseReviewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseReviewTableViewCell", for: indexPath) as! CourseReviewTableViewCell
        let course = self.courses[indexPath.row]
        
        fetchNumReviews(for: course) { numReviews in
            DispatchQueue.main.async { [self] in
                if let numReviews = numReviews {
                    cell.bind(course: course, courseReviewDelegate: self, numReviews: numReviews)
                } else {
                    cell.bind(course: course, courseReviewDelegate: self, numReviews: 0)
                }
                        
                cell.courseNameLabel.text = course.name
                cell.courseNumberLabel.text = course.number
                cell.creditHoursLabel.text = "\(course.hours!) Credit Hours"
//                if
                                            
                cell.heartButton.tag = indexPath.row
                cell.heartButton.addTarget(self, action: #selector(heartButtonTapped(_:)), for: .touchUpInside)
            }
        }
        return cell
    }
    
    @objc func heartButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let course = self.courses[indexPath.row]
        heartClicked(course)
    }
    
    func heartClicked(_ course: Course) {
        course.isFavorite = !course.isFavorite
        updateFavoriteStatus(course: course)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GotoReviewCourseSegue", sender: self)
    }
    
    @IBAction func unwindFromReviewCourseVC(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
}

extension CourseReviewsViewController : CourseReviewDelegate {
    
    
    func fetchNumReviews(for course: Course, completion: @escaping (Int?) -> Void) {
        let db = Firestore.firestore()
        db.collection("courses").document(course.courseId!).collection("reviews").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching reviews: \(error.localizedDescription)")
                completion(nil)
            } else {
                let numReviews = snapshot?.documents.count ?? 0
                completion(numReviews)
            }
        }
    }
    func updateFavoriteStatus(course: Course) {
        let db = Firestore.firestore()
        let courseRef = db.collection("courses").document(course.courseId!)

        if course.isFavorite {
            if let currentUserID = currentUserID {
                courseRef.collection("favoritedUsers").document(currentUserID).setData(["userID": currentUserID]) { error in
                    if let error = error {
                        print("Error adding favorited user: \(error.localizedDescription)")
                    } else {
                        print("Favorited user added successfully")
                    }
                }
            }
        } else {
            if let currentUserID = currentUserID {
                courseRef.collection("favoritedUsers").document(currentUserID).delete { error in
                    if let error = error {
                        print("Error removing favorited user: \(error.localizedDescription)")
                    } else {
                        print("Favorited user removed successfully")
                    }
                }
            }
        }
    }
}
