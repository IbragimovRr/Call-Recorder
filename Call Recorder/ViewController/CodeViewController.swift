//
//  CodeViewController.swift
//  Call Recorder
//
//  Created by Руслан on 20.09.2022.
//

import UIKit
import FirebaseAuth

class CodeViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var txtSix: UITextField!
    @IBOutlet weak var txtFive: UITextField!
    @IBOutlet weak var txtFour: UITextField!
    @IBOutlet weak var txtThird: UITextField!
    @IBOutlet weak var txtSecond: UITextField!
    @IBOutlet weak var txtFirst: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFirst.delegate = self
        txtSecond.delegate = self
        txtThird.delegate = self
        txtFive.delegate = self
        txtFour.delegate = self
        txtSix.delegate = self
        overrideUserInterfaceStyle = .light
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if !(string == "") {
                textField.text = string
                if textField == txtFirst {
                    txtSecond.becomeFirstResponder()
                }
                else if textField == txtSecond {
                    txtThird.becomeFirstResponder()
                }
                else if textField == txtThird {
                    txtFour.becomeFirstResponder()
                }else if textField == txtFour {
                    txtFive.becomeFirstResponder()
                }else if textField == txtFive {
                    txtSix.becomeFirstResponder()
                }
                else {
                    textField.resignFirstResponder()
                    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")!
                    let verificationCode = txtFirst.text! + txtSecond.text! + txtThird.text! + txtFour.text! + txtFive.text! + txtSix.text!
                    
                    let credential = PhoneAuthProvider.provider().credential(
                      withVerificationID: verificationID,
                      verificationCode: verificationCode
                    )
                    auth(credentional: credential)
                    
                }
                return false
            }
            return true
        }

        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            if (textField.text?.count ?? 0) > 0 {

            }
            return true
        }
    

    func auth(credentional:AuthCredential){
        Auth.auth().signIn(with: credentional) { result,error in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
                self.performSegue(withIdentifier: "finish", sender: self)
                
            }
        }
    }

}
