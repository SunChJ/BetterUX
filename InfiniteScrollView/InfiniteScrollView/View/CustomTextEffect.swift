//
//  CustomTextEffect.swift
//  InfiniteScrollView
//
//  Created by SamsonCJ on 2025/2/25.
//

import SwiftUI

struct TitleTextRenderer: TextRenderer, Animatable {
    var progress: CGFloat
    var aniamtionData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        let slices = layout.flatMap({ $0 }).flatMap({ $0 })
        
        for (index, slice) in slices.enumerated() {
            let sliceProgressIndex = CGFloat(slice.count) * progress
            let sliceProgress = max(min(sliceProgressIndex / CGFloat(index + 1), 1), 0)
            
            ctx.addFilter(.blur(radius: 5 - (5 * sliceProgress)))
            ctx.opacity = sliceProgress
            ctx.translateBy(x: 0, y: 5 - (5 * sliceProgress))
            ctx.draw(slice, options: .disablesSubpixelQuantization)
        }
    }
}

//struct WaveTextRenderer: TextRenderer, Animatable {
//    var progress: CGFloat // 控制波浪的动画进度
//    var amplitude: CGFloat // 波浪的振幅
//    var frequency: CGFloat // 波浪的频率
//
//    var animatableData: CGFloat {
//        get { progress }
//        set { progress = newValue }
//    }
//
//    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
//        let slices = layout.flatMap { $0 }.flatMap { $0 }
//        var currentX: CGFloat = 0
//
//        for slice in slices {
//            // 测量当前文字片段的尺寸
//            let sliceSize = ctx.measure(slice)
//
//            // 计算当前文字的波浪偏移量
//            let waveOffset = sin((currentX / layout.totalWidth) * frequency + progress * 2 * .pi) * amplitude
//
//            // 绘制文字，并应用波浪偏移
//            ctx.translateBy(x: 0, y: waveOffset)
//            ctx.draw(slice, options: .disablesSubpixelQuantization)
//            ctx.translateBy(x: 0, y: -waveOffset) // 恢复上下文状态
//
//            currentX += sliceSize.width
//        }
//    }
//}
//

//struct BlurAttribute: TextAttribute {
//    let radius: CGFloat
//}
//
//struct BlurEffect: TextRenderer {
//    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
//        let runs = layout.flatMap({$0}).flatMap({$0})
//        // 遍历每个 run
//        for run in runs {
//            // 检查是否应用了 BlurAttribute
//            if let blurAttribute = run.attributes[BlurAttribute.self] {
//                // 创建一个新的上下文并应用模糊效果
//                var blurContext = ctx
//                blurContext.addFilter(.blur(radius: blurAttribute.radius))
//                blurContext.draw(run)
//            } else {
//                // 如果没有应用模糊效果，直接绘制
//                ctx.draw(run)
//            }
//        }
//    }
//
//}

