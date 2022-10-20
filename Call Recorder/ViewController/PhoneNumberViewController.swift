//
//  PhoneNumberViewController.swift
//  Call Recorder
//
//  Created by Руслан on 21.09.2022.
//

import UIKit
import Alamofire
import SwiftyJSON

class PhoneNumberViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var textName: UITextField!
    var number = ""
    let ns = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        ns.delegate = self
        textName.inputView = UIView(frame: CGRect.zero)
    }
    
    
    
    func notificationSender(number:String){
        let content = UNMutableNotificationContent()
        content.title = "Позвонить на номер"
        content.body = "Нажмите для звонка на номер \(textName.text!)"
        content.sound = .default
        UserDefaults.standard.set(textName.text!, forKey: "GlavnNumber")
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "identefire", content: content, trigger: trigger)
        ns.add(request){ err in
            if err != nil {
                print(err?.localizedDescription)
            }
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let nu = UserDefaults.standard.string(forKey:"GlavnNumber")!
        callNumber(phoneNumber: nu)
        dismiss(animated: true)
        completionHandler()
        
    }


    
    private func callNumber(phoneNumber: String) {
        print(phoneNumber)
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:])
        
                
    }
    
    
    @IBAction func num(_ sender: UIButton) {
        if sender.tag == 10 {
            if number != ""{
                number.remove(at: number.index(before: number.endIndex))
                textName.text = number
            }

        }else if sender.tag == 11{
            var phone1 = ""
            print(UserDefaults.standard.string(forKey: "settingsPhone"))
            if UserDefaults.standard.string(forKey: "settingsPhone") == nil{
                phone1 = UserDefaults.standard.string(forKey: "servicePhone")!
            }else {
                phone1 = UserDefaults.standard.string(forKey: "settingsPhone")!
                phone1.remove(at: phone1.startIndex)
            }
            
            var phone = "+\(textName.text!)"
            
            if UserDefaults.standard.bool(forKey: "current") == true{
                let token = UserDefaults.standard.string(forKey: "token")!
                let log_id = UserDefaults.standard.string(forKey: "log_id")!
                let phoneNum = UserDefaults.standard.string(forKey: "phoneNumber")!
            let url = "https://recmycallssingapore.com/v1/get_code_new/?token=\(token)&log_id=\(log_id)&service_phone=\(phoneNum)&comment=\(phone)"
                print(url)
            AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON(emptyResponseCodes: [200, 204, 205]) { response in
                switch response.result{
                    case .success(let value):
                        let json = JSON(value)
                    if json.isEmpty == false{
                        print(json)
                        let code = json["code"].stringValue
                        UserDefaults.standard.set(code, forKey: "code")
                    }
                    case .failure(let err):
                    print("\(err.localizedDescription)")
                }
            }
            }
            
            let code = UserDefaults.standard.string(forKey: "code")
            callNumber(phoneNumber: "+\(phone1),\(code!)")
            
            if textName.text?.first == "8" || textName.text?.first == "7"{
                let ph = textName.text!
                phone = "+7\(ph.dropFirst())"
                
            }
            callNumber(phoneNumber: "\(phone)")
            notificationSender(number: textName.text!)
            UserDefaults.standard.set(true, forKey: "not")
            dismiss(animated: true)
        }else{
            number += "\(sender.tag)"
            textName.text = number
        }
    }
    
    

}
