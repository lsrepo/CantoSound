//
//  WordDefinitionListView.swift
//  CantoSound
//
//  Created by Pak Lau on 22/9/2020.
//

import SwiftUI
import AVFoundation

struct WordDefinitionListView: View {
    @Binding var definitions: [ChineseWordefinition]
    
    var body: some View {
        List {
            ForEach(definitions) {
                definition in WordDefinitionRow(
                    definition: WordDefinitionRowData(
                        homophone: definition.homophones.first ?? "",
                        syllabel: definition.syllableYale ,
                        longText: definition.words
                            .joined(separator: ", ")
                            .appending(definition.words.isEmpty ? "" : " ")
                            .appending(definition.note ?? ""),
                        audioLink: "http://humanum.arts.cuhk.edu.hk/Lexis/lexi-mf/sound/\(definition.syllableYale).Mp3"
                    )
                )
            }
        }
    }
}

struct WordDefinitionRowData {
    var homophone: String
    var syllabel: String
    var longText: String
    var audioLink: String
}

struct WordDefinitionListView_Previews: PreviewProvider {
    static var example = [ChineseWordefinition(
        syllableYale: "oi3",
        homophones: ["鑀", "焥", "薆"],
        words: ["愛心", "愛情", "愛護", "愛惜", "博愛", "熱愛", "偏愛", "疼愛"],
        note: "異讀字"
    )]
    @Binding var definitions: [ChineseWordefinition]


    static var previews: some View {
       ForEach(ColorScheme.allCases, id: \.self, content: WordDefinitionListView(
                definitions: .constant(example)).preferredColorScheme
       )
   }
}

struct WordDefinitionRow: View, Identifiable {
    var definition: WordDefinitionRowData
    var id = UUID()
    
    func playSound() {
        let url = URL(fileURLWithPath: definition.audioLink)
        Sounds.playSounds(soundfile: url)
    }
    
    var body: some View {
        HStack{
            VStack{
                Text(definition.homophone).font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                Text(definition.syllabel).font(.title3)
            }.padding()
            Text(definition.longText)
        }
        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
            playSound()
        })
    }
}
