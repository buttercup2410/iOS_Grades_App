//
//  LoginViewController.swift
//  Assignment08
//
//  Created by Mohamed Shehab on 3/13/24.
//

import UIKit
import Firebase
import PKHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var currentUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func loginClicked(_ sender: Any) {
        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        
        if email.isEmpty || password.isEmpty {
            showAlertWith(title: "Login Error", message: "Email and password are required!", okAlertAction: nil)
        } else {
            HUD.show(.labeledProgress(title: "Login", subtitle: "Please wait!!"))
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                HUD.hide()
                if let error = error {
                    self?.showAlertWith(title: "Login Error", message: error.localizedDescription, okAlertAction: nil)
                } else {
                    if let currentUser = Auth.auth().currentUser {
                        self?.currentUserName = currentUser.displayName
                    }
                    SceneDelegate.showGrades()
                }
            }
            
        }
        

    }
}


extension UIViewController {
    
    func showAlertWith(title: String, message: String, okAlertAction: ((UIAlertAction) -> Void)?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: okAlertAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
 
    func showAlertWith(title: String, message: String, okAlertAction: ((UIAlertAction) -> Void)?, cancelAlertAction: ((UIAlertAction) -> Void)?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: okAlertAction)
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: cancelAlertAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWith(title: String, message: String, deleteAlertAction: ((UIAlertAction) -> Void)?, cancelAlertAction: ((UIAlertAction) -> Void)?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: deleteAlertAction)
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: cancelAlertAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
