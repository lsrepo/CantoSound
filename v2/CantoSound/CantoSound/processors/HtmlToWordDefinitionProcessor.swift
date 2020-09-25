//
//  HtmlToWordDefinitionProcessor.swift
//  CantoSound
//
//  Created by Pak Lau on 21/9/2020.
//

import Foundation
import SwiftSoup

class HtmlToWordDefinitionProcessor {
    var html: String
    
    init(html: String){
        self.html = html
    }
    
    func getDefinitionRowElements()  throws -> Elements{
        let doc: Document = try SwiftSoup.parse(html)
        let table = try doc.select("#char_can_table > tbody")
        let headerRow = try table.select("tr:nth-child(1)")
        try headerRow.remove()
        
        let definitionRows = try doc.select("tr:has(td.char_can_head)")
        return definitionRows
    }
    
    func getNoteRowElements() throws -> Elements {
        let doc: Document = try SwiftSoup.parse(html)
        let noteRows = try doc.select("td.char_can_note")
        // A sound follows a word
        try noteRows.select("span").remove()
        try noteRows.select("script").remove()
        return noteRows
    }
    
    func getWord() -> ChineseWord? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let ranking = try doc.select(CUHKLexisSelector.ranking).text()
            let cangjie = try doc.select(CUHKLexisSelector.cangjie).text()
            let definitions = try getDefinitions()
            
            return ChineseWord(ranking: Int(ranking), cangjie: cangjie, definitions: definitions)
        } catch {
            return nil
        }
    }
    
    func getHomophones(rowElement: Element) throws ->  [String] {
        var homophones = [String]()
        
        do {
            let homophonesGood = try rowElement.select(CUHKLexisSelector.homophonesGood).map{try $0.text()}
            homophones.append(contentsOf: homophonesGood)
        }
        do {
            if (homophones.isEmpty){
                let homophonesAll = try rowElement.select(CUHKLexisSelector.homophonesAll).map{try $0.text()}
                homophones.append(contentsOf: homophonesAll)
            }
        }
        
        return homophones
    }
        
    func getDefinitions() throws -> [ChineseWordefinition] {
        let noteElements = try getNoteRowElements()
        let definitionElements = try getDefinitionRowElements()
        
        guard (noteElements.count == definitionElements.count) else {
            return []
        }
        
        var delimiterSet =  CharacterSet.whitespacesAndNewlines
        delimiterSet.insert(",")
        
        return try definitionElements.enumerated()
            .map{ (index, rowElement) in
                ChineseWordefinition(
                    syllableYale: try rowElement.select(CUHKLexisSelector.audioLink).attr("onClick")
                        .lowercased()
                        .replacingOccurrences(of: "_playsound( \'sound/", with: "")
                        .replacingOccurrences(of: ".mp3\' );", with: ""),
                    homophones: try getHomophones(rowElement: rowElement),
                    words: try rowElement.select(CUHKLexisSelector.words)
                        .text()
                        .components(separatedBy: delimiterSet)
                        .filter {!$0.isEmpty},
                    note: try noteElements[index].text()
                )
            }
    }
}

struct CUHKLexisSelector {
    static let ranking = "body > table:nth-child(1) > tbody > tr:nth-child(2) > td:nth-child(6)"
    static let cangjie = "body > table:nth-child(1) > tbody > tr:nth-child(2) > td:nth-child(4)"
    
    // For each row
    static let audioLink = "td.char_can_head > a"
    static let syllable = "td:nth-child(1)"
    static let homophonesGood = "td:nth-child(4) > div > a.rad-linkbold"
    static let homophonesAll = "td:nth-child(4) > div > a"
    
    static let words = "td:nth-child(5)"
    static let note = "td.char_can_note"
}

struct ChineseWord: Equatable, Identifiable{
    var id = UUID()
    var ranking: Int?
    var cangjie: String?
    var definitions: [ChineseWordefinition]
}

struct ChineseWordefinition: Equatable, Identifiable {
    var id = UUID()
    var syllableYale: String?
    var audioLink: String?
    var homophones: [String]
    var words: [String]
    var note: String?
}
