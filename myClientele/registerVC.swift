//
//  registerVC.swift
//  myClientele
//
//  Created by Bryan Okafor on 5/10/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit

class registerVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var backendless = Backendless.sharedInstance()
    
    var newUser: BackendlessUser?
    var email: String?
    var username: String?
    var password: String?
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newUser = BackendlessUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    @IBAction func registerButtonClicked(sender: AnyObject) {
        
        if emailTextField.text != "" && usernameTextField.text != "" && passwordTextField.text != "" {
            
            // Notifying user that it is registering
            ProgressHUD.show("Registering...")
            
            email = emailTextField.text
            username = usernameTextField.text
            password = passwordTextField.text
            
            register(self.email!, username: self.username!, password: self.password!, avatarImage: self.avatarImage)
        } else {
            //warning to the user
            ProgressHUD.showError("All fields are required")
            
        }
    }


    //MARK: Backendless user registration
    func register(email: String, username: String, password: String, avatarImage: UIImage?) {
        
        if avatarImage == nil {
            newUser!.setProperty("Avatar", object: "")
        }
        
        newUser!.email = email
        newUser!.name = username
        newUser!.password = password
        
        backendless.userService.registering(newUser, response: { (registeredUser : BackendlessUser!) -> Void in
            
            ProgressHUD.dismiss()
            
            //login new user
            self.loginUser(email, username: username, password: password)
            
            self.usernameTextField.text = ""
            self.passwordTextField.text = ""
            self.emailTextField.text = ""
            
        }) { (fault : Fault!) -> Void in
            print("Server reported an error, could not register new user: \(fault)")
        }
        
    }
    
    func loginUser(email: String, username:String, password: String) {
        
        backendless.userService.login(email, password: password, response: { (user : BackendlessUser!) -> Void in
            
            //here segue to recents vc
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
            
        }) { (fault : Fault!) -> Void in
            print("Server reported an error: \(fault)")
        }
        
    }
}
