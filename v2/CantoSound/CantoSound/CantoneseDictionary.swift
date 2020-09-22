//
//  CantoneseDictionary.swift
//  CantoSound
//
//  Created by Pak Lau on 22/9/2020.
//

import Foundation

class CantoneseDictionary {
    	
    // TODO: Use async if necessary
    func checkCuhk(character: String) -> String? {
        let myURLString = "https://google.com"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return nil
        }

        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            print("HTML : \(myHTMLString)")
        } catch let error {
            print("Error: \(error)")
            return nil
        }
        return nil
    }
    
//    func lookUp(character: String) -> ChineseWord? {
//        
//    }
    
}
