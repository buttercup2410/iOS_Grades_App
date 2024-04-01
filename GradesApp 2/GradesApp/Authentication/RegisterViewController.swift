//
//  RegisterViewController.swift
//  Assignment08
//
//  Created by Mohamed Shehab on 3/13/24.
//

import UIKit
import Firebase
import PKHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var currentUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        let name = fullnameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if name.isEmpty || email.isEmpty || password.isEmpty {
            self.showAlertWith(title: "Register Error", message: "Enter name, email and password!", okAlertAction: nil)
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                if let error = error {
                    HUD.hide()
                    self?.showAlertWith(title: "Register Error", message: error.localizedDescription, okAlertAction: nil)
                } else {
                    // Update user's display name
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = name
                    changeRequest?.commitChanges { [weak self] error in
                        HUD.hide()
                        if let error = error {
                            self?.showAlertWith(title: "Register Error", message: error.localizedDescription, okAlertAction: nil)
                        } else {
                            self?.currentUserName = name // Store current user's name
                            SceneDelegate.showGrades()
                        }
                    }
                }
            }
        }
        
        
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
