//
//  CantoneseDictionary.swift
//  CantoSound
//
//  Created by Pak Lau on 22/9/2020.
//

import Foundation

class CantoneseDictionary {
    func checkCuhk(text: String) -> String? {
        guard let character = text.prefix(1).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        guard let lookUpUrl = URL(string: "https://humanum.arts.cuhk.edu.hk/Lexis/lexi-mf/search.php?word=\(character)") else {
            return nil
        }

        do {
            let html = try String(contentsOf: lookUpUrl, encoding: .utf8)
            return html
        } catch let error {
            print("Error: \(error)")
            return nil
        }
    }
    
    func lookUp(character: String) -> ChineseWord? {
        guard let html = checkCuhk(text: character) else {return nil}
        
        let htmlToWordDefinitionProcessor = HtmlToWordDefinitionProcessor(html: html)
        return htmlToWordDefinitionProcessor.getWord()
    }
}
