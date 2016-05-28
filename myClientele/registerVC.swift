//
//  registerVC.swift
//  myClientele
//
//  Created by Bryan Okafor on 5/10/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit

class registerVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
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

    @IBAction func uploadPhotoButtonPressed(sender: AnyObject) {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) -> Void in
            camera.PresentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert : UIAlertAction!) -> Void in
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (aler : UIAlertAction!) -> Void in
            print("Cancelled")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.avatarImage = (info[UIImagePickerControllerEditedImage] as! UIImage)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: Backendless user registration
    func register(email: String, username: String, password: String, avatarImage: UIImage?) {
        
        if avatarImage == nil {
            newUser!.setProperty("Avatar", object: "")
        } else {
            
            uploadAvatar(avatarImage!, result: { (imageLink) -> Void in
                let properties = ["Avatar" : imageLink!]
                
                backendless.userService.currentUser!.updateProperties(properties)
                
                backendless.userService.update(backendless.userService.currentUser, response: { (updatedUser: BackendlessUser!) -> Void in
                    print("Updated current user avatar")
                    }, error: { (fault : Fault!) -> Void in
                        print("Error could not set avatar image \(fault)")
                })
            })
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
