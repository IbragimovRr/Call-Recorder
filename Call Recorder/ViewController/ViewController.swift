//
//  ViewController.swift
//  Call Recorder
//
//  Created by Руслан on 19.09.2022.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnLayout: NSLayoutConstraint!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var number: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        btnNext.isEnabled = false
        btnNext.setTitleColor(UIColor.gray, for: .normal)
        overrideUserInterfaceStyle = .light
        number.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            btnLayout.constant = keyboardHeight
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,replacementString string: String) -> Bool {
        
        let maxLength = 12
        let currentString: NSString = number.text! as NSString
        let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == 12 || newString.length == 13 {
            btnNext.isEnabled = true
            btnNext.setTitleColor(UIColor.white, for: .normal)
        }else{
            btnNext.isEnabled = false
            btnNext.setTitleColor(UIColor.gray, for: .normal)
        }
        return newString.length <= maxLength
    }
    
    @IBAction func btnNext(_ sender: UIButton) {
        let phoneNumber = number.text!
        PhoneAuthProvider.provider()
          .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
              if let error = error {
                  print(error.localizedDescription)
                return
              }
              UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
              UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
              self.performSegue(withIdentifier: "code", sender: self)
          }
    }
    
}

