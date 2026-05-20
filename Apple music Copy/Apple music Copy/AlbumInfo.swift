//
//  AlbumInfo.swift
//  Apple music Copy
//
//  Created by Jaebin Ahn on 4/7/26.
//

import SwiftUI

struct AlbumInfo: View {
    var body: some View {
        HStack {
            Image("album cover")
                .resizable()
                .scaledToFit()
                .cornerRadius(15)
                .frame(width: 100)
                .shadow(radius: 20)
            ScrollView(.horizontal)
            {
                VStack(alignment: .leading){
                    Text("F1")
                        .font(.title3)
                        .bold()
                    Text("Brian Tyler")
                        .font(.body)
                        
                }.padding(20)
            }
            Spacer()
            
            Button{
                
            }
            label : {
                Image(systemName: "star")
                    .font(.system(size: 25))
                    .foregroundStyle(.gray)
                    
            }.padding()
            
            Spacer()

            Menu {
                popup()
            }
            label : {
                Image(systemName: "ellipsis")
                    .font(.system(size: 25))
                    .foregroundStyle(Color.gray)
            }.padding()
                
        }
    }
}

#Preview {
    AlbumInfo()
}
