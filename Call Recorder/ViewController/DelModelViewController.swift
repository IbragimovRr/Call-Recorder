//
//  DelModelViewController.swift
//  Call Recorder
//
//  Created by Руслан on 07.10.2022.
//

import UIKit
import Alamofire
import SwiftyJSON

class DelModelViewController: UIViewController {

    //Localized
    @IBOutlet weak var l1: UILabel!
    @IBOutlet weak var l3: UIButton!
    @IBOutlet weak var l2: UIButton!
    //Localized
    
    var delegate:DeleteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localized()
    }
    
    func localized() {
        l1.text = NSLocalizedString("txtPopupDel", comment: "")
        l2.setTitle(NSLocalizedString("yes", comment: ""), for: .normal)
        l3.setTitle(NSLocalizedString("not", comment: ""), for: .normal)
    }
    
    @IBAction func yes(_ sender: UIButton) {
        if UserDefaults.standard.string(forKey: "phoneNumber") != "+17777777"{
        if UserDefaults.standard.bool(forKey: "current") == true{
            let url = "https://recmycallssingapore.com/v1/purge"
            let tok = UserDefaults.standard.string(forKey: "token")
            let param = [
                "token":tok!
            ]
            print(param)
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON{ response in
                switch response.result{
                    case .success(let value):
                        let json = JSON(value)
                        print(json)
                        UserDefaults.standard.set(false, forKey: "current")
                        self.delegate?.delete(bool: true)
                        self.dismiss(animated: true)
                    case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
        }
    }
    
    
    @IBAction func not(_ sender: UIButton) {
        delegate?.delete(bool: false)
        dismiss(animated: false)
    }
    

}
