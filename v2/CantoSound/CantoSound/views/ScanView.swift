//
//  ScanView.swift
//  CantoSound
//
//  Created by Pak Lau on 25/9/2020.
//

import SwiftUI

struct ScanView: View {
    @Binding var cameraView: CameraView
    @Binding var capturedImage: UIImage
    @Binding var detectedSentences: [String]
    @Binding var keyword: String
    @Binding var showCameraView: Bool
    @Binding var loadingDefinition: Bool
   
    
    var onCommitKeywordInputField: () -> Void
    
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
    

  
    var body: some View {
        VStack {
            cameraView.frame(height: UIScreen.screenHeight / 3)
            Button(
                action : {
                    cameraView.controller.photoCaptureCompletionBlock = handlePhotoReceived
                    cameraView.controller.capturePhoto()
                },
                label : {Image(systemName: "camera.viewfinder")
                    .resizable()
                    .frame( width:40, height: 40)
                    .foregroundColor(Color.primary)
                }).padding()
            
            WordCandidateListView(words: $detectedSentences, selectedWord: $keyword, shouldViewPresented: $showCameraView, onWordSelected: onCommitKeywordInputField)
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static func emptyFn() {}
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self, content:
                ScanView(
                    cameraView: .constant(CameraView()),
                    capturedImage: .constant(UIImage()),
                    detectedSentences: .constant([
                        "張國榮",
                        "穌黎世"
                    ]),
                    keyword: .constant(""),
                    showCameraView: .constant(true),
                    loadingDefinition: .constant(false),
                    onCommitKeywordInputField: emptyFn
                )
                .preferredColorScheme
        )
        .previewDevice("iPad (8th generation)")
    }
}
