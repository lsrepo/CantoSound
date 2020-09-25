//
//  HtmlToWordDefinitionProcessorTest.swift
//  CantoSoundTests
//
//  Created by Pak Lau on 21/9/2020.
//

import XCTest
import SwiftSoup

@testable import CantoSound

class HtmlToWordDefinitionProcessorTest: XCTestCase {
    var oiHtml: String = ""
    
    func getHtmlFile(name: String) throws -> String {
        let bundle = Bundle(for: type(of: self))
        let path = bundle .path(forResource: name, ofType: "html")
        
        return try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
    }
    
    func testSoup() throws {
        do{
            let doc: Document = try SwiftSoup.parse(oiHtml)
            let table = try doc.select("#char_can_table > tbody")
            let headerRow = try table.select("tr:nth-child(1)")
            try headerRow.remove()
            
            let definitionRows = try doc.select("tr:has(td.char_can_head)")
            XCTAssertEqual(definitionRows.count, 2)
            
            let firstDefinitionRow = definitionRows.first()
            XCTAssertEqual(try firstDefinitionRow?.select("td:nth-child(1)").text(), "oi")
        } catch {
            print("error")
        }
    }
    
    func testShouldReturnAllDefinitions_Oi() throws {
        let htmlFile = try getHtmlFile(name: "oi")
        let processor = HtmlToWordDefinitionProcessor(html: htmlFile)
	
        let oi = processor.getWord()
        let expectedOi =  ChineseWord(definitions: [
            ChineseWordefinition(
                syllableYale: "oi3",
                homophones: ["堨", "壒", "僾"],
                words: ["愛心", "愛情", "愛護", "愛惜", "博愛", "熱愛", "偏愛", "疼愛"]
            )
        ])

        XCTAssertEqual(oi?.definitions.first?.syllableYale, expectedOi.definitions.first?.syllableYale)
        XCTAssertEqual(oi?.definitions.first?.homophones, expectedOi.definitions.first?.homophones)
        XCTAssertEqual(oi?.definitions.first?.words, expectedOi.definitions.first?.words)
    }
    
    func testShouldReturnAllDefinitionsWithNote_Wui() throws {
        let htmlFile = try getHtmlFile(name: "wui")
        let processor = HtmlToWordDefinitionProcessor(html: htmlFile)
    
        let oi = processor.getWord()
        let expectedOi =  ChineseWord(definitions: [
            ChineseWordefinition(
                syllableYale: "kui3",
                homophones: ["繪", "檜", "澮", "儈", "憒", "聵", "鄶", "廥", "禬", "旝", "襘", "槶"],
                words: [], note: "「會」的異讀字"
            )
        ])

        XCTAssertEqual(oi?.definitions[1].syllableYale, expectedOi.definitions.first?.syllableYale)
        XCTAssertEqual(oi?.definitions[1].homophones, expectedOi.definitions.first?.homophones)
        XCTAssertEqual(oi?.definitions[1].note, expectedOi.definitions.first?.note)
    }
}
