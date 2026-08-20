//
//  ImportedRecord.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/20/26.
//

import Foundation
import SwiftData

@Model
final class ImportedRecord {  // final class는 더 상속이 안되도록 하는 개념인걸로 알고 있는데, 이 데이터 스키마에서 상속이 되지 않도록 하는 이유는?
    // 답변: SwiftData 모델은 저장 구조가 명확해야 해서 상속으로 속성/동작이 바뀌는 상황을 피하는 게 좋음. 이 앱에서는 ImportedRecord를 확장용 부모 클래스로 쓸 이유가 없어서 final로 고정.
    var realName: String?     // 이 자료형 뒤에 물음표는 왜 붙는거였지?
    // 답변: ?는 Optional 타입. CSV에서 해당 값이 비어 있거나 변환에 실패할 수 있으므로 String 값이 있거나 nil일 수 있다는 뜻.
    var name: String?
    var gender: String?
    var age: Int?
    var height: Double?
    
    var sourceFileName: String
    var sourceRowNumber: Int
    var importedAt: Date
    
    init(
        realName: String? = nil,
        name: String? = nil,
        gender: String? = nil,
        age: Int? = nil,
        height: Double? = nil,
        sourceFileName: String,
        sourceRowNumber: Int,
        importedAt: Date = .now
    ) {
        self.realName = realName
        self.name = name
        self.gender = gender
        self.age = age
        self.height = height

        self.sourceFileName = sourceFileName
        self.sourceRowNumber = sourceRowNumber
        self.importedAt = importedAt
    }
}
