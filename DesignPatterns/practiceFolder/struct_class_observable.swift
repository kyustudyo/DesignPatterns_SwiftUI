//
//  ContentView.swift
//  DesignPatterns
//
//  Created by Hankyu Lee on 2022/06/24.
//


import SwiftUI

// struct와 class에서의 observable object 실험입니다.

struct StatePractice: View {
    
    @State var wordsViewModel: WordsViewModelstpr
    @State var wordsViewModelClass: WordsViewModelstpr2
    @StateObject var wordsViewModelClassWithObservable: WordsViewModelstpr3
    @StateObject var wordsViewModelClassWithObservablePublished: WordsViewModelstpr4
    @State var numberToGet:String = ""
    
    var body: some View {
        //struct 는 value type 이므로 값을 바꾸면 자체가 바뀐것인데, class 는 ref type 이므로 view가 value type에 의해 update 되지 않는 이상 update안됨. class에 observableObject protol을 씌워도 @Published 프로퍼티 없으면 마찬가지이다.
        VStack(alignment: .leading) {
            Text("Struct")
            VStack { //얘가 없으면 숫자와 토글버튼의 alignment 가 중앙.
                Button {
                    wordsViewModel.number += 1
                } label: {
                    Text("\(wordsViewModel.number)")
                }
                Button {
                    wordsViewModel.toggleValue.toggle()
                } label: {
                    Text("toggle")
                }
            }.frame(maxWidth: .infinity)
            Rectangle()
                .frame(height:3)
            VStack(alignment: .leading) {
                Text("just class")
                VStack {
                    Button {
                        wordsViewModelClass.number += 1
                    } label: {
                        Text("\(wordsViewModelClass.number)")
                    }
                    Button {
                        wordsViewModelClass.toggleValue.toggle()
                    } label: {
                        Text("toggle")
                    }.frame(maxWidth: .infinity)
                }
                Rectangle()
                    .frame(height:3)
            }
            VStack(alignment: .leading) {
                Text("observable class")
                VStack {
                    Button {
                        wordsViewModelClassWithObservable.number += 1
                    } label: {
                        Text("\(wordsViewModelClassWithObservable.number)")
                    }
                    Button {
                        wordsViewModelClassWithObservable.toggleValue.toggle()
                    } label: {
                        Text("toggle")
                    }.frame(maxWidth: .infinity)
                }
                Rectangle()
                    .frame(height:3)
            }
            VStack(alignment: .leading) {
                Text("Published + observable class")
                VStack {
                    Button {
                        wordsViewModelClassWithObservablePublished.number += 1
                    } label: {
                        Text("\(wordsViewModelClassWithObservablePublished.number)")
                    }
                    Button {
                        wordsViewModelClassWithObservablePublished.toggleValue.toggle()
                    } label: {
                        Text("toggle")
                    }.frame(maxWidth: .infinity)
                }
                Rectangle()
                    .frame(height:3)
            }
        }
        .padding()
    }
}

class WordsViewModelstpr3: ObservableObject {
    var toggleValue: Bool = false
    var number: Int = 0
}
class WordsViewModelstpr2 {
    var toggleValue: Bool = false
    var number: Int = 0
}
class WordsViewModelstpr4: ObservableObject {
    @Published var toggleValue: Bool = false
    @Published var number: Int = 0
}

struct WordsViewModelstpr {
    
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


struct struct_class_observable_Previews: PreviewProvider {
    static var previews: some View {
        StatePractice(wordsViewModel: WordsViewModelstpr([""]), wordsViewModelClass: WordsViewModelstpr2(), wordsViewModelClassWithObservable: WordsViewModelstpr3(), wordsViewModelClassWithObservablePublished: WordsViewModelstpr4())
    }
}

