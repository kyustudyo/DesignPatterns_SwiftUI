//
//  GetWords2.swift
//  DesignPatterns
//
//  Created by Hankyu Lee on 2022/06/26.
//

import SwiftUI

struct GetWords2: View {
    
    @State var words:[String] = []
    @State var numberToGet:String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField(text: $numberToGet) {
                    Text("10 미만 자연수")
                }
                Button {
                    getWordsData(count: numberToGet)
                } label: {
                    Text("확인")
                }
            }.padding()
            
            Form {
                ForEach(words, id:\.self) { word in
                    Text(word)
                }
            }
        }
        .padding(.leading)
    }
}

extension GetWords2 {
    private func getWordsData(count: String) {
        
        WebService.getWords(count: count) { words in
            self.words = words
        }
    }
}
extension WebService {
    
    // API를 통해 데이터를 가져온 후 [String]으로 변환 후 completion 클로저를 통해 UI에 출력합니다.
    static func getWords(count: String, completion: @escaping ([String]) -> Void) {
        let url = Constants.urlForTenWordsByCount(count: count)!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                fatalError()
            }
            let transfer = WordsViewModel3(data)
            DispatchQueue.main.async {
                completion(transfer.words)
            }
        }.resume()
    }
}


struct WordsViewModel3 {
    
    var words: [String] = []
    
    init(_ data: Data) {
        self.words = transerDataToArray(data)
    }

//    var nWords: Int? {
//        words.count
//    }
//    var longWords: [String]? {
//        words.filter{$0.count > 5}
//    }
    
    // String to Array
    private func transerDataToArray(_ data:Data) -> [String] {
        
        let totalString = String(data: data, encoding: .utf8) ?? ""
        let stringArray = totalString.split(separator: ",").map{String($0)}
        
        return stringArray.map{
            $0.filter{$0.isLetter}
        }
    }
}

struct GetWords2_Previews: PreviewProvider {
    static var previews: some View {
        GetWords2()
    }
}
