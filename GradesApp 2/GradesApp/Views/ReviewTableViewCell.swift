//
//  ReviewTableViewCell.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import UIKit
import Firebase
import FirebaseAuth

protocol ReviewDelegate {
    func deleteClicked(_ review: Review)
}

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var createdByNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var review: Review?
    var course: Course?
    var reviewDelegate: ReviewDelegate?
    
    func bind(review: Review, reviewDelegate: ReviewDelegate, currentUserName: String?) {
        self.review = review
        self.reviewDelegate = reviewDelegate

        reviewLabel.text = review.text

        if let userName = currentUserName {
            createdByNameLabel.text = "Created by: \(userName)"
        } else {
            createdByNameLabel.text = "Created by: Unknown"
        }

        if let createdAt = review.createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            createdAtLabel.text = dateFormatter.string(from: createdAt.dateValue())
        } else {
            createdAtLabel.text = "Created at: N/A"
        }
    }
    
    func fetchUserName(userID: String, completion: @escaping (String?) -> Void) {
        //    let reviewsRef = Firestore.firestore().collection("courses").document(courseID!)?.collection("reviews").whereField("userID", isEqualTo: userID)

        let usersRef = Firestore.firestore().collection("courses").document(userID)
            usersRef.getDocument { (document, error) in
                if let error = error {
                    print("Error fetching user document:", error.localizedDescription)
                    completion(nil)
                    return
                }
                
                guard let document = document, document.exists else {
                    print("User document does not exist or is empty")
                    completion(nil)
                    return
                }
                
                if let data = document.data(), let userName = data["name"] as? String {
                    completion(userName)
                } else {
                    print("User document does not contain 'name' field or 'name' field is not a string")
                    completion(nil)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func deleteClicked(_ sender: Any) {
        guard let review = review else {
            print("No review data available")
            return
        }
        self.reviewDelegate?.deleteClicked(review)
    }
}
