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
                    .stroke(Color.primary, lineWidth: 1.5)
            )
        .padding()
    }
}

struct ContentView: View {
    @State var capturedImage = UIImage()
    @State var detectedSentences = [String]()
    @State var keyword = ""
    @State var showCameraView = true
    @State var selectedWord = ChineseWord(definitions: [])
    @State var loadingDefinition = false
    @State var cameraView = CameraView()
    
    var cantoneseDictionary = CantoneseDictionary()
    
    func lookUpDictionary(text: String) -> ChineseWord? {
        return cantoneseDictionary.lookUp(character: text)
    }
    
    func onCommitKeywordInputField() {
        
        loadingDefinition = true
        DispatchQueue.global().async {
            if let word = self.lookUpDictionary(text: keyword) {
                self.selectedWord = word
            }
            loadingDefinition = false
        }
    }
    
    var wordInputField: some View {
        TextField("", text: $keyword, onCommit: onCommitKeywordInputField)
            .textFieldStyle(MyTextFieldStyle())
            .keyboardType(.default)
            .font(.title3)
            .lineLimit(1)
            
    }
    
    var cameraButton: some View {
        Button(
            action : {
                showCameraView.toggle()
            },
            label : {
                Image(systemName: "camera.viewfinder").resizable().foregroundColor(Color.orange)
            }
        )
    }


    var body: some View {
        
        VStack {
            Spacer(minLength: 50)
            Text("請輸入或影低想查嘅字").font(.subheadline)
            HStack{
                wordInputField.frame(width: 200, height: 150.0)
                cameraButton.frame( width:50, height: 50)
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
        }
        .sheet(isPresented: $showCameraView, content: {
            ScanView(
                cameraView: $cameraView,
                capturedImage: $capturedImage,
                detectedSentences: $detectedSentences,
                keyword: $keyword,
                showCameraView: $showCameraView,
                loadingDefinition: $loadingDefinition,
                onCommitKeywordInputField: onCommitKeywordInputField
            )
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
           ForEach(ColorScheme.allCases, id: \.self, content: ContentView().preferredColorScheme)
       }
}
