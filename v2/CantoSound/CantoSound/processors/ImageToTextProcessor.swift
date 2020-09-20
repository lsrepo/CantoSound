//
//  ImageToTextProcessor.swift
//  CantoSound
//
//  Created by Pak Lau on 20/9/2020.
//

import Foundation
import UIKit
import Vision

class ImageToTextProcessor {
    var textHandler: ([String]) -> Void
    
    init(textHandler: @escaping ([String]) -> Void) {
        self.textHandler = textHandler
    }
  
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        
        // Process the recognized strings.
        self.textHandler(recognizedStrings)
    }
    
    
    func detect(image: UIImage) {
        
        // Get the CGImage on which to perform requests.
        guard let cgImage = image.cgImage else { return }

        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
        
        request.recognitionLanguages =  ["zh-Hant"]
        request.recognitionLevel = .accurate

        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func getChineseCharacters(strings: [String]){
        
    }
    

}
