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
//        let url = "http://pakwlau.com/yue/cu.html"
        let url = "http://humanum.arts.cuhk.edu.hk/Lexis/lexi-can/guide.php"
        
        //methodDependent
        Alamofire.request(url).responseString(encoding: String.Encoding.utf8) { (response) in
            print("Result: ",response.result.error)
            // if sucess
            guard (response.result.isSuccess) else {return}
            let result = response.result.value!
            
           
            
            print(result)
            //self.parseHtml(html: response.result.value!)
        }
    }
    
    func parseHtml(html:String){
        print("======= Begin Parsing ======= ")
 
        if let doc = Kanna.HTML(html:html , encoding: .utf8){
            
            // Search for nodes by CSS
//            for link in doc.css("div nowrap") {
//                print(link.text)
//            }
            
            let data = doc.css("tr td div")
            let first = data.first!.innerHTML!
            let firstLineBreakIndex = first.range(of: "\n")?.lowerBound
            let content = first.substring(to: firstLineBreakIndex!)
            
            print("first ",content)
            print("second ",data[1].content)

        }
    }
    
}

