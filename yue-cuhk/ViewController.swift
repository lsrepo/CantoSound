//
//  ViewController.swift
//  yue-cuhk
//
//  Created by Pak on 2016-11-17.
//  Copyright © 2016 pakwlau.com. All rights reserved.
//

import UIKit
import Kanna


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let senses = searchCharacter(keyword: "文")
        print(senses)

        // Do any additional setup after loading the view, typically from a nib
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchCharacter(keyword:String)->[Sense]{
        let html = getHtml(keyword: keyword)
        let senses = parseHtml(html: html)
        return senses
    }
    
    func getHtml(keyword:String)->String{
        let big5CfIndex = CFIndex(CFStringEncodings.big5.rawValue)
        let big5 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(big5CfIndex))
        let escapedKeyword = keyword.addingPercentEscapes(using: String.Encoding(rawValue: big5))
        
        let urlStr = "http://humanum.arts.cuhk.edu.hk/Lexis/lexi-can/search.php?q=" + escapedKeyword!
        let url = URL(string:urlStr)
        let data = NSData(contentsOf: url!)
        
        let html = NSString(data: data! as Data, encoding: big5) as! String
        return html
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
                        if let content = td.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines){
                            //add content to contents
                            contents.append(content)
                        }
                    }
                    // create sense object and add it to collection of senses
                    let sense = Sense(syllable: contents[0], homophones: contents[3], explanation: contents[5])
                    senses.append(sense)
                }
            }
        }
        return senses
    }
}


extension Data {
    var stringValue: String? {
        return String(data: self, encoding: .utf8)
    }
    var base64EncodedString: String? {
        return base64EncodedString(options: .lineLength64Characters)
    }
}
extension String {
    var utf8StringEncodedData: Data? {
        return data(using: .utf8)
    }
    
    var base64DecodedData: Data? {
        return Data(base64Encoded: self, options: .ignoreUnknownCharacters)
    }
}
