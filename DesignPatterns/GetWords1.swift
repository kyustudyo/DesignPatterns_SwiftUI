//
//  ContentView.swift
//  DesignPatterns
//
//  Created by Hankyu Lee on 2022/06/24.

import SwiftUI

// Source of truth가 State로서 ContentView 내부에 선언되어 있기때문에 API를 통해 데이터를 받아오면 뷰가 업데이트 됩니다. Webservice struct에서는 API를 통해 데이터를 얻는 코드가 있습니다.

struct GetWords1: View {
    
//    @State var words:[String] = []
    @State var wordsViewModel: WordsViewModel
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
                ForEach(wordsViewModel.words, id:\.self) { word in
                    Text(word)
                }
            }
        }
        .padding(.leading)
    }
}

extension GetWords1 {
    private func getWordsData(count: String) {
        
        guard let wordsUrl = Constants.urlForTenWordsByCount(count: count) else {
            //TODO: Error handling
            return
        }
        let wordsResource = Resource<WordsViewModel>(url: wordsUrl) { data in
            let words = transerDataToArray(data) // data type -> [String]
            return WordsViewModel(words)
        }
        WebService.getDataWithGeneric2(resource: wordsResource) { vm in
            if let vm = vm {
//                self.words = vm.words
                wordsViewModel = vm
            } else {
                print("오류 발생")
            }
        }
    }
    
    // String to Array
    private func transerDataToArray(_ data:Data) -> [String] {
        
        let totalString = String(data: data, encoding: .utf8) ?? ""
        let stringArray = totalString.split(separator: ",").map{String($0)}
        
        return stringArray.map{
            $0.filter{$0.isLetter}
        }
    }
    
}
struct WordViewModel {
    let word: String
    
    var length: Int {
        word.count
    }
    
    init(_ word: String) {
        self.word = word
    }//이거 만들면 인자 _ 로 할 수 있다.
    
}
struct WordsViewModel {
    
    let words: [String]
    var toggleValue: Bool = false
    var number: Int = 0
    
    init(_ words: [String]) {
        self.words = words
    }

    var nWords: Int {
        words.count
    }
    var longWords: [String] {
        words.filter{$0.count > 5}
    }
    func wordAtIndex(_ index: Int) -> WordViewModel {
        let word = self.words[index]
        return WordViewModel(word)
    }

    mutating func mut() {
        number += 1
    }
}

struct Resource<T> {
    let url: URL
    let parse: (Data) -> T?
}

struct WebService {
    
    // Resource구조체 이용.
    static func getDataWithGeneric2<T>(resource: Resource<T>, completion: @escaping (T?) -> Void) {
        URLSession.shared.dataTask(with: resource.url) { data, _, error in
            guard error == nil else {
                completion(nil) // nil로 오류 처리
                return
            }
            if let data = data {
                DispatchQueue.main.async {
                    completion(resource.parse(data))
                }
            } else {
                completion(nil)
            }
        }.resume()
    }
}

struct GetWords1_Previews: PreviewProvider {
    static var previews: some View {
        GetWords1(wordsViewModel: WordsViewModel([""]))
    }
}

// TODO: 에러 추가
enum NetworkError: Error {
    case badUrl
    case badData
}

enum Constants {
 
    static func urlForTenWordsByCount(count: String) -> URL? {
        return URL(string: "https://random-word-api.herokuapp.com/word?number=\(count.escaped())")
    }
}

extension String {
    
    func escaped() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
}

// 몇번째 인덱스에 있는지 알아보기
//func findIndex<T:Equatable>(from list: [T], valueToFind: T) -> Int? {
//    return list.firstIndex {
//        $0 == valueToFind
//    }
//}
