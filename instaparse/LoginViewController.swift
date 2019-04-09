//
//  LoginViewController.swift
//  instaparse
//
//  Created by Oliver Thurn on 4/2/19.
//  Copyright © 2019 Oliver Thurn. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextfeild: UITextField!
    
    @IBOutlet weak var passwordTextfeild: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        let username = usernameTextfeild.text!
        let password = passwordTextfeild.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "afterLogin", sender: nil)
            } else {
                print("Error \(error?.localizedDescription)")
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        let user = PFUser()
        user.username = usernameTextfeild.text
        user.password = passwordTextfeild.text
        
        user.signUpInBackground { (success, error) in
            if success {
                self.performSegue(withIdentifier: "afterLogin", sender: nil )
            } else {
                print("Error  \(error?.localizedDescription)")
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
