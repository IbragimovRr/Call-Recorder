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
import CoreTelephony


class MainViewController: UIViewController, CNContactPickerDelegate {

    
    //Localized
    @IBOutlet weak var l72: UILabel!
    @IBOutlet weak var l1: UILabel!
    @IBOutlet weak var l2: UILabel!
    @IBOutlet weak var l8: UILabel!
    @IBOutlet weak var l7: UILabel!
    @IBOutlet weak var l6: UILabel!
    @IBOutlet weak var l5: UILabel!
    @IBOutlet weak var l4: UILabel!
    @IBOutlet weak var l3: UIButton!
    @IBOutlet weak var l10: UILabel!
    @IBOutlet weak var l9: UILabel!
    @IBOutlet weak var l11: UILabel!
    @IBOutlet weak var l12: UILabel!
    //Localized
    
    
    @IBOutlet var selectedView: UIView!
    @IBOutlet weak var skipConstr: NSLayoutConstraint!
    @IBOutlet weak var btnNum: UIButton!
    @IBOutlet weak var tableViewSettings: UITableView!
    @IBOutlet weak var myNumberS: UILabel!
    @IBOutlet weak var myNumberEnd: UILabel!
    @IBOutlet weak var rightSettings: NSLayoutConstraint!
    @IBOutlet weak var leftSettings: NSLayoutConstraint!
    @IBOutlet weak var playbtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timePlay: UILabel!
    @IBOutlet weak var textGl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let ns = UNUserNotificationCenter.current()
    var displayLink : CADisplayLink! = nil
    var num = ""
    var numberCall = ""
    var indexPlay = 0
    var player: AVAudioPlayer?
    var arraySettings = Array<Settings>()
    var hload = false
    @IBOutlet weak var hlabel3: UILabel!
    @IBOutlet weak var hlabel2: UILabel!
    @IBOutlet weak var hlabel1: UILabel!
    @IBOutlet weak var hnedavn: UIView!
    @IBOutlet weak var hContakts: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constrantAnim: NSLayoutConstraint!
    var array = Array<Audio>()
    @IBOutlet weak var enablenotif: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let center = UNUserNotificationCenter.current()
           center.getNotificationSettings { (settings) in
               if(settings.authorizationStatus == .authorized){
                   DispatchQueue.main.async {
                       self.enablenotif.isHidden = true
                       UserDefaults.standard.set(true, forKey: "notif")
                   }
               }else{
                   DispatchQueue.main.async {
                       self.enablenotif.tag = 1
                       UserDefaults.standard.set(false, forKey: "notif")
                   }
                        
               }
           }
        add()
        addObservers()
        let length = UserDefaults.standard.string(forKey: "length")
        timePlay.text = length
        progressView.progress = 0
        scrollView.setContentOffset(CGPoint(x: 0, y: -48), animated: false)
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableViewSettings.delegate = self
        tableViewSettings.dataSource = self
        ns.delegate = self
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        scrollView.delegate = self
        addSettingsCountry()
        btnNum.isEnabled = false
        print(array)
        if UserDefaults.standard.bool(forKey: "current") == false{
            tableView.isHidden = true
            btnNum.isEnabled = true
            
        }else  {
            
            numberSetting()
        }
        
