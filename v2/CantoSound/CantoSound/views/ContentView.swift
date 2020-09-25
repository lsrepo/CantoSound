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
        TextField("", text: $keyword)
            .textFieldStyle(MyTextFieldStyle())
            .keyboardType(.default)
            .font(.title3)
            .lineLimit(1)
            
            .onChange(of: keyword, perform: { value in
                onCommitKeywordInputField()
            })
    }
    
    var cameraButton: some View {
        Button(
            action : {
                showCameraView = true
            },
            label : {
                Image(systemName: "camera.circle").resizable().foregroundColor(.white)
            }
        )
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: 50)
            HStack{
                wordInputField.frame(width: 200, height: 150.0).padding()
                cameraButton.frame( width:40, height: 40).padding()
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
        Group {
            ContentView()
                .preferredColorScheme(.dark)
            ContentView()
        }
    }
}
