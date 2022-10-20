//
//  CodeViewController.swift
//  Call Recorder
//
//  Created by Руслан on 20.09.2022.
//

import UIKit
import FirebaseAuth
import Alamofire
import Lottie
import SwiftyJSON

class CodeViewController: UIViewController,UITextFieldDelegate {
    
    //Localized
    @IBOutlet weak var l3: UILabel!
    @IBOutlet weak var l2: UIButton!
    @IBOutlet weak var l1: UILabel!
    //Localized
    
    @IBOutlet weak var otpCode: UIButton!
    @IBOutlet weak var hid: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var loading: AnimationView!
    @IBOutlet weak var txtSix: UITextField!
    @IBOutlet weak var txtFive: UITextField!
    @IBOutlet weak var txtFour: UITextField!
    @IBOutlet weak var txtThird: UITextField!
    @IBOutlet weak var txtSecond: UITextField!
    @IBOutlet weak var txtFirst: UITextField!
    var tim = 60
    var timer = Timer()
    let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { verificationID, error in
                
                if error != nil{
                    print("\(error?.localizedDescription)-------------------")
                    self.navigationController?.popToRootViewController(animated: true)
                }else{
                    self.txtFirst.becomeFirstResponder()
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                }
          }
        txtFirst.delegate = self
        txtSecond.delegate = self
        txtThird.delegate = self
        txtFive.delegate = self
        txtFour.delegate = self
        txtSix.delegate = self
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        loading.loopMode = .loop
        loading.contentMode = .scaleAspectFill
        loading.play()
        localized()
    }
    
    func localized() {
        l1.text = NSLocalizedString("code", comment: "")
        l2.setTitle(NSLocalizedString("otprCode", comment: ""), for: .normal)
        l3.text = NSLocalizedString("code2", comment: "")
    }
    
    @IBAction func otprCode(_ sender: UIButton) {
        tim = 60
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeCode), userInfo: nil, repeats: true)
        sender.isHidden = true
        time.isHidden = false
        loading.isHidden = false
        hid.isHidden = false
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { verificationID, error in
              if let error = error {
                  print(error.localizedDescription)
                  self.loading.play()
                return
              }
              UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.loading.play()
          }
    }
    
    @objc func timeCode(){
        if tim == 1{
            timer.invalidate()
            time.isHidden = true
            loading.isHidden = true
            hid.isHidden = true
            otpCode.isHidden = false
            loading.stop()
        }
        tim -= 1
        time.text = "00:\(tim)"
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
                let length = 3
                let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                let randomCharacters = (0..<length).map{_ in characters.randomElement()!}
                let randomString = String(randomCharacters)
                UserDefaults.standard.set(randomString, forKey: "log_id")
                UserDefaults.standard.set(true, forKey: "current")
                self.call2(log_id: randomString)
                print(randomString)
                
            }
        }
    }

    func call2(log_id:String){
        let phone = UserDefaults.standard.string(forKey: "phoneNumber")!
        let url = "https://recmycallssingapore.com/v1/register"
        let param = [
            "log_id":log_id,
            "telephone":phone,
            "comment":"comment"
        ]
        print(param)
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON{ response in
            switch response.result{
                case .success(let value):
                    print("value", value)
                    let json = JSON(value)
                    let token = json["token"].stringValue
                    UserDefaults.standard.set(token, forKey: "token")
                    print(token)
                    self.performSegue(withIdentifier: "finish", sender: self)
                case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
}
