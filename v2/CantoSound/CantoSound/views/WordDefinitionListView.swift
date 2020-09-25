//
//  WordDefinitionListView.swift
//  CantoSound
//
//  Created by Pak Lau on 22/9/2020.
//

import SwiftUI

struct WordDefinitionListView: View {
    @Binding var definitions: [ChineseWordefinition]
   
    var body: some View {
        List{
            ForEach(definitions) { definition in
                WordDefinitionRow(definition: definition)
            }
         }
    }
}

struct WordDefinitionListView_Previews: PreviewProvider {
    static var example = [ChineseWordefinition(
        syllableYale: "oi3",
        homophones: ["鑀", "焥", "薆"],
        words: ["愛心", "愛情", "愛護", "愛惜", "博愛", "熱愛", "偏愛", "疼愛"]
    )]
    @Binding var definitions: [ChineseWordefinition]
    
    static var previews: some View {
        WordDefinitionListView(definitions: .constant(example))
            .preferredColorScheme(.dark)
    }
}

struct WordDefinitionRow: View, Identifiable {
    var definition: ChineseWordefinition
    var id = UUID()
    var body: some View {
        HStack{
            VStack{
                Text(definition.homophones.first ?? "")
                    .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                Text(definition.syllableYale ?? "")
                    .font(.title3)
            }.padding()
            Text(definition.words.joined(separator: ", "))
        }
    }
}
