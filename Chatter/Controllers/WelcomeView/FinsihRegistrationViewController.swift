//
//  FinsihRegistrationViewController.swift
//  Chatter
//
//  Created by Avihai Shabtai on 22/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class FinsihRegistrationViewController: UIViewController , ImagePickerDelegate{
   
    
    @IBOutlet weak var nameTextField: UITextField!
        @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var CountryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.isUserInteractionEnabled = true
    }
    
    
  //MARK: IBAction
    
    @IBAction func avatarImageTap(_ sender: Any) {
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        
        present(imagePickerController, animated: true, completion: nil)
        
        dissmisKeyboard()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dissmisKeyboard()
        ProgressHUD.show("Registreing...")
        
        if nameTextField.text != "" && surnameTextField.text != "" && CountryTextField.text != "" && cityTextField.text != "" && phoneTextField.text != "" {
            FUser.registerUserWith(email: email, password: password, firstName: nameTextField.text!, lastName: surnameTextField.text!) { (error) in
                
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                self.registerUser()
            }
            
        }else {
            ProgressHUD.showError("All fields are required!")
        }
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cleanTextFields()
        dissmisKeyboard()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func backroundTap(_ sender: Any) {
        dissmisKeyboard()
    }
    
    //MARK:Helpers
    
    func registerUser() {
        
        let fullName = nameTextField.text! + " " + surnameTextField.text!
        
        var tempDictionary : Dictionary = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kFULLNAME : fullName, kCOUNTRY : CountryTextField.text!, kCITY : cityTextField.text!, kPHONE : phoneTextField.text!] as [String : Any]
        
        
        if avatarImage == nil {
            
            imageFromInitials(firstName: nameTextField.text!, lastName: surnameTextField.text!) { (avatarInitials) in
                
                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDictionary[kAVATAR] = avatar
                
                self.finishRegestration(withValues: tempDictionary)
            }
            
            
            
        } else {
            
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.5)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempDictionary[kAVATAR] = avatar
            
            self.finishRegestration(withValues: tempDictionary)
        }

    }
    func finishRegestration(withValues: [String:Any])
    {
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
                return
            }
            ProgressHUD.dismiss()
            
            self.goToApp()
        }
    }
    func goToApp(){
        
        cleanTextFields()
        dissmisKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])

        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplictaion") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
    
    func dissmisKeyboard(){
        self.view.endEditing(false)
    }
    func cleanTextFields()
    {
        nameTextField.text = ""
        surnameTextField.text = ""
        CountryTextField.text = ""
        cityTextField.text = ""
        phoneTextField.text = ""
    }

            //MARK: ImagePickerDelegate
      
      func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
          self.dismiss(animated: true, completion: nil)
      }
      
      func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
          
          if images.count > 0 {
              self.avatarImage = images.first!
              self.avatarImageView.image = self.avatarImage?.circleMasked
          }
          
          self.dismiss(animated: true, completion: nil)
      }
      
      func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
          self.dismiss(animated: true, completion: nil)
      }
}
