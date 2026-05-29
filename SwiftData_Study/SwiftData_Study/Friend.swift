//
//  Friend.swift
//  SwiftData_Study
//
//  Created by Jaebin Ahn on 5/29/26.
//

import Foundation
import SwiftData     // 앱을 껐다 켜도 데이터가 유지되기 위한 개념

@Model  // SwiftData가 관리할 수 있도록 swift class를 바꾸는 매크로
        // 매크로는 숨겨진 코드로, 특정 조건을 만족할때 까지 오류를 발생시킨다.
        // swift에선, class의 경우 built-in identity가 있으며 이 부분이 struct와의 차이점이다. 이 id가 앱 내부 모든 뷰를 거쳐 공유될 수 있는 요소이다.
class Friend {
    var name: String
    var birthday: Date
    
    init(name: String, birthday: Date) {   // class의 선언에선, 이 생성자가 필수이다. (구조체는 자동으로 생성함)
        self.name = name
        self.birthday = birthday
    }
        
    var isBirthdayToday: Bool {            // 연산 프로퍼티 생성
        Calendar.current.isDateInToday(birthday)
    }
}
