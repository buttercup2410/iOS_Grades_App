//
//  Semester.swift
//  GradesApp
//
//  Created by Mohamed Shehab on 3/25/24.
//

import Foundation
class Semester {
    var name: String?
    var year: Int?
    var month: Int?
    
    init(year: Int, month: Int) {
        self.year = year
        self.month = month
        if month == 1 {
            self.name = "Spring \(year)"
        } else {
            self.name = "Fall \(year)"
        }
    }
}
