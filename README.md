# DesignPatterns

다양한 디자인 패턴을 학습하고,
그간 공부했던 사항들을 대입해 보았습니다.
with swiftui

generic


# 참고 영상: WWDC data essential
Where will the data come from -> source of truth

Source of truth -> properties maintain itself. 

Own : @State

Share, dependency : @Binding

ObservableObject protocol: publisher emit before any mutation.
When using observableObject, it means creating sourth of truth

Avoiding slow updates
1. Make view initialzation cheap -> stateobject 고려. Unnecessary heap allocation방지
2. Make body a pure function
3. Avoid assumptions

App 부분에 쓰면 App wide source of truth

Extended lifetime
아래도 마찬가지로 source of truth. Binding 가능
Scenestorage 꺼져도 남음.State처럼 사용
Appstorage. UserDefault를 이용한 global storage. Setting에 사용  

