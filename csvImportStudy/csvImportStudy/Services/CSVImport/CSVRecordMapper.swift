//
//  CSVRecordMapper.swift
//  csvImportStudy
//
//  Created by Jaebin Ahn on 8/20/26.
//
// SwiftData로 스키마가 구상된 importedRecord의 내용으로 저장할 수 있도록 함

import Foundation

struct CSVRecordMapper {
    func map(
        row: ParsedCSVRow,
        sourceFileName: String
    ) throws -> ImportedRecord { // 여기서 throws는 왜 들어가는거지?
        // 답변: 나이/키 변환 중 잘못된 값이 있으면 에러를 던질 수 있기 때문. 내부에서 try optionalInt, try optionalDouble을 호출하므로 이 함수도 throws가 필요.
        let realName = optionalString(
            row.values["본명"]
        )

        let name = optionalString(
            row.values["이름"]
        )

        let gender = optionalString(
            row.values["성별"]
        )

        let age = try optionalInt(   // 여기서 try의 의미는?
            // 답변: optionalInt가 실패할 수 있는 throwing 함수라서 try가 필요. 변환 실패 시 여기서 멈추고 map을 호출한 쪽의 catch로 에러가 전달됨.
            // throwing 함수: 실행 중 에러를 던질수도 있는 함수
            row.values["나이"],
            rowNumber: row.rowNumber,
            columnName: "나이"
        )

        let height = try optionalDouble(
            row.values["키"],
            rowNumber: row.rowNumber,
            columnName: "키"
        )

        return ImportedRecord(
            realName: realName,
            name: name,
            gender: gender,
            age: age,
            height: height,
            sourceFileName: sourceFileName,
            sourceRowNumber: row.rowNumber
        )
    }
    
    /// 매개변수 입력 시 _를 써서 함수의 실사용에서 어떤 변수인지 명시를 생략하는 이유는?
    /// 답변: 첫 번째 값 자체가 함수 이름 optionalString과 함께 읽혀서 라벨이 없어도 의미가 충분하기 때문. optionalString(value:)보다 optionalString(value)가 더 자연스러운 호출.
    private func optionalString(_ value: String? ) -> String? {
        guard let value else {
            return nil
        }

        let trimmedValue = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedValue.isEmpty else {
            return nil
        }

        return trimmedValue
    }
    
    private func optionalInt(
        _ value: String?,
        rowNumber: Int,
        columnName: String
    ) throws -> Int? { // 이 구문의 의미는?
                       // 답변: 이 함수는 에러를 던질 수 있고, 성공해도 Int 값이 없을 수 있다는 뜻. 빈 값이면 nil, 숫자로 변환 불가능한 값이면 throw.
        
        guard let text = optionalString(value) else {
            return nil
        }
        
        // guard let에서 만약 변수가 nil이면 어떻게 되는거지? 에러메시지를 반환하는가 아니면 그냥 nil을 넣는가
        // 답변: 이 guard의 nil은 Int(text) 변환 실패를 의미하므로 nil을 넣지 않고 에러를 던짐. 위의 optionalString(value)가 nil일 때만 정상적으로 nil을 반환.
        guard let number = Int(text) else {
            throw CSVImportError.invalidValue(
                row: rowNumber,
                column: columnName,
                value: text,
                expectedType: "Int"
            )
        }

        return number
    }
    
    private func optionalDouble(
        _ value: String?,
        rowNumber: Int,
        columnName: String
    ) throws -> Double? {
        guard let text = optionalString(value) else {
            return nil
        }

        guard let number = Double(text) else {
            throw CSVImportError.invalidValue(
                row: rowNumber,
                column: columnName,
                value: text,
                expectedType: "Double"
            )
        }

        return number
    }
}
