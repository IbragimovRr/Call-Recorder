//
//  MainViewController.swift
//  Call Recorder
//
//  Created by Руслан on 21.09.2022.
//

import UIKit
import Contacts
import ContactsUI
import Alamofire
import SwiftyJSON
import NotificationCenter
import AVFoundation

class MainViewController: UIViewController, CNContactPickerDelegate {

    @IBOutlet weak var playbtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timePlay: UILabel!
    @IBOutlet weak var textGl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let ns = UNUserNotificationCenter.current()
    var displayLink : CADisplayLink! = nil
    var num = ""
    var numberCall = ""
    var player: AVAudioPlayer?
    @IBOutlet weak var hlabel3: UILabel!
    @IBOutlet weak var hlabel2: UILabel!
    @IBOutlet weak var hlabel1: UILabel!
    @IBOutlet weak var hnedavn: UIView!
    @IBOutlet weak var hContakts: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constrantAnim: NSLayoutConstraint!
    var array = Array<Audio>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ns.requestAuthorization(options: [.alert,.sound,.badge]) { success, err in
            if success == true{
                print("t")
            }else{
                print("f")
            }
        }
        addObservers()
        let length = UserDefaults.standard.string(forKey: "length")
        timePlay.text = length
        progressView.progress = 0
        scrollView.setContentOffset(CGPoint(x: 0, y: -48), animated: false)
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        ns.delegate = self
        overrideUserInterfaceStyle = .light
        scrollView.delegate = self
        call()
        add()
    }
    
    
    
    @IBAction func play(_ sender: UIButton) {
        if sender.titleLabel?.text == "play" && progressView.progress == 0{
            
            let audio = UserDefaults.standard.object(forKey: "audio")
            if audio != nil {
                sender.setTitle("stop", for: .normal)
                playSound(data: audio as! Data)
            }
            
        }else if progressView.progress > 0 && sender.titleLabel?.text == "play"{
            playbtn.setTitle("stop", for: .normal)
            player?.play()
        }else if sender.titleLabel?.text == "stop"{
            sender.setTitle("play", for: .normal)
            player?.stop()
        }
    }
    
    @IBAction func cont(_ sender: UIButton) {
        let vc = CNContactPickerViewController()
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let phone = UserDefaults.standard.string(forKey: "servicePhone")
        let code = UserDefaults.standard.string(forKey: "code")
        callNumber(phoneNumber: "+\(phone!),\(code!)")
        notificationSender(number: contact.phoneNumbers[0].value.stringValue)
        //numberCall = contact.phoneNumbers[0].value.stringValue
        numberCall = (contact.phoneNumbers[0].value as! CNPhoneNumber).value(forKey: "digits") as! String
        
        
    }
    
    func notificationSender(number:String){
        let content = UNMutableNotificationContent()
        content.title = "Позвонить на номер"
        content.body = "Нажмите для звонка на номер \(number)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "identefire", content: content, trigger: trigger)
        ns.add(request){ err in
            if err != nil {
                print(err?.localizedDescription)
            }
        }
        
    }
    
    private func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:])
        
                
    }
    
    func add(){
        let url = "https://recmycallssingapore.com/v1/list/?token=31c6b5cf210491ec039490c3a02bd767&limit=100&log_id=e1l"
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON(emptyResponseCodes: [200, 204, 205]) { response in
            switch response.result{
                case .success(let value):
                    let json = JSON(value)["recordings"]
                    if json.isEmpty == false{
                        self.tableView.isHidden = false
                        for i in 0...json.count-1 {
                            let comment = json[i]["comment"].stringValue
                            let datetime = json[i]["datetime"].stringValue
                            let id = json[i]["id"].stringValue
                            let length = json[i]["length"].stringValue
                            let link = json[i]["link"].stringValue
                            let recordingTelephone = json[i]["recording_telephone"].stringValue
                            self.array.append(Audio(comment: comment, datetime: datetime, id: id, length: length, link: link, recordingTelephone: recordingTelephone))
                        }
                        if self.array.isEmpty == true {
                            self.tableView.isHidden = true
                        }
                        self.tableView.reloadData()
                        print(self.array)
                    }else{
                        self.tableView.isHidden = true
                    }
                case .failure(let err):
                    print(err)
            }
        }
    }
    
    func call(){
        let url = "https://recmycallssingapore.com/v1/get_code_new/?token=31c6b5cf210491ec039490c3a02bd767&log_id=e1l&service_phone=+79882912310"
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON(emptyResponseCodes: [200, 204, 205]) { response in
            switch response.result{
                case .success(let value):
                    print("value", value)
                    let json = JSON(value)
                    let p = json["service_phone"].arrayValue
                    let code = json["code"].stringValue
                for x in 0...p.count-1 {
                    let str = "\(p[x])"
                    let first = str.first!
                    let us = UserDefaults.standard.string(forKey: "phoneNumber")
                    let one = us?.first!
                    if first == one{
                        let phone = "\(p[x])"
                        UserDefaults.standard.set(phone, forKey: "servicePhone")
                    }
                }
                    
                    UserDefaults.standard.set(code, forKey: "code")
                case .failure(let err):
                    print(err)
            }
        }
        
        
    }
    
    func call2(){
        let url = "https://recmycallssingapore.com/v1/register"
        let param = [
            "log_id":"e1l",
            "telephone":"+79674034174",
            "comment":"comment"
        ]
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON{ response in
            switch response.result{
                case .success(let value):
                    print("value", value)
                case .failure(let err):
                    print(err)
            }
        }
    }
  
    func playSound(data:Data) {

        do {
            player = try AVAudioPlayer(data: data)
            displayLink = CADisplayLink(target: self, selector: #selector(updateSliderProgress))
            displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
            playbtn.setTitle("stop", for: .normal)
            player?.play()
            player?.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    fileprivate  func addObservers() {
          NotificationCenter.default.addObserver(self,
                                                 selector: #selector(applicationDidBecomeActive),
                                                 name: UIApplication.didBecomeActiveNotification,
                                                 object: nil)
        }

    fileprivate  func removeObservers() {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        }

    @objc fileprivate func applicationDidBecomeActive() {
        array.removeAll()
        add()
    }
    
    
    
}
extension MainViewController:UIScrollViewDelegate,UNUserNotificationCenterDelegate,UITableViewDelegate,UITableViewDataSource, AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true{
            playbtn.setTitle("play", for: .normal)
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "audio", for: indexPath) as! AudioTableViewCell
        let date = Date(timeIntervalSince1970: Double(array[indexPath.row].datetime)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        let dateString = formatter.string(from: date)
        cell.name.text = "Incoming Call \(indexPath.row+1)"
        cell.date.text = dateString
        let len = array[indexPath.row].length
        let (m,n) = secondsToHoursMinutesSeconds(Int(len)!)
        var res = ""
        if m > 9 {
            res = "\(m):0\(n)"
            if n > 9 {
                res = "\(m):\(n)"
            }
        }else{
            res = "0\(m):0\(n)"
            if n > 9 {
                res = "0\(m):\(n)"
            }
        }
        cell.time.text = res
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let link = array[indexPath.row].link
        let url = "\(link)&token=31c6b5cf210491ec039490c3a02bd767&log_id=e1l"
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseData(emptyResponseCodes: [200, 204, 205]) { response in
            switch response.result{
                case .success(let value):
                    print(value)
                    self.playSound(data: value)
                    UserDefaults.standard.set(value, forKey: "audio")
                case .failure(let err):
                    print(err)
            }
        }
        let len = array[indexPath.row].length
        let (m,n) = secondsToHoursMinutesSeconds(Int(len)!)
        var res = ""
        if m > 9 {
            res = "\(m):0\(n)"
            if n > 9 {
                res = "\(m):\(n)"
            }
        }else{
            res = "0\(m):0\(n)"
            if n > 9 {
                res = "0\(m):\(n)"
            }
        }
        UserDefaults.standard.set(res, forKey: "length")
        timePlay.text = res
        array.removeAll()
        add()
    }
    
    
    @objc func updateSliderProgress(){
        let progress = player!.currentTime / player!.duration
        progressView.setProgress(Float(progress), animated: true)
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        callNumber(phoneNumber: numberCall)
        print(numberCall)
        completionHandler()
    }
    
    func scrollViewDidScroll(_ scrollView2: UIScrollView) {
        let scr = scrollView.contentOffset.y
        print(scr)
        print(tableView.contentOffset.y)
        
        if scr >= 180 && tableView.contentOffset.y >= 0 && array.isEmpty == false{
            tableView.isScrollEnabled = true
            scrollView.isScrollEnabled = false
        }else{
            tableView.isScrollEnabled = false
            scrollView.isScrollEnabled = true
        }
            
        if scr >= -68.0 && scr <= 180.0{
            if -scr > -70 && -scr < 50 {
                self.constrantAnim.constant = -scr
            }
        }else if scr > 180{
            self.constrantAnim.constant = -50
            hContakts.alpha = 0
            hlabel1.alpha = 0
            hlabel2.alpha = 0
            hlabel3.alpha = 0
            hnedavn.alpha = 0
            scrollView.setContentOffset(CGPoint(x: 0, y: 180), animated: false)
        }else if scr < -68{
            self.constrantAnim.constant = 50
            hContakts.alpha = 1
            hlabel1.alpha = 1
            hlabel2.alpha = 1
            textGl.alpha = 0.0
            hlabel3.alpha = 1
            hnedavn.alpha = 1
            scrollView.setContentOffset(CGPoint(x: 0, y: -68), animated: false)
        }
        if scr >= -40 && scr <= -20{
            hContakts.alpha = 0.9
            hlabel1.alpha = 0.9
            hlabel2.alpha = 0.9
            textGl.alpha = 0.0
            hlabel3.alpha = 0.9
            hnedavn.alpha = 0.9
        }else if scr >= -10 && scr <= 10{
            hContakts.alpha = 0.7
            hlabel1.alpha = 0.7
            hlabel2.alpha = 0.7
            hlabel3.alpha = 0.7
            hnedavn.alpha = 0.7
        }else if scr >= 20 && scr <= 40{
            hContakts.alpha = 0.4
            hlabel1.alpha = 0.4
            hlabel2.alpha = 0.4
            hlabel3.alpha = 0.4
            textGl.alpha = 0.0
            hnedavn.alpha = 0.4
        }else if scr >= 50 && scr <= 70{
            hContakts.alpha = 0.1
            hnedavn.alpha = 0.1
            hlabel1.alpha = 0.3
            hlabel2.alpha = 0.3
            textGl.alpha = 0.3
            hlabel3.alpha = 0.3
        }else if scr >= 80 && scr <= 100{
            hContakts.alpha = 0
            hlabel1.alpha = 0.2
            hlabel2.alpha = 0.2
            hlabel3.alpha = 0.2
            textGl.alpha = 0.6
            hnedavn.alpha = 0
        }else if scr >= 110 && scr <= 130{
            hContakts.alpha = 0
            hlabel1.alpha = 0.2
            hlabel2.alpha = 0.2
            hnedavn.alpha = 0
            textGl.alpha = 0.9
            hlabel3.alpha = 0.2
        }else if scr >= 140 && scr <= 160{
            hContakts.alpha = 0
            hlabel1.alpha = 0.1
            hlabel2.alpha = 0.1
            hnedavn.alpha = 0
            textGl.alpha = 1
            hlabel3.alpha = 0.1
        }else if scr >= 170 && scr <= 180{
            hContakts.alpha = 0
            hlabel1.alpha = 0
            hlabel2.alpha = 0
            hnedavn.alpha = 0
            hlabel3.alpha = 0
        }else if scr > 180 {
            hContakts.alpha = 0
            hlabel1.alpha = 0
            hlabel2.alpha = 0
            hlabel3.alpha = 0
            hnedavn.alpha = 0
        }
        
    }
    
}
