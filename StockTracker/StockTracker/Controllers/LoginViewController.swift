//
//  LoginViewController.swift
//  StockTracker
//
//  Created by Chenning Li on 12/9/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import UIKit
import Parse
import SwiftUI
import TKSubmitTransition

class LoginViewController: UIViewController {
    
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    
    var btn_login: TKTransitionSubmitButton!
    var btn_signup: TKTransitionSubmitButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let user_icon = UIImageView(image: UIImage(named: "username-icon"))
        user_icon.frame = CGRect(x: 70, y: self.view.frame.size.height-130, width: 30, height: 30)
        user_icon.contentMode = .scaleAspectFill;
        self.view.addSubview(user_icon)
        
        let password_icon = UIImageView(image: UIImage(named: "password-icon"))
        password_icon.frame = CGRect(x: 70, y: self.view.frame.size.height-90, width: 30, height: 30)
        password_icon.contentMode = .scaleAspectFill;
        self.view.addSubview(password_icon)
        
        
        let userTextField =  UITextField(frame: CGRect(x: 105, y: self.view.frame.size.height-130, width: self.view.frame.size.width - 170, height: 30))
        let passwordTextField =  UITextField(frame: CGRect(x: 105, y: self.view.frame.size.height-90, width: self.view.frame.size.width-170, height: 30))
        
        userTextField.placeholder = "Enter your username"
        userTextField.font = UIFont.systemFont(ofSize: 15)
        userTextField.borderStyle = UITextField.BorderStyle.roundedRect
        userTextField.autocorrectionType = UITextAutocorrectionType.no
        userTextField.autocapitalizationType = .none
        userTextField.keyboardType = UIKeyboardType.default
        userTextField.returnKeyType = UIReturnKeyType.done
        userTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        userTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.UsernameField = userTextField
        self.view.addSubview(userTextField)
        
        passwordTextField.placeholder = "Enter your password"
        passwordTextField.font = UIFont.systemFont(ofSize: 15)
        passwordTextField.borderStyle = UITextField.BorderStyle.roundedRect
        passwordTextField.autocorrectionType = UITextAutocorrectionType.no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.keyboardType = UIKeyboardType.default
        passwordTextField.returnKeyType = UIReturnKeyType.done
        passwordTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        passwordTextField.isSecureTextEntry = true
        passwordTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.PasswordField = passwordTextField
        self.view.addSubview(passwordTextField)
        
        
        let bg = UIImageView(image: UIImage(named: "cover"))
        bg.frame = CGRect(x: 0, y: 32, width: self.view.frame.size.width, height: self.view.frame.size.height-200)
        bg.contentMode = .scaleAspectFill;
        self.view.addSubview(bg)
        self.view.sendSubviewToBack(bg)
        
        btn_login = TKTransitionSubmitButton(frame: CGRect(x: 32, y: self.view.frame.size.height-40, width: self.view.frame.size.width/2 - 64, height: 30))
        btn_signup = TKTransitionSubmitButton(frame: CGRect(x: self.view.frame.size.width/2+32, y: self.view.frame.size.height-40, width: self.view.frame.size.width/2 - 64, height: 30))
        btn_login.backgroundColor = .red
        btn_signup.backgroundColor = .red
        
        btn_login.setTitle("Log in", for: UIControl.State())
        btn_signup.setTitle("Sign up", for: UIControl.State())
        var titleFont=UIFont(name: "HelveticaNeue-Light", size: 14)
        titleFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_login.titleLabel?.font=titleFont
        btn_signup.titleLabel?.font=titleFont
        
        btn_login.addTarget(self, action: #selector(LoginViewController.OnLoginIn(_:)), for: UIControl.Event.touchUpInside)
        btn_signup.addTarget(self, action: #selector(LoginViewController.OnSignUp(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(btn_login)
        self.view.addSubview(btn_signup)
        
    }
    
    @IBAction func OnLoginIn(_ button: TKTransitionSubmitButton) {
        button.animate(0.5, completion: { () -> () in
            if self.usernameAndPasswordNotEmpty() {
                let username = self.UsernameField.text ?? ""
                let password = self.PasswordField.text ?? ""
                
                PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
                    if let error = error {
                        print("User log in failed: \(error.localizedDescription)")
                        self.displayLoginError(error: error)
                    } else {
                        print("User \(username) logged in successfully")
                        // display view controller that needs to shown after successful login
                        NotificationCenter.default.post(name: NSNotification.Name("login"), object: nil)
                        
                        
                    }
                }
            }
            
            
        })
        
    }
    
    @IBAction func OnSignUp(_ button: TKTransitionSubmitButton) {
        button.animate(0.5, completion: { () -> () in
            
            if self.usernameAndPasswordNotEmpty() {
                // initialize a user object
                let newUser = PFUser()
                
                // set user properties
                newUser.username = self.UsernameField.text
                newUser.password = self.PasswordField.text
                
                // call sign up function on the object
                newUser.signUpInBackground { (success: Bool, error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                        self.displaySignupError(error: error)
                    } else {
                        print("User \(newUser.username!) Registered successfully")
                        NotificationCenter.default.post(name: NSNotification.Name("login"), object: nil)
                        
                    }
                }
            }
            
        }
        )}
    
    func usernameAndPasswordNotEmpty() -> Bool {
        // Check text field inputs
        if UsernameField.text!.isEmpty || PasswordField.text!.isEmpty {
            displayError()
            return false
        } else {
            return true
        }
    }
    
    func displayError() {
        let title = "Error"
        let message = "Username and password field cannot be empty"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default)
        // add the OK action to the alert controller
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    // Login error alert controller
    func displayLoginError(error: Error) {
        let title = "Login Error"
        let message = "Oops! Something went wrong while logging in: \(error.localizedDescription)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default)
        // add the OK action to the alert controller
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    
    // Sign up error alert controller
    func displaySignupError(error: Error) {
        let title = "Sign up error"
        let message = "Oops! Something went wrong while signing up: \(error.localizedDescription)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default)
        // add the OK action to the alert controller
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
//    // MARK: UIViewControllerTransitioningDelegate
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return TKFadeInAnimator(transitionDuration: 0.5, startingAlpha: 0.8)
//    }
//
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return nil
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

