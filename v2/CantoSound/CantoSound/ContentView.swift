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
                    .stroke(Color.white, lineWidth: 1.5)
            ).padding()
    }
}

struct ContentView: View {
    @State var capturedImage = UIImage()
    @State var detectedWords = [Word]()
    @State var keyword = ""
    @State var showCameraView = false
    @State var selectedWord = ChineseWord(definitions: [])
    @State var loadingDefinition = false
    
    var cantoneseDictionary = CantoneseDictionary()
    
    func lookUpDictionary(text: String) -> ChineseWord? {
        return cantoneseDictionary.lookUp(character: text)
    }
    
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
    
    func onCommitKeywordInputField() {
        detectedWords = [Word(character: keyword)]
        loadingDefinition = true
        DispatchQueue.global().async {
            if let word = self.lookUpDictionary(text: keyword) {
                self.selectedWord = word
            }
            loadingDefinition = false
        }
    }
    
    var cameraView = CameraView()
    
    var body: some View {
        VStack {
            Spacer(minLength: 50)
            HStack{
                TextField("", text: $keyword, onCommit: onCommitKeywordInputField)
                    .textFieldStyle(MyTextFieldStyle())
                    .keyboardType(.default)
                    .font(.title)
                    .lineLimit(1)
                    .frame(width: 150, height: 150.0)
                    .padding()
                
                Button(
                    action : {
                        showCameraView = true
                    },
                    label : { Image(systemName: "camera.circle")
                        .resizable()
                        .foregroundColor(.white)
                        .frame( width:40, height: 40)}
                )
                .padding()
            }
            ZStack(alignment: .top){
                ProgressView()
                    .scaleEffect(1.5, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                    .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                    .opacity(loadingDefinition ? 1 : 0 )
                
                WordDefinitionListView(definitions: $selectedWord.definitions)
                    .opacity(loadingDefinition ? 0 : 1 )
            }
            
        }.sheet(isPresented: $showCameraView, content: {
            cameraView
                .frame(maxHeight: 200)
            Button(
                action : {
                    cameraView.controller.photoCaptureCompletionBlock = handlePhotoReceived
                    cameraView.controller.capturePhoto()
                    showCameraView = false
                },
                label : {Image(systemName: "camera.viewfinder")
                    .resizable()
                    .foregroundColor(.white)
                    .frame( width:40, height: 40)
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
