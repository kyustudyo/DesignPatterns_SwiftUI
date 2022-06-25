//
//  ContentView.swift
//  DesignPatterns
//
//  Created by Hankyu Lee on 2022/06/24.
//

import SwiftUI

// Source of truth가 State로서 ContentView 내부에 선언되어 있기때문에 API를 통해 데이터를 받아오면 뷰가 업데이트 됩니다. 간편하지만, 뷰의 코드가 길어집니다. Webservice struct에서는 API를 통해 데이터를 얻는 코드가 있습니다. 3가지가 있는데, 나머지 2가지는 코드 아래부분에 extension Webservice에 있습니다. 이는 개수를 반영하지는 않습니다.
struct ContentView: View {
    
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

extension ContentView {
    private func getWordsData(count: String) {
        
        // 1번 방법 - 개수 미반영, 10개 가져옴
//        WebService.getWords { words in
//            self.words = words
//        }
        
        // 2번 방법 - 개수 미반영, 10개 가져옴
//        WebService.getDataWithGeneric { (result: Result<WordsViewModel, Error>) in
//            switch result {
//            case .success(let data):
//                self.words = data.words
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
        
        // 3번 방법
        guard let wordsUrl = Constants.urlForTenWordsByCount(count: count) else {
            return
        }
        let wordsResource = Resource<WordsViewModel>(url: wordsUrl) { data in
            WordsViewModel(data)
        }
        WebService.getDataWithGeneric2(resource: wordsResource) { vm in
            if let vm = vm {
                self.words = vm.words
            }
        }
    }
}

enum Constants {
    static let tenWordsURL = "https://random-word-api.herokuapp.com/word?number=10"
    static func urlForTenWordsByCount(count: String) -> URL? {
        return URL(string: "https://random-word-api.herokuapp.com/word?number=\(count.escaped())")
    }
}

extension String {
    
    func escaped() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
}

// WordsViewModel 뿐 아니라 다른 ViewModel을 만들어서 getDataWithGeneric함수에서 사용하고 싶을 경우를 위해 프로토콜 정의합니다.
protocol ViewModel {}

struct WordsViewModel: ViewModel {
    
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

struct Resource<T> {
    let url: URL
    let parse: (Data) -> T?
}

struct WebService {
    
    // 3번 함수. 2번 함수로 할 경우, 다운캐스팅등 코드가 길어지는거에 반해 Resource구조체를 이용해서 코드 단순화.
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// TODO: 에러 추가
enum NetworkError: Error {
    case badUrl
    case badData
}

// 아래는 WebService에서 다른 방법의 함수 입니다.

extension WebService {
    
    // 2번 함수. completion을 통해 결과를 반영할 때, ViewModel protocol을 따르는 ViewModel에 반영하도록 정합니다. Result 이용하여 Error 처리도 하도록 합니다.
    static func getDataWithGeneric<T:ViewModel>(completion: @escaping (Result<T,Error>) -> Void) {
        let url = URL(string: Constants.tenWordsURL)!
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data else {
                // TODO: Error handling
                completion(.failure(NetworkError.badData))
                return
            }
            if let transfer = WordsViewModel(data) as? T {
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

extension WebService {
    
    // 1번 함수. API를 통해 데이터를 가져온 후 [String]으로 변환 후 completion 클로저를 통해 UI에 출력합니다.
    static func getWords(completion: @escaping ([String]) -> Void) {
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

// 몇번째 인덱스에 있는지 알아보기
//func findIndex<T:Equatable>(from list: [T], valueToFind: T) -> Int? {
//    return list.firstIndex {
//        $0 == valueToFind
//    }
//}
