//
//  ContentView.swift
//  CantoSound
//
//  Created by Pak Lau on 20/9/2020.
//

import SwiftUI

struct ContentView: View {
    @State var capturedImage = UIImage()
    @State var detectedWords = [Word]()

    func handleText(sentences: [String]) {

        let characters = sentences.flatMap{ sentence in Array(sentence) }
        let words = characters.map{ character in Word(character: String(character))}
        detectedWords = words
    }
    
    func handlePhotoReceived(image: UIImage?) {
        guard let image = image else {return}
        capturedImage = image
        
        let imageToTextProcessor = ImageToTextProcessor(textHandler: handleText)
        imageToTextProcessor.detect(image: image)
    }
    
    var cameraView = CameraView()

    var body: some View {
        VStack {
            cameraView
                .frame(maxHeight: 200)
            Button(
                action : {
                    cameraView.controller.photoCaptureCompletionBlock = handlePhotoReceived
                    cameraView.controller.capturePhoto()
                },
                label : {Text("Detect")
                })
                .frame(height: 200)
//
//            Image(uiImage: capturedImage)
//                .resizable().aspectRatio(contentMode: .fit)
//                .frame(height:200)
//                .foregroundColor(.black)
            WordList(words: $detectedWords)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
