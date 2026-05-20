//
//  bottom.swift
//  Apple music Copy
//
//  Created by Jaebin Ahn on 4/7/26.
//

import SwiftUI

struct bottom: View {
    var body: some View {
        HStack {
            Spacer()
            Button("", systemImage: "quote.bubble") {}
                .foregroundStyle(Color(.gray))
                .font(.title.bold())
            Spacer()
            Button("", systemImage: "airplay.audio") {}
                .foregroundStyle(Color(.gray))
                .font(.title)
            Spacer()
            Button("", systemImage: "list.bullet") {}
                .foregroundStyle(Color(.gray))
                .font(.title)
            Spacer()
        }
    }
}

#Preview {
    bottom()
}
