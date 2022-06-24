//
//  ContentView.swift
//  DesignPatterns
//
//  Created by Hankyu Lee on 2022/06/24.
//

import SwiftUI

//주석

struct ContentView: View {
    
    @State var words:[String] = []
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(height:0)
                .background(.gray)
                
            Text("리스트 확인")
                .padding()
                .onTapGesture {
                    WebService.getWords { words in
                        self.words = words
                    }
                }
                
            Form {
                ForEach(words, id:\.self) { word in
                    Text(word)
                }
            }
            
        }
        
    }
}

enum Constants {
    static let tenWordsURL = "https://random-word-api.herokuapp.com/word?number=10"
}

struct WordsViewModel {
    
    var words: [String] = []
    
    init(_ data: Data) {
        words = transerDataToArray(data)
    }

    private func transerDataToArray(_ data:Data) -> [String] {
        
        let totalString = String(data: data, encoding: .utf8) ?? ""
        let stringArray = totalString.split(separator: ",").map{String($0)}
        
        return stringArray.map{
            $0.filter{$0.isLetter}
        }
    }
    
    var nWords: Int {
        words.count
    }
    
    var longWords: [String] {
        words.filter{$0.count > 5}
    }

}

enum WebService {
    static func getWords(completion: @escaping ([String]) -> ()) {
        let url = URL(string: Constants.tenWordsURL)!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                fatalError()
            }
            
            let transfer = WordsViewModel(data)
            
            DispatchQueue.main.async {
                completion(transfer.words)
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
