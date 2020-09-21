//
//  ContentView.swift
//  CantoSound
//
//  Created by Pak Lau on 20/9/2020.
//

import SwiftUI

struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color.white, lineWidth: 2)
            ).padding()
    }
}

struct ContentView: View {
    @State var capturedImage = UIImage()
    @State var detectedWords = [Word]()
    @State var keyword = ""
    @State var showCameraView = false
    
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
            HStack{
                TextField("打字", text: $keyword)
                    .textFieldStyle(MyTextFieldStyle())
                    .keyboardType(.default)
                    .font(.largeTitle)
                    .lineLimit(1)
                    .frame(width: 150, height: 150.0)
                    .padding()
                Text("或")
                    .padding()
                Button(
                    action : {
                        showCameraView = true
                    },
                    label : { Image(systemName: "camera.viewfinder")
                        .resizable()
                        .foregroundColor(.white)
                        .frame( width:40, height: 40)}
                )
                .padding()
            }
            WordList(words: $detectedWords)
        }.sheet(isPresented: $showCameraView, content: {
            cameraView
                .frame(maxHeight: 200)
            Button(
                action : {
                    cameraView.controller.photoCaptureCompletionBlock = handlePhotoReceived
                    cameraView.controller.capturePhoto()
                    showCameraView = false
                },
                label : {Text("Detect")
            })
            .frame(height: 200)
            
        })

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark)
            ContentView()
        }
    }
}
