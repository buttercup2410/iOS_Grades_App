//
//  SelectCourseViewController.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON

class SelectCourseViewController: UIViewController {
    var courses = [Course]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "CoursesTableViewCell", bundle: nil), forCellReuseIdentifier: "CoursesTableViewCell")
        getCourses()
    }
    
    func getCourses() {
        courses.removeAll()
        HUD.show(.labeledProgress(title: "Loading Courses", subtitle: "Please Wait!"))
        AF.request("https://www.theappsdr.com/api/cci-courses").validate(statusCode: 200..<300).responseData { [weak self] response in
        HUD.hide()
        switch response.result {
            case .success:
                if let data = response.data {
                    if let json = try? JSON(data: data) {
                        let coursesArray = json["courses"].arrayValue
                        for item in coursesArray {
                            self?.courses.append(Course(item))
                        }
                        self?.tableView.reloadData()
                    } else {
                        self?.showAlertWith(title: "Course Error", message: "Unable to load courses", okAlertAction: nil)
                    }
                } else {
                    self?.showAlertWith(title: "Course Error", message: "Unable to load courses", okAlertAction: nil)
                }
                        
            case let .failure(error):
                print(error)
                self?.showAlertWith(title: "Course Error", message: "Unable to load courses", okAlertAction: nil)
            }
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
}


extension SelectCourseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoursesTableViewCell", for: indexPath) as! CoursesTableViewCell
        let course = self.courses[indexPath.row]
            
        cell.courseNameLabel.text = course.name ?? "Name Not Available"
        if let hours = course.hours {
            cell.courseHoursLabel.text = "\(hours) Credit Hours"
        } else {
            cell.courseHoursLabel.text = "Credit Hours Not Available"
        }
        cell.courseNumberLabel.text = course.number ?? "Number Not Available"
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = self.courses[indexPath.row]
        NotificationCenter.default.post(name: Notification.Name("NotifySelectedCourse"), object: course)
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true)
    }
}
