//
//  PhoneNumberViewController.swift
//  Call Recorder
//
//  Created by Руслан on 21.09.2022.
//

import UIKit

class PhoneNumberViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var textName: UITextField!
    var number = ""
    let ns = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        ns.delegate = self
    }
    
    func notificationSender(number:String){
        let content = UNMutableNotificationContent()
        content.title = "Позвонить на номер"
        content.body = "Нажмите для звонка на номер \(textName.text!)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "identefire", content: content, trigger: trigger)
        ns.add(request){ err in
            if err != nil {
                print(err?.localizedDescription)
            }
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        callNumber(phoneNumber: textName.text!)
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
            let phone1 = UserDefaults.standard.string(forKey: "servicePhone")
            let code = UserDefaults.standard.string(forKey: "code")
            callNumber(phoneNumber: "+\(phone1!),\(code!)")
            var phone = "+\(textName.text!)"
            if textName.text?.first == "8" || textName.text?.first == "7"{
                let ph = textName.text!
                phone = "+7\(ph.dropFirst())"
                
            }
            callNumber(phoneNumber: "\(phone)")
            notificationSender(number: textName.text!)
            
        }else{
            number += "\(sender.tag)"
            textName.text = number
        }
    }
    

}
