//
//  ContentView.swift
//  SwiftData_Study
//
//  Created by Jaebin Ahn on 5/29/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @Query(sort: \Friend.birthday) private var friends: [Friend]      // SwiftData에 있는 영구 데이터를 modelcontext로 수정할 수 있도록 하는 것, @Query는 읽기 전담
                                                                      // (sort: \Friend.bithdaa) 는 List에 정렬될 인스턴스들의 정렬기준을 정해주는 것
    @Environment(\.modelContext) private var context                  // modelContext는 view와 모델 사이를 연결해주는 역할
    
    @State private var newName = ""
    @State private var newDate = Date.now
    
    var body: some View {
        NavigationStack {
            //List(friends, id: \.name) { friend in     // 구조체에서 사용할 때 id를 사용하기 위한 구성, 만약 동명이인이면 문제 발생했음
            List(friends) { friend in                   // SwiftData가 인스턴스 내부 식별자를 구분할 수 있어서 id 지정이 필요 없음
                VStack(alignment: .leading, spacing: 8) {
                    HStack {                                // 리스트 내 단일 객체당 표시할 내용
                        
                        if friend.isBirthdayToday {         // 클래스 내부 연산 프로퍼티에 따른 이미지 출력
                            Image(systemName: "birthday.cake")
                        }
                        
                        Text(friend.name)
                            .bold(friend.isBirthdayToday)   // 연산 프로퍼티의 값에 따른 설정 변경 여부
                        Spacer()
                        Text(friend.birthday, format: .dateTime.month(.wide).day().year())
                    }
                    
                    ForEach(friend.gifts) { gift in
                        HStack(spacing: 6) {
                            Image(systemName: "gift")
                            Text(gift.name)
                            
                            if !gift.memo.isEmpty {
                                Text(gift.memo)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .font(.caption)
                    }
                }
                
            }
            .navigationTitle("Birthdays")               // 리스트 상단에 해당 문구 출력
            .safeAreaInset(edge: .bottom) {             // 화면 바닥에 새로운 친구 입력을 위한 구역 지정, 이는 화면의 특정 사이드에 컨텐츠를 고정할 수 있다.
                VStack(alignment: .center, spacing: 20) {
                    Text("New birthday")
                        .font(.headline)
                    DatePicker(selection: $newDate,                           // 날짜를 선택할 수 있도록 만들어주는 컴포넌트
                               in: Date.distantPast...Date.now,               // 과거부터 현재 날짜까지만 고를 수 있도록
                               displayedComponents: .date) {                  // 화면에 표기할 데이터의 포맷: 날짜만
                            TextField("Name", text: $newName)                 // 날짜 선택 옆에 이름도 추가, newName 바인딩
                            .textFieldStyle(.roundedBorder)
                    }
                    Button("Save") {
                        let newFriend = Friend(name: newName, birthday: newDate)    // 앞에서 입력한 정보들을 새로운 객체로 저장
                        context.insert(newFriend)                                   // 새 변수에 저장한 인스턴스를 기존 배열에 추가 (클래스일 때)
                        newName = ""       // 변수들 초기화
                        newDate = .now
                    }
                    .bold()
                }
                .padding()
                .background(.bar) // 안전한 영역 구분을 위해 패딩과 bar
            }
            .task {               // View가 처음 나타날 때 자동으로 실행되는 수정자, View가 모두 준비 되었을 때 사용하겠다는 의미
                guard friends.isEmpty else { return }
                
                let vince = Friend(
                    name: "vince",
                    birthday: .now,
                    gifts: [
                        Gift(name: "Book", memo: "Birthday gift"),
                        Gift(name: "Coffee Beans")
                    ]
                )
                let asFriend = Friend(name: "as", birthday: Date(timeIntervalSince1970: 0))
                
                context.insert(vince)
                context.insert(asFriend)
            }
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Friend.self, Gift.self], inMemory: true) // Friend라는 모델 등록, inMemory true를 통해 앱이 종료되면 데이터를 날리겠다는 의미 (테스트용)
}
