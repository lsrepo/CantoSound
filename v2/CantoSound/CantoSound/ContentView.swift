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
    @State var detectedSentences = [String]()
    @State var keyword = ""
    @State var showCameraView = true
    @State var selectedWord = ChineseWord(definitions: [])
    @State var loadingDefinition = false
    
    var cantoneseDictionary = CantoneseDictionary()
    
    func lookUpDictionary(text: String) -> ChineseWord? {
        return cantoneseDictionary.lookUp(character: text)
    }
    
    func handleText(sentences: [String]) {
        print(sentences)
        detectedSentences = sentences
    }
    
    func handlePhotoReceived(image: UIImage?) {
        guard let image = image else {return}
        capturedImage = image
        
        let imageToTextProcessor = ImageToTextProcessor(textHandler: handleText)
        imageToTextProcessor.detect(image: image)
    }
    
    func onCommitKeywordInputField() {
        detectedSentences = [keyword]
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
//                , onCommit: onCommitKeywordInputField)
                TextField("", text: $keyword)
                    .textFieldStyle(MyTextFieldStyle())
                    .keyboardType(.default)
                    .font(.title3)
                    .lineLimit(1)
                    .frame(width: 200, height: 150.0)
                    .padding()
                    .onChange(of: keyword, perform: { value in
                        onCommitKeywordInputField()
                    })
                
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
            VStack {
            cameraView
                .frame(maxHeight: 300)
                Button(
                    action : {
                        cameraView.controller.photoCaptureCompletionBlock = handlePhotoReceived
                        cameraView.controller.capturePhoto()
//                        showCameraView = false
                    },
                    label : {Image(systemName: "camera.viewfinder")
                        .resizable()
                        .foregroundColor(.white)
                        .frame( width:40, height: 40)
                    })
                    .frame(height: 100)
                
                
                WordCandidateListView(words: $detectedSentences, selectedWord: $keyword, shouldViewPresented: $showCameraView, onWordSelected: onCommitKeywordInputField)
                    .frame(height: 300)
//                Spacer()
            }
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
