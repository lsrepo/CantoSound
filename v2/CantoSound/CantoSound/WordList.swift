//
//  WordList.swift
//  CantoSound
//
//  Created by Pak Lau on 21/9/2020.
//

import SwiftUI

struct WordList: View {
//    @State var words = [Word( character: "a"), Word( character: "b")]
//
    @Binding var words: [Word]
    var body: some View {
        List{
            ForEach(words) {word in
                         WordRow(word: word, id: UUID())
             }
         }
    
    }

    
//    func updateWords(newWords: [String]) -> Void {
//        let wwwords = newWords.map{ word in Word(  character: word) }
//        self.words.append(Word(character: "c"))
//    }
}

//struct WordList_Previews: PreviewProvider {
//    static var previews: some View {
//        WordList(words: <#Binding<[Word]>#>)
//    }
//}

struct WordRow: View {
    var word: Word
    var id: UUID
    var body: some View {
        HStack {
            Text(word.character)
            Spacer()
        }
    }
}

struct Word: Identifiable , Hashable{
    var id = UUID()
    
    var character: String
    var defintion: String?
}



struct LandmarkRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WordRow(word: Word(character: "a"), id: UUID())
                .previewLayout(.fixed(width: 300, height: 70))
            WordRow(word: Word(character: "ab"), id: UUID())
                .previewLayout(.fixed(width: 300, height: 70))
        }
    }
}
