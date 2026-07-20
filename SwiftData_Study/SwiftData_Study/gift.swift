import Foundation
import SwiftData

@Model
final class Gift {
    var name: String
    var memo: String

    var friend: Friend?

    init(name: String, memo: String = "", friend: Friend? = nil) {
        self.name = name
        self.memo = memo
        self.friend = friend
    }
}
