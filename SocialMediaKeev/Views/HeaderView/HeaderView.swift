//
//  HeaderView.swift
//  LadySocial
//
//  Created by KEEVIN MITCHELL on 2/5/23.
//

import SwiftUI

struct HeaderView: View {
    @State var currentType: String = "Popular"
    // MARK: For Smooth Sliding Effect
    @Namespace var animation
    var body: some View {
        // MARK: Header View
     
            GeometryReader{proxy in
                let minY = proxy.frame(in: .named("SCROLL")).minY
                let size = proxy.size
                let height = (size.height + minY)
                
                Image("LadySocialLogo1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width,height: height > 0 ? height : 0,alignment: .top)
                    .overlay(content: {
                        ZStack(alignment: .bottom) {
                            
                            // Dimming Out the text Content
                            LinearGradient(colors: [
                                .clear,
                                .black.opacity(0.8)
                            ], startPoint: .top, endPoint: .bottom)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                
                                Text("GOALS")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                
                                HStack(alignment: .bottom, spacing: 10) {
                                    Text("MARIA's Womens Acheivments")
                                        .font(.title.bold())
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .imageScale(.large)
                                        .foregroundColor(.teal)
                                        .background{
                                            Circle()
                                                .fill(.white)
                                                .padding(3)
                                        }
                                        //.position(x: 0, y: 50)
                                        
                                }
                                
                                Label {
                                 
                                    Text("Monthly Subscribers")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white.opacity(0.7))
                                } icon: {
                                    Text("6,000")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.teal)
                                }
                                .font(.caption)
                            }
                            .padding(.horizontal)
                            .padding(.bottom,25)
                            .frame(maxWidth: .infinity,alignment: .leading)
                        }
                    })
                    .cornerRadius(15)
                    .offset(y: -minY)
            }
            .frame(height: 250)
        }
        
        // MARK: Pinned Header
        @ViewBuilder
        func PinnedHeaderView()->some View{
            let types: [String] = ["Popular","Albums","Songs","Fans also like","About"]
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25){
                    
                    ForEach(types,id: \.self){type in
                        VStack(spacing: 12){
                            
                            Text(type)
                                .fontWeight(.semibold)
                                .foregroundColor(currentType == type ? .white : .gray)
                            
                            ZStack{
                                if currentType == type{
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(.white)
                                        .matchedGeometryEffect(id: "TAB", in: animation)
                                }
                                else{
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(.clear)
                                }
                            }
                            .padding(.horizontal,8)
                            .frame(height: 4)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut){
                                currentType = type
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top,25)
                .padding(.bottom,5)
            }
        }
    
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
