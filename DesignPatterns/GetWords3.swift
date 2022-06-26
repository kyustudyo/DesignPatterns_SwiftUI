//
//  GetWords3.swift
//  DesignPatterns
//
//  Created by Hankyu Lee on 2022/06/26.
//

import SwiftUI

// 프로토콜 사용.

struct GetWords3: View {
    
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


struct GetWords3_Previews: PreviewProvider {
    static var previews: some View {
        GetWords3()
    }
}

extension WebService {
    
    // Result 이용하여 Error 처리도 하도록 합니다.
    static func getDataWithGeneric<T>(count: String, completion: @escaping (Result<T,Error>) -> Void) {
        let url = Constants.urlForTenWordsByCount(count: count)!
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data else {
                // TODO: Error handling
                completion(.failure(NetworkError.badData))
                return
            }
            
            // WordsViewModel2가 T를 conform함을 알지못함.
            if let transfer = WordsViewModel2(data) as? T {
                DispatchQueue.main.async {
                    completion(.success(transfer))
                }
            } else {
                // TODO: Error handling
                completion(.failure(NetworkError.badData))
            }
        }.resume()
    }
}

struct WordsViewModel2 {
    
    var words: [String] = []
    
    init(_ data: Data) {
        words = transerDataToArray(data)
    }

    // String to Array
    private func transerDataToArray(_ data:Data) -> [String] {
        
        let totalString = String(data: data, encoding: .utf8) ?? ""
        let stringArray = totalString.split(separator: ",").map{String($0)}
        
        return stringArray.map{
            $0.filter{$0.isLetter}
        }
    }
    
//    var nWords: Int {
//        words.count
//    }
//    var longWords: [String] {
//        words.filter{$0.count > 5}
//    }

}

extension GetWords3 {
    private func getWordsData(count: String) {
        
    
        WebService.getDataWithGeneric(count: count) { (result: Result<WordsViewModel2, Error>) in
            // 위와같이 명시해줘야 사용가능.
            switch result {
            case .success(let data):
                self.words = data.words
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
       
    }
}
