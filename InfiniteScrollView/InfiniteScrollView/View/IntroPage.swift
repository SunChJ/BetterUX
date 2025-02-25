//
//  IntroPage.swift
//  InfiniteScrollView
//
//  Created by SamsonCJ on 2025/2/25.
//

import SwiftUI

struct IntroPage: View {
    @State private var activeCard: Card? = cards.first
    
    var body: some View {
        ZStack {
            AmbientBackground()
            
            VStack(spacing: 40) {
                InfiniteScrollView {
                    ForEach(cards) {
                        CarouselCardView($0)
                    }
                }
                .scrollIndicators(.hidden)
                .containerRelativeFrame(.vertical) {value, axis in
                    value  * 0.45
                    
                }
            }
            .safeAreaPadding(15)
        }
    }
    
    @ViewBuilder
    private func AmbientBackground() -> some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                ForEach(cards) { card in
                    Image(card.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .frame(width: size.width, height: size.height)
                        .opacity(activeCard?.id == card.id ? 1 : 0)
                }
                
                Rectangle()
                    .fill(.black.opacity(0.45))
                    .ignoresSafeArea()
            }
            .compositingGroup()
        }
    }
    
    @ViewBuilder
    private func CarouselCardView(_ card: Card) -> some View {
        GeometryReader {
            let size = $0.size
            
            Image(card.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipShape(.rect(cornerRadius: 20))
                .shadow(color: .black.opacity(0.4), radius: 10, x: 1 ,y : 0)
               
        }
        .frame(width: 220)
        .scrollTransition( .interactive.threshold(.centered), axis: .horizontal) { content, phase in
            content.offset(y: phase == .identity ? -10 : 0)
                .rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
            
        }
    }
}

#Preview {
    IntroPage()
}
