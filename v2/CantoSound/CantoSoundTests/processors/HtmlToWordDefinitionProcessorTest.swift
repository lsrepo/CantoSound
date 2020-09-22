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
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = Bundle(for: type(of: self))
        let path = bundle .path(forResource: "oi", ofType: "html")
        oiHtml = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSoup() throws {
        do{
            let doc: Document = try SwiftSoup.parse(oiHtml)
            let table = try doc.select("body > form > table:nth-child(1)  > tbody ")
            let headerRow = try table.select("tr:nth-child(1)")
            try headerRow.remove()
            
            let definitionRows = try table.select("tr")
            XCTAssertEqual(definitionRows.count, 2)
            
            let firstDefinitionRow = definitionRows.first()
            XCTAssertEqual(try firstDefinitionRow?.select("td:nth-child(1)").text(), "oi3")
        } catch {
            print("error")
        }
    }
    
    func testShouldReturnAllDefinitions()  {
        let processor = HtmlToWordDefinitionProcessor(html: oiHtml)

        let oi = processor.getWord()
        let expectedOi =  ChineseWord(definitions: [
            ChineseWordefinition(
                syllableYale: "oi3",
                homophones: ["鑀", "焥", "薆"],
                words: ["愛心", "愛情", "愛護", "愛惜", "博愛", "熱愛", "偏愛", "疼愛"]
            )
        ])

        XCTAssertEqual(oi?.definitions.first, expectedOi.definitions.first)

    }
}
