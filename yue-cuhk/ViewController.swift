//
//  ViewController.swift
//  yue-cuhk
//
//  Created by Pak on 2016-11-17.
//  Copyright © 2016 pakwlau.com. All rights reserved.
//

import UIKit
import Kanna
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var labelConnectionProbelm: UILabel!
    var dataSource = [Sense]()
    var audioPlayer = AVAudioPlayer()
    var hasInternet:Bool = false{
        didSet{
            print("hasInternet:\(hasInternet)" )
            if (!hasInternet){
                print(" no coneection")
                labelConnectionProbelm.alpha = 1
            }else{
                print(" has coneection")
                labelConnectionProbelm.alpha = 0
            }
        }
    }
    var lastKeyword = "一"
    // Table View
    @IBOutlet weak var tfCharacter: UITextField!
    @IBOutlet weak var resultTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        searchCharacter(keyword: lastKeyword)
        // Do any additional setup after loading the view, typically from a nib
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configure(){
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        // textField
        tfCharacter.delegate = self
        
        // appearance
        self.view.backgroundColor = Constants.backgroundColor
    }
    
    func searchCharacter(keyword:String){
        let html = getHtml(keyword: keyword)
        
        // check internet connection
        guard (html != nil) else {
            hasInternet = false
            return
        }
        hasInternet = true
        let senses = parseHtml(html: html!)
        dataSource = senses
        resultTableView.reloadData()
    }
    
    
    
    func getHtml(keyword:String)->String?{
        
        let big5CfIndex = CFIndex(CFStringEncodings.big5.rawValue)
        let big5 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(big5CfIndex))
        let escapedKeyword = keyword.addingPercentEscapes(using: String.Encoding(rawValue: big5))
        
        let urlStr = "http://humanum.arts.cuhk.edu.hk/Lexis/lexi-can/search.php?q=" + escapedKeyword!
        let url = URL(string:urlStr)
        if let data = NSData(contentsOf: url!){
            let html = NSString(data: data as Data, encoding: big5) as! String
            return html
        }
        return nil
    }
    
    func parseHtml(html:String) -> [Sense]{
        print("======= Begin Parsing ======= ")
        var senses = [Sense]()
        
        if let doc = Kanna.HTML(html:html , encoding: .utf8){
            // loop through each valid result
            for tr in doc.css("form table tr"){
                var contents = [String]()
                
                // remove first and last result
                if (tr.css("td[align^='center']").first != nil ){
                    for td in tr.css("td"){
                        if let content = td.content?.trimmingCharacters(in: CharacterSet.newlines){
                            
                            //add content to contents
                            contents.append(content)
                        }
                    }
                    // create sense object and add it to collection of senses
                    let syllable = contents[0]
                    let explanation = extractExplanation(str: contents[5])
                    //replacingOccurrences(of: " ", with: "")
                    let homophones = contents[3].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).components(separatedBy: ",")
                    
                    print(explanation)
                    
                    let sense = Sense(syllable: syllable, homophones: homophones, explanation: explanation)
                    senses.append(sense)
                }
            }
        }
        return senses
    }
    
    
    func extractExplanation(str:String)->String{
        let explanation:String
        
        // filter text from [ to ]
        let sqbBeg = str.range(of: "[")
        let sqbEnd = str.range(of: "]")
        
        if ( (sqbBeg != nil) && (sqbEnd != nil)){
            let basicExpl = str.substring(to: sqbBeg!.lowerBound)
            let extraExpl = str.substring(from: sqbEnd!.upperBound)
            explanation = basicExpl + " ," + extraExpl
        }else{
            explanation = str
        }
        return explanation
    }
}


extension ViewController: UITableViewDelegate,UITableViewDataSource{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SenseTableViewCell
        
        let row = indexPath.row
        // fill in data
        
        if (dataSource[row].homophones.first != ""){
            cell.labelHomophone.text = dataSource[row].homophones.first
        }else{
            cell.labelHomophone.text = "/"
        }
        
        cell.labelSyllabel.text = dataSource[row].syllable
        cell.labelExplanation.text = dataSource[row].explanation
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // functional
        let row = indexPath.row
        let syllable = dataSource[row].syllable
        playAudio(syllable: syllable)
    }
    
    
}


extension ViewController:UITextFieldDelegate{
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        print("End editing")
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let keyword = tfCharacter.text
        self.lastKeyword = keyword!
        let charCount = keyword!.characters.count
        print(charCount)
        
        switch charCount {
        case 0:
            print("wow! 0")
            return false
        case 1:
            print("wow! 1")
            tfCharacter.resignFirstResponder();
            tfCharacter.text = "【 " + keyword! + " 】"
            self.searchCharacter(keyword: keyword!)
            return true
        default:
            print("wow! more than 1")
            return false
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if (hasInternet){
            textField.text?.removeAll()
        }else{
           textField.text = lastKeyword
        }
        
    }
    
    
    
}

extension ViewController:AVAudioPlayerDelegate{
    
    func playAudio(syllable:String){
        do {
            let url = "http://humanum.arts.cuhk.edu.hk/Lexis/lexi-can/sound/" + syllable + ".wav"
            let fileURL = URL(string:url)
            if let soundData = NSData(contentsOf:fileURL!){
                self.audioPlayer = try AVAudioPlayer(data: soundData as Data)
                audioPlayer.prepareToPlay()
                audioPlayer.delegate = self
                audioPlayer.play()
            }

        } catch {
            print("Error getting the audio file")
        }
    }
}
