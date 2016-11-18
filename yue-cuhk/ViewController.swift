//
//  ViewController.swift
//  yue-cuhk
//
//  Created by Pak on 2016-11-17.
//  Copyright © 2016 pakwlau.com. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import WebKit


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getHtml()
        // Do any additional setup after loading the view, typically from a nib
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHtml(){
        let big5CfIndex = CFIndex(CFStringEncodings.big5.rawValue)
        let big5 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(big5CfIndex))
        let keyword = "文"
        let escapedKeyword = keyword.addingPercentEscapes(using: String.Encoding(rawValue: big5))

        let urlStr = "http://humanum.arts.cuhk.edu.hk/Lexis/lexi-can/search.php?q=" + escapedKeyword!
        let url = URL(string:urlStr)
        let data = NSData(contentsOf: url!)
        
        let html = NSString(data: data! as Data, encoding: big5) as! String
        parseHtml(html: html)
    }
    
    func parseHtml(html:String){
        print("======= Begin Parsing ======= ")
        
        if let doc = Kanna.HTML(html:html , encoding: .utf8){
            
            for tr in doc.css("form table tr"){
                // remove first and last result
                if (tr.css("td[align^='center']").first != nil ){
                    for td in tr.css("td"){
                        let content = td.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        print(content)
                    }
                }
                print("\n")
            }

           
            
            
            
            
            
            
            
//            let first = data.first!.innerHTML!
//            if let firstLineBreakIndex = first.range(of: "<")?.lowerBound{
//                 firstContent = first.substring(to: firstLineBreakIndex)
//            }else{
//                firstContent = data.first?.content
//            }
//            
//            
//            print("first ",firstContent)
//            print("second ",data[1].content)
            
        }
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
