//
//  SelectSemesterViewController.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import UIKit

class SelectSemesterViewController: UIViewController {

    var semesters = [Semester]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SelectTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectTableViewCell")
        
        for i in 2020...2024 {
            self.semesters.append(Semester(year: i, month: 1))
            self.semesters.append(Semester(year: i, month: 8))
        }
        self.semesters.reverse()
        self.tableView.reloadData()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension SelectSemesterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.semesters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTableViewCell", for: indexPath) as! SelectTableViewCell
        let semster = self.semesters[indexPath.row]
        cell.itemLabel.text = semster.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let semester = self.semesters[indexPath.row]
        NotificationCenter.default.post(name: Notification.Name("NotifySelectedSemester"), object: semester)
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true)
    }
}
