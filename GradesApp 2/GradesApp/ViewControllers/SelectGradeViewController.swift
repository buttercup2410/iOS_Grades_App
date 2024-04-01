//
//  SelectGradeViewController.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import UIKit

class SelectGradeViewController: UIViewController {
    var grades = [LetterGrade]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SelectTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectTableViewCell")

        grades.append(LetterGrade(letter: "A", number: 4.0))
        grades.append(LetterGrade(letter: "B", number: 3.0))
        grades.append(LetterGrade(letter: "C", number: 2.0))
        grades.append(LetterGrade(letter: "D", number: 1.0))
        grades.append(LetterGrade(letter: "F", number: 0.0))
        
        self.tableView.reloadData()
    }
  
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
}


extension SelectGradeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.grades.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTableViewCell", for: indexPath) as! SelectTableViewCell
        let grade = self.grades[indexPath.row]
        cell.itemLabel.text = grade.letter!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grade = self.grades[indexPath.row]
        NotificationCenter.default.post(name: Notification.Name("NotifySelectedGrade"), object: grade)
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true)
    }
}
