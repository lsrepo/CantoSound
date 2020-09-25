//
//  ScanView.swift
//  CantoSound
//
//  Created by Pak Lau on 25/9/2020.
//

import SwiftUI

struct ScanView: View {
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
    
    let cameraView = CameraView()
    var body: some View {
        VStack {
            cameraView.frame(height: 200)
            Button(
                action : {
                    cameraView.controller.photoCaptureCompletionBlock = handlePhotoReceived
                    cameraView.controller.capturePhoto()
                },
                label : {Image(systemName: "camera.viewfinder")
                    .resizable()
                    .foregroundColor(.white)
                    .frame( width:40, height: 40)
                }).padding()
            
            WordCandidateListView(words: $detectedSentences, selectedWord: $keyword, shouldViewPresented: $showCameraView, onWordSelected: onCommitKeywordInputField)
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static func emptyFn() {}
    static var previews: some View {
        Group {
            ScanView(
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
            .preferredColorScheme(.dark)
        }
    }
}
