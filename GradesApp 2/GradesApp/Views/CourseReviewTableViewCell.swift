//
//  CourseReviewTableViewCell.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol CourseReviewDelegate {
    func heartClicked(_ course: Course)
}

class CourseReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var courseNumberLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var creditHoursLabel: UILabel!
    @IBOutlet weak var numReviewsLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    
    var course: Course?
    var courseReviewDelegate: CourseReviewDelegate?
    
    func bind(course: Course, courseReviewDelegate: CourseReviewDelegate, numReviews: Int) {
        self.course = course
        self.courseReviewDelegate = courseReviewDelegate
        updateHeartButton()
        numReviewsLabel.text = "\(numReviews) Reviews"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onHeartClicked))
        heartButton.addGestureRecognizer(tapGesture)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onHeartClicked(_ sender: Any) {
        guard let course = self.course else { return }
        self.courseReviewDelegate?.heartClicked(course)
        updateHeartButton()
    }
    
    func updateHeartButton() {
        guard let course = self.course else { return }
        if let currentUserID = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let favoritedUsersRef = db.collection("courses").document(course.courseId!).collection("favoritedUsers").document(currentUserID)
            
            favoritedUsersRef.getDocument { [weak self] document, error in
                guard let self = self else { return }
                
                var imageName: String
                
                if let document = document, document.exists {
                    // Current user's ID is present in the subcollection
                    imageName = "ic_heart_full"
                } else {
                    // Current user's ID is not present in the subcollection
                    imageName = "ic_heart_empty"
                }
                
                let image = UIImage(named: imageName)
                self.heartButton.setImage(image, for: .normal)
            }
        } else {
            // User is not logged in, set default heart button image
            let imageName = "ic_heart_empty"
            let image = UIImage(named: imageName)
            heartButton.setImage(image, for: .normal)
        }
    }

    
//    func updateHeartButton() {
//        
//        guard let course = self.course else { return }
//        let imageName = course.isFavorite ? "ic_heart_full" : "ic_heart_empty"
//        let image = UIImage(named: imageName)
//        heartButton.setImage(image, for: .normal)
//    }
    
    func getFavoriteCount(courseID: String, completion: @escaping (Int?) -> Void) {
        let db = Firestore.firestore()
        let courseRef = db.collection("courses").document(courseID)
        
        courseRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let favoriteCount = data?["favoriteCount"] as? Int
                completion(favoriteCount)
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
    
    func updateFavoriteCount(courseID: String, newCount: Int) {
        let db = Firestore.firestore()
        let courseRef = db.collection("courses").document(courseID)
        
        courseRef.updateData(["favoriteCount": newCount]) { error in
            if let error = error {
                print("Error updating favorite count: \(error.localizedDescription)")
            } else {
                print("Favorite count updated successfully")
            }
        }
    }
    
}
