//
//  WordList.swift
//  CantoSound
//
//  Created by Pak Lau on 21/9/2020.
//

import SwiftUI

struct WordCandidateListView: View {
    @Binding var words: [String]
    @Binding var selectedWord: String
    @Binding var shouldViewPresented: Bool
    
    var onWordSelected: () -> Void
    
    var body: some View {
        ScrollView(){
            TagCloudView(words: $words, tags: words).onChange(of: words, perform: { value in
                if (value.count == 1 && value.first?.count == 1){
                    selectedWord = value.first!
                    onWordSelected()
                    shouldViewPresented = false
                }
            })
        }
    }
}

struct WordCandidateListViewPreviews: PreviewProvider {
    static var example = [
        "和式客房",
        "你好嗎",
        "查良庸",
        "和式客房",
        "你好嗎",
        "查良庸"
    ]
    @Binding var words: [String]
    
    static var previews: some View {
        WordCandidateListView(words: .constant(example), selectedWord: .constant(""), shouldViewPresented: .constant(true)){
            
        }
        .preferredColorScheme(.dark)
    }
}

struct TagCloudView: View {
    @Binding var words: [String]
    var tags: [String]
    
    @State private var totalHeight
        = CGFloat.zero       // << variant for ScrollView/List
    //    = CGFloat.infinity   // << variant for VStack
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(self.tags, id: \.self) { tag in
                self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }
    
    private func item(for text: String) -> some View {
        Button(action: {
            words = Array(text).map{ te in  String(te) }
        }, label: {
            Text(text)
                .padding(.all, 10)
                .font(.title3)
                .background(Color.white)
                .foregroundColor(Color.black)
                .cornerRadius(10)
        })
    }
    
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