        localized()
    }
    
    func numberSetting(){
        if UserDefaults.standard.string(forKey: "phoneNumber")! == "+17777777"{
            myNumberEnd.text = "admin"
            myNumberS.text = ""
            return
        }
        var start = ""
        var result = ""
        let phoneNum = UserDefaults.standard.string(forKey: "phoneNumber")!
        let country = country.countryDictionary
        for i in country {
            if i.value[0] == phoneNum[1]{
                if i.value[1] == phoneNum[2]{
                    if i.value[2] == phoneNum[3]{
                        if i.value[3] == phoneNum[4]{
                            start += i.value[2] + i.value[3]
                        }else{
                            start += i.value[2]
                        }
                    }else{
                        start += i.value[1]
                    }
                }else{
                    start = i.value[0]
                }
            }
            if start == i.value {
                myNumberS.text = "+\(start)"
                result = start
            }
        }
        let one = phoneNum.dropFirst()
        var two = one
        for _ in 0...result.count-1{
            two = "\(two.dropFirst())"
        }
        var a = ""
        var b = ""
        var c = ""
        var d = ""
        if result.count == 2{
            a = "\(Array(two)[0])\(Array(two)[1])\(Array(two)[2])"
            b = "\(Array(two)[3])\(Array(two)[4])\(Array(two)[5])"
            c = "\(Array(two)[6])\(Array(two)[7])"
            d = "\(Array(two)[8])"
        }else if result.count == 1{
            a = "\(Array(two)[0])\(Array(two)[1])\(Array(two)[2])"
            b = "\(Array(two)[3])\(Array(two)[4])\(Array(two)[5])"
            c = "\(Array(two)[6])\(Array(two)[7])"
            d = "\(Array(two)[8])\(Array(two)[9])"
        }else if result.count == 3{
            a = "\(Array(two)[0])\(Array(two)[1])\(Array(two)[2])"
            b = "\(Array(two)[3])\(Array(two)[4])\(Array(two)[5])"
            c = "\(Array(two)[6])\(Array(two)[7])"
            d = ""
        }
        myNumberEnd.text = "\(a) \(b) \(c) \(d)"
        
    }
    
    
    func localized() {
        l1.text = NSLocalizedString("main1", comment: "")
        l2.text = NSLocalizedString("main2", comment: "")
        l3.setTitle(NSLocalizedString("notif", comment: ""), for: .normal)
        l4.text = NSLocalizedString("keyboard", comment: "")
        l5.text = NSLocalizedString("contacts", comment: "")

        l6.text = NSLocalizedString("recent", comment: "")
        l7.text = NSLocalizedString("hid1", comment: "")
        l8.text = NSLocalizedString("settings", comment: "")
        l72.text = NSLocalizedString("hid2", comment: "")
        l9.text = NSLocalizedString("myNumber", comment: "")
        l11.text = NSLocalizedString("serviceNumbers", comment: "")
        l12.text = NSLocalizedString("delAcc", comment: "")
        
    }
    
    
    
    func addSettingsCountry(){
       
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
                        self.arraySettings.append(Settings(country: country, pgone: phone, image: image))
                        
                    }
                  
                    self.tableViewSettings.reloadData()
                }
                case .failure(let error):
                    print("\(error.localizedDescription)")
            }
            
        }
    }
    
    @IBAction func skip(_ sender: UIButton) {
        if sender.tag == 0{
            UIView.animate(withDuration: 1.0, delay: 0.2) {
                self.skipConstr.constant = 0
                self.view.layoutIfNeeded()
            }
            sender.setImage(UIImage(named:"right"), for: .normal)
            sender.tag = 1
        }else{
            UIView.animate(withDuration: 1.0, delay: 0.2) {
                self.skipConstr.constant = 270
                self.view.layoutIfNeeded()
            }
            sender.setImage(UIImage(named:"down"), for: .normal)
            sender.tag = 0
        }
    }
    
    @IBAction func play(_ sender: UIButton) {
        if sender.tag == 0 && progressView.progress == 0{
            
            let audio = UserDefaults.standard.object(forKey: "audio")
            if audio != nil {
                sender.setImage(UIImage(named: "stop.png"), for: .normal)
                sender.tag = 1
                playSound(data: audio as! Data)
                
            }
            
        }else if progressView.progress > 0 && sender.tag == 0{
            sender.setImage(UIImage(named: "stop.png"), for: .normal)
            sender.tag = 1
            player?.play()
        }else if sender.tag == 1{
            sender.setImage(UIImage(named: "start.png"), for: .normal)
            sender.tag = 0
            player?.stop()
        }
    }
    @IBAction func enableNotif(_ sender: UIButton) {
        ns.requestAuthorization(options: [.alert,.sound,.badge]) { success, err in
            if success == true{
                DispatchQueue.main.async {
                    self.enablenotif.isHidden = true
                    
                }
            }else{
                DispatchQueue.main.async {
                    self.enablenotif.isHidden = false
                    if let appSettings = URL(string: UIApplication.openSettingsURLString){
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func cont(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: "notif") == true{
            if UserDefaults.standard.bool(forKey: "current") == true {
                let vc = CNContactPickerViewController()
                vc.delegate = self
                self.present(vc, animated: true)
            }else{
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        var phone = ""
        let v = (contact.phoneNumbers[0].value as! CNPhoneNumber).value(forKey: "digits") as! String
        if UserDefaults.standard.string(forKey: "settingsPhone") == nil{
            phone = UserDefaults.standard.string(forKey: "servicePhone")!
        }else {
            phone = UserDefaults.standard.string(forKey: "settingsPhone")!
            phone.remove(at: phone.startIndex)
        }
        let token = UserDefaults.standard.string(forKey: "token")!
        let log_id = UserDefaults.standard.string(forKey: "log_id")!
        let phoneNum = UserDefaults.standard.string(forKey: "phoneNumber")!
        let text = "\(contact.givenName)"
        let encoded = text.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted)
        let url = "https://recmycallssingapore.com/v1/get_code_new/?token=\(token)&log_id=\(log_id)&service_phone=\(phoneNum)&comment=\(encoded!)"
        print(url)
    AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON(emptyResponseCodes: [200, 204, 205]) { response in
        switch response.result{
            case .success(let value):
                let json = JSON(value)
            if json.isEmpty == false{
                print(json)
                let code = json["code"].stringValue
                UserDefaults.standard.set(code, forKey: "code")
                self.callNumber(phoneNumber: "+\(phone),\(code)")
            }
            case .failure(let err):
            print("\(err.localizedDescription)")
        }
    }
        
        
        notificationSender(number: v)

        numberCall = v
        
        
    }
    
    private func isOnPhoneCall() -> Bool
        {
            let callCntr = CTCallCenter()

            if let calls = callCntr.currentCalls
            {
                for call in calls
                {
                    if call.callState == CTCallStateConnected || call.callState == CTCallStateDialing || call.callState == CTCallStateIncoming
                    {
                        print("In call")
                        var phone = ""
                        if UserDefaults.standard.string(forKey: "settingsPhone") == nil{
                            phone = UserDefaults.standard.string(forKey: "servicePhone")!
                        }else {
                            phone = UserDefaults.standard.string(forKey: "settingsPhone")!
                            phone.remove(at: phone.startIndex)
                        }
                        let code = UserDefaults.standard.string(forKey: "code")
                        callNumber(phoneNumber: "+\(phone),\(code!)")
                        return true
                    }
                }
            }
            print("No calls")
            return false
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
                print(err?.localizedDescription as Any)
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
        
        if UserDefaults.standard.bool(forKey: "current") == false{
            return
        }
            let token = UserDefaults.standard.string(forKey: "token")!
            let log_id = UserDefaults.standard.string(forKey: "log_id")!
            let url = "https://recmycallssingapore.com/v1/list/?token=\(token)&limit=100&log_id=\(log_id)"
            print(url)
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON(emptyResponseCodes: [200, 204, 205]) { response in
            switch response.result{
                case .success(let value):
                    let json = JSON(value)["recordings"]
                    print("\(JSON(value))--------------------------------------------")
                    self.array.removeAll()
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
                            print("\(comment)-----------------")
                        }
                        for x in 0...self.array.count-1 {
                            if self.array[x].id == UserDefaults.standard.string(forKey: "idTouch") {
                                self.indexPlay = x
                            }
                        }
                        if self.array.isEmpty == true {
                            self.tableView.isHidden = true
                        }else{
                            self.tableView.reloadData()
                        }
                    }else{
                        self.tableView.isHidden = true
                    }
                    self.btnNum.isEnabled = true
                case .failure(let err):
                    print(err.localizedDescription)
            }
        }
        print(array)
    }
    
    func call(number:String) {
        if UserDefaults.standard.bool(forKey: "current") == true{
            let token = UserDefaults.standard.string(forKey: "token")!
            let log_id = UserDefaults.standard.string(forKey: "log_id")!
            let phoneNum = UserDefaults.standard.string(forKey: "phoneNumber")!
        let url = "https://recmycallssingapore.com/v1/get_code_new/?token=\(token)&log_id=\(log_id)&service_phone=\(phoneNum)&comment=\(number)"
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
        
    }
    
  
    func playSound(data:Data) {

        do {
            player = try AVAudioPlayer(data: data)
            displayLink = CADisplayLink(target: self, selector: #selector(updateSliderProgress))
            displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
            playbtn.setImage(UIImage(named: "stop.png"), for: .normal)
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
        let center = UNUserNotificationCenter.current()
           center.getNotificationSettings { (settings) in
               if(settings.authorizationStatus == .authorized){
                   DispatchQueue.main.async {
                       self.enablenotif.isHidden = true
                   }
               }else{
                   DispatchQueue.main.async {
                       self.enablenotif.tag = 1
                   }
                        
               }
           }
        add()
        if UserDefaults.standard.bool(forKey: "not") == true{
            UserDefaults.standard.set(false, forKey: "not")
            performSegue(withIdentifier: "number", sender: self)
        }
    }
    
    
    func arrfor(){
        var a = array
        for x in 0...array.count-1 {
            for i in 0...array.count-1 {
                if array[x].id == array[i].id && x != i {
                    a.remove(at: i)
                    
                }
            }
        }
        array = a
    }
    
    @IBAction func del(_ sender: UIButton) {
        
    }
    
    @IBAction func settings(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: "current"){
            UIView.animate(withDuration: 1.0, delay: 0.1) {
                self.leftSettings.constant = 10
                self.rightSettings.constant = 10
                self.view.layoutIfNeeded()
            }
            for x in 0...arraySettings.count-1 {
                if UserDefaults.standard.string(forKey: "servicePhone") == arraySettings[x].pgone {
                    UserDefaults.standard.set(x, forKey: "selectSettings2")
                }
            }
            let pos = UserDefaults.standard.integer(forKey: "selectSettings2")
            print(pos)
            let indexPath = IndexPath(row: pos, section: 0)
            tableViewSettings.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
                
        }else{
            navigationController?.popToRootViewController(animated: true)
        }
        
    }
    @IBAction func exit(_ sender: Any) {
        UIView.animate(withDuration: 1.0, delay: 0.1){
            self.leftSettings.constant = 600
            self.rightSettings.constant = -600
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func number(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: "notif") == true{
            if UserDefaults.standard.bool(forKey: "current") == true{
                performSegue(withIdentifier: "number", sender: self)
            }else{
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "del"{
            if let vc = segue.destination as? DelModelViewController {
                vc.delegate = self
            }
        }
    }
    
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
}
extension MainViewController:UIScrollViewDelegate,UNUserNotificationCenterDelegate,UITableViewDelegate,UITableViewDataSource, AVAudioPlayerDelegate,DeleteDelegate{
    
    func delete(bool: Bool) {
        if bool{
            tableView.isHidden = true
            array.removeAll()
            tableView.reloadData()
            UIView.animate(withDuration: 1.0, delay: 0.1) {
                self.leftSettings.constant = 600
                self.rightSettings.constant = -600
                self.view.layoutIfNeeded()
            }
            resetDefaults()
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true{
            playbtn.setImage(UIImage(named: "start.png"), for: .normal)
            let len = array[indexPlay].length
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
            timePlay.text = res
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewSettings{
            return arraySettings.count
        }else{
            return array.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if tableView == tableViewSettings{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Settings", for: indexPath) as! SettingsTableViewCell
            let pos = UserDefaults.standard.integer(forKey: "selectSettings2")
            cell.select.isHidden = true
            if pos == indexPath.row{
                cell.select.isHidden = false
            }
            cell.phone.text = arraySettings[indexPath.row].pgone
            cell.country.text = arraySettings[indexPath.row].country
            cell.flag.image = UIImage(named: arraySettings[indexPath.row].image)
            cell.selectedBackgroundView = selectedView
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "audio", for: indexPath) as! AudioTableViewCell
            if indexPlay == indexPath.row {
                
                if hload == false {
                    cell.loading.stopAnimating()
                    cell.loading.isHidden = true
                }else{
                    cell.loading.startAnimating()
                    cell.loading.isHidden = false
                }
                cell.name.font = UIFont(name: "Qanelas-Bold", size: 20.0)
                cell.time.font = UIFont(name: "Qanelas-Bold", size: 20.0)
            }else{
                cell.loading.stopAnimating()
                cell.loading.isHidden = true
                cell.name.font = UIFont(name: "Qanelas-Medium", size: 20.0)
                cell.time.font = UIFont(name: "Qanelas-Medium", size: 20.0)
            }
            
            let date = Date(timeIntervalSince1970: Double(array[indexPath.row].datetime)!)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM"
            let dateString = formatter.string(from: date)
            if array[indexPath.row].comment == "" {
                cell.name.text = "Incoming Call \(indexPath.row+1)"
            }else{
                cell.name.text = array[indexPath.row].comment
            }
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewSettings{
            tableViewSettings.reloadData()
            UserDefaults.standard.set(arraySettings[indexPath.row].pgone, forKey: "settingsPhone")
            UserDefaults.standard.set(indexPath.row, forKey: "selectSettings2")
        }else{
            indexPlay = indexPath.row
            hload = true
            UserDefaults.standard.set(array[indexPlay].id, forKey: "idTouch")
            if UserDefaults.standard.bool(forKey: "current") == true{
                let token = UserDefaults.standard.string(forKey: "token")!
                let log_id = UserDefaults.standard.string(forKey: "log_id")!
            let link = array[indexPath.row].link
            let url = "\(link)&token=\(token)&log_id=\(log_id)"
            AF.request(url, method: .get, encoding: JSONEncoding.default).responseData(emptyResponseCodes: [200, 204, 205]) { response in
                switch response.result{
                    case .success(let value):
                        self.hload = false
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
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
        }
    }
    
    
    @objc func updateSliderProgress(){
        let progress = player!.currentTime / player!.duration
        progressView.setProgress(Float(progress), animated: true)
        let currentTime1 = Int((player!.currentTime))
        let minutes = currentTime1/60
        let seconds = currentTime1 - minutes * 60
        let time = NSString(format: "%02d:%02d", minutes,seconds+1) as String
        let time2 = NSString(format: "%02d:%02d", minutes,seconds) as String
        if time2 != "00:00"{
            timePlay.text = time
        }
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
        var n = 180.0
        if UIDevice.current.name == "iPhone 8"{
            n = 220.0
        }
        print(scr)
        if scr >= n && tableView.contentOffset.y >= 0 && array.isEmpty == false{
            tableView.isScrollEnabled = true
            scrollView.isScrollEnabled = false
        }else{
            tableView.isScrollEnabled = false
            scrollView.isScrollEnabled = true
        }
        if scr >= -68.0 && scr <= n{
            if -scr > -70 && -scr < 50 {
                self.constrantAnim.constant = -scr
            }
        }else if scr > 180{
            self.constrantAnim.constant = -50
            hContakts.alpha = 0
            hlabel1.alpha = 0
            hlabel2.alpha = 0
            enablenotif.alpha = 0
            hlabel3.alpha = 0
            hnedavn.alpha = 0
            scrollView.setContentOffset(CGPoint(x: 0, y: n), animated: false)
        }else if scr < -68{
            self.constrantAnim.constant = 50
            hContakts.alpha = 1
            hlabel1.alpha = 1
            hlabel2.alpha = 1
            enablenotif.alpha = 1
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
            enablenotif.alpha = 0.9
            hlabel3.alpha = 0.9
            hnedavn.alpha = 0.9
        }else if scr >= -10 && scr <= 10{
            hContakts.alpha = 0.7
            hlabel1.alpha = 0.7
            enablenotif.alpha = 0.7
            hlabel2.alpha = 0.7
            hlabel3.alpha = 0.7
            hnedavn.alpha = 0.7
        }else if scr >= 20 && scr <= 40{
            hContakts.alpha = 0.4
            hlabel1.alpha = 0.4
            hlabel2.alpha = 0.4
            hlabel3.alpha = 0.4
            textGl.alpha = 0.0
            enablenotif.alpha = 0.4
            hnedavn.alpha = 0.4
        }else if scr >= 50 && scr <= 70{
            hContakts.alpha = 0.1
            hnedavn.alpha = 0.1
            hlabel1.alpha = 0.3
            enablenotif.alpha = 0.3
            hlabel2.alpha = 0.3
            textGl.alpha = 0.3
            hlabel3.alpha = 0.3
        }else if scr >= 80 && scr <= 100{
            hContakts.alpha = 0
            hlabel1.alpha = 0.2
            hlabel2.alpha = 0.2
            hlabel3.alpha = 0.2
            enablenotif.alpha = 0.2
            textGl.alpha = 0.6
            hnedavn.alpha = 0
        }else if scr >= 110 && scr <= 130{
            hContakts.alpha = 0
            hlabel1.alpha = 0.2
            hlabel2.alpha = 0.2
            hnedavn.alpha = 0
            textGl.alpha = 0.9
            enablenotif.alpha = 0.2
            hlabel3.alpha = 0.2
        }else if scr >= 140 && scr <= 160{
            hContakts.alpha = 0
            hlabel1.alpha = 0.1
            hlabel2.alpha = 0.1
            enablenotif.alpha = 0.1
            hnedavn.alpha = 0
            textGl.alpha = 1
            hlabel3.alpha = 0.1
        }else if scr >= 170 && scr <= n{
            hContakts.alpha = 0
            hlabel1.alpha = 0
            hlabel2.alpha = 0
            textGl.alpha = 1
            enablenotif.alpha = 0
            hnedavn.alpha = 0
            hlabel3.alpha = 0
        }else if scr > n {
            hContakts.alpha = 0
            hlabel1.alpha = 0
            enablenotif.alpha = 0
            hlabel2.alpha = 0
            textGl.alpha = 1
            hlabel3.alpha = 0
            hnedavn.alpha = 0
        }
        
    }
    
}
extension String {
    
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
