//
//  ImageToTextProcessorTest.swift
//  CantoSoundTests
//
//  Created by Pak Lau on 20/9/2020.
//

import XCTest
@testable import CantoSound

class ImageToTextProcessorTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShouldReturnDetectedStrings() throws {
        let expectation = XCTestExpectation(description: "Returned selected text")

        func stringsHandler(strings: [String]) {
            expectation.fulfill()
        }
            
        let processor = ImageToTextProcessor(textHandler: stringsHandler)
        
        guard let image = UIImage(named: "aTextAtCenter", in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            throw TestError.runtimeError("Test image not found")
        }
        
        processor.detect(image: image)
        wait(for: [expectation], timeout: 3.0)
    }

}

