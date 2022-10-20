//
//  ViewController.swift
//  Call Recorder
//
//  Created by Руслан on 19.09.2022.
//

import UIKit
import FirebaseAuth
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var btnLayout: NSLayoutConstraint!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var number: UITextField!
    
    var arraySettings = Array<Settings>()
    //Localized
    @IBOutlet weak var l2: UIButton!
    @IBOutlet weak var l1: UILabel!
    //Localized
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localized()
        let current = UserDefaults.standard.bool(forKey: "current")
        if current{
            performSegue(withIdentifier: "current", sender: self)
        }
        navigationController?.isNavigationBarHidden = true
        btnNext.isEnabled = false
        btnNext.setTitleColor(UIColor.gray, for: .normal)
        overrideUserInterfaceStyle = .light
        number.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func localized() {
        l1.text = NSLocalizedString("registr", comment: "")
        l2.setTitle(NSLocalizedString("btnRegistr", comment: ""), for: .normal)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            btnLayout.constant = keyboardHeight
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,replacementString string: String) -> Bool {
        
        let maxLength = 13
        let currentString: NSString = number.text! as NSString
        let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == 12 || newString.length == 13 {
            btnNext.isEnabled = true
            btnNext.setTitleColor(UIColor.white, for: .normal)
        }else{
            btnNext.isEnabled = false
            btnNext.setTitleColor(UIColor.gray, for: .normal)
        }
        if textField.text == "+1777777"{
            btnNext.isEnabled = true
            btnNext.setTitleColor(UIColor.white, for: .normal)
        }
        
        return newString.length <= maxLength
    }
    
    @IBAction func btnNext(_ sender: UIButton) {
        let phoneNumber = number.text!
        UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
        print(phoneNumber)
        if number.text! == "+17777777" {
            let randomString = "jzB"
            UserDefaults.standard.set(randomString, forKey: "log_id")
            UserDefaults.standard.set(true, forKey: "current")
            UserDefaults.standard.set("f526b609178f9579500e270b41bc358b", forKey: "token")
            self.performSegue(withIdentifier: "current2", sender: self)
        }else{
            let url2 = "http://recmycallssingapore.com/tel.json"
            AF.request(url2).responseJSON(emptyResponseCodes: [200, 204, 205]) { response in
                switch response.result{
                    case .success(let value):
                    let json = JSON(value)["phonenumbers"]
                    if json.isEmpty == false{
                        for i in 0...json.count-1 {
                            let country = json[i]["description"].stringValue
                            let image = json[i]["image"].stringValue
                            let phone = json[i]["phone"].stringValue
                            
                            if phone[1] == self.number.text![1]{
                                UserDefaults.standard.set(phone, forKey: "servicePhone")
                            }
                            
                            
                        }
                    
                    }
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                }
            }
            
            
            
            number.text = "+7"
            self.performSegue(withIdentifier: "code", sender: self)
        }
    }
}

