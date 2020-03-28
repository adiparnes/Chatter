//
//  WelcomeViewController.swift
//  Chatter
//
//  Created by Avihai Shabtai on 22/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit
import ProgressHUD
class WelcomeViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  
  //MARK: IBAction
    
    @IBAction func loginButtonPressed(_ sender: Any) {
       dissmisKeyboard()
        if emailTextField.text != "" && (passwordTextField!.text != nil) {
            
            loginUser()
        
        }else{
            ProgressHUD.showError("Email and Password is missing!")
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        dissmisKeyboard()
        if isValid() {
            if passwordTextField.text == confirmPasswordTextField.text{
            registerUser()
            }else{
                ProgressHUD.showError("Password don't match")
                }
         }else{
            if !emailTextField.text!.isValidEmail(){
                ProgressHUD.showError("Email address is badly formatted")
            }else if passwordTextField!.text!.count < 6 {
                ProgressHUD.showError("The password must be 6 characters long or more.")
            }else{
                ProgressHUD.showError("All fields are required!")
            }
         }
    }
    
    
    func isValid() -> Bool{
        return emailTextField.text!.isValidEmail() && passwordTextField!.text!.count >= 6 && confirmPasswordTextField.text == passwordTextField?.text
    }
    
    @IBAction func backroundTap(_ sender: Any) {
        dissmisKeyboard()
    }
    
   //MARK: HelperFunctions
    
    func loginUser()
    {
        ProgressHUD.show("Login...")
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            self.goToApp()
        }
        
    }
    
    func registerUser()
    {
        performSegue(withIdentifier: "welcomeToFinishReg", sender: self)
        cleanTextFields()
        dissmisKeyboard()
        
        
    }
    
    func dissmisKeyboard(){
        self.view.endEditing(false)
    }
    func cleanTextFields()
    {
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
    }
    
    //MARK: GoTOApp
    func goToApp()
    {
        ProgressHUD.dismiss()
        
        cleanTextFields()
        dissmisKeyboard()
       
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])

        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplictaion") as! UITabBarController
               self.present(mainView, animated: true, completion: nil)
           }
    
    
    //MARK:Navigtion
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcomeToFinishReg" {
            let vc = segue.destination as! FinsihRegistrationViewController
            vc.email = emailTextField.text!
            vc.password = passwordTextField.text!
        }
    }
    
}

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegex = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    mutating func index(character:Character) -> Int?{
        var temp = self
        for i in 0...self.count - 1{
            if temp.first == character{
                return i
            }
            temp.remove(at: temp.startIndex)
        }
        return nil
    }
}
