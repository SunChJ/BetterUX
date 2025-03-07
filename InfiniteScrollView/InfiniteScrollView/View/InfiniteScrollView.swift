//
//  InfiniteScrollView.swift
//  InfiniteScrollView
//
//  Created by SamsonCJ on 2025/2/25.
//

import SwiftUI

#if os(iOS)
fileprivate struct InfiniteScrollHelper: UIViewRepresentable {
    
    @Binding var contentSize: CGSize
    @Binding var declarationRate: UIScrollView.DecelerationRate
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(declarationRate: declarationRate, contentSize: contentSize)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if let scrollView = view.scrollView {
                context.coordinator.defaultDelegate = scrollView.delegate
                scrollView.decelerationRate = declarationRate
                scrollView.delegate = context.coordinator
            }
            
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.declarationRate = declarationRate
        context.coordinator.contentSize = contentSize
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var declarationRate: UIScrollView.DecelerationRate
        var contentSize: CGSize
        
        
        init(declarationRate: UIScrollView.DecelerationRate, contentSize: CGSize) {
            self.declarationRate = declarationRate
            self.contentSize = contentSize
        }
        
        weak var defaultDelegate: UIScrollViewDelegate?
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
            scrollView.decelerationRate = declarationRate
            
            let minX = scrollView.contentOffset.x
            if minX > contentSize.width {
                scrollView.contentOffset.x -= contentSize.width
            }
            if minX < 0 {
                scrollView.contentOffset.x += contentSize.width
            }
            
            defaultDelegate?.scrollViewDidScroll?(scrollView)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            defaultDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            defaultDelegate?.scrollViewDidEndDecelerating?(scrollView)
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            defaultDelegate?.scrollViewWillBeginDragging?(scrollView)
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            defaultDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
}

extension UIView {
    var scrollView: UIScrollView? {
        if let superview, superview is UIScrollView {
            return superview as? UIScrollView
        }
        
        return superview?.scrollView
    }
}
#elseif os(macOS)
fileprivate struct InfiniteScrollHelper: NSViewRepresentable {
    @Binding var contentSize: CGSize
    @Binding var declarationRate: NSScrollView.DecelerationRate
    
    func makeCoordinator() -> Coordinator {
        Coordinator(declarationRate: declarationRate, contentSize: contentSize)
    }
    
    func makeNSView(context: Context) -> some NSView {
        let view = NSView(frame: .zero)
        view.wantsLayer = true
        
        DispatchQueue.main.async {
            if let scrollView = view.scrollView {
                context.coordinator.scrollView = scrollView
                // 设置滚动监听
                NotificationCenter.default.addObserver(
                    context.coordinator,
                    selector: #selector(Coordinator.scrollViewDidScroll(_:)),
                    name: NSView.boundsDidChangeNotification,
                    object: scrollView.contentView
                )
                
                // 设置减速率
                scrollView.horizontalScrollElasticity = .none
                
                // 启用鼠标拖动
                let panGesture = NSPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
                scrollView.documentView?.addGestureRecognizer(panGesture)
            }
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        context.coordinator.declarationRate = declarationRate
        context.coordinator.contentSize = contentSize
    }
    
    class Coordinator: NSObject {
        var declarationRate: NSScrollView.DecelerationRate
        var contentSize: CGSize
        weak var scrollView: NSScrollView?
        private var startPoint: NSPoint = .zero
        
        init(declarationRate: NSScrollView.DecelerationRate, contentSize: CGSize) {
            self.declarationRate = declarationRate
            self.contentSize = contentSize
            super.init()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc func scrollViewDidScroll(_ notification: Notification) {
            guard let scrollView = scrollView else { return }
            
            // 处理无限滚动逻辑
            let minX = scrollView.contentView.bounds.origin.x
            if minX > contentSize.width {
                scrollView.contentView.scroll(to: NSPoint(x: minX - contentSize.width, y: scrollView.contentView.bounds.origin.y))
                scrollView.reflectScrolledClipView(scrollView.contentView)
            }
            if minX < 0 {
                scrollView.contentView.scroll(to: NSPoint(x: minX + contentSize.width, y: scrollView.contentView.bounds.origin.y))
                scrollView.reflectScrolledClipView(scrollView.contentView)
            }
        }
        
        // 处理鼠标拖动手势
        @objc func handlePanGesture(_ gestureRecognizer: NSPanGestureRecognizer) {
            guard let scrollView = scrollView else { return }
            
            switch gestureRecognizer.state {
            case .began:
                // 记录开始位置
                startPoint = scrollView.contentView.bounds.origin
                
            case .changed:
                // 计算拖动距离
                let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
                
                // 更新滚动位置（注意：水平滚动时，向左拖动应该增加contentOffset.x）
                let newX = startPoint.x - translation.x
                scrollView.contentView.scroll(to: NSPoint(x: newX, y: startPoint.y))
                scrollView.reflectScrolledClipView(scrollView.contentView)
                
            case .ended, .cancelled:
                // 根据减速率设置滑动惯性
                let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
                let decelerationFactor: CGFloat = (declarationRate == .fast) ? 0.99 : 0.95
                
                // 简单模拟惯性滚动
                if abs(velocity.x) > 50 {
                    let direction: CGFloat = velocity.x > 0 ? -1 : 1
                    var currentVelocity = min(abs(velocity.x) * 0.2, 500) // 限制最大速度
                    
                    // 使用Timer创建减速效果
                    var timer: Timer?
                    timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] t in
                        guard let self = self, let scrollView = self.scrollView else {
                            timer?.invalidate()
                            return
                        }
                        
                        let currentX = scrollView.contentView.bounds.origin.x
                        let newX = currentX + direction * currentVelocity * 0.016
                        
                        scrollView.contentView.scroll(to: NSPoint(x: newX, y: scrollView.contentView.bounds.origin.y))
                        scrollView.reflectScrolledClipView(scrollView.contentView)
                        
                        // 应用减速
                        currentVelocity *= decelerationFactor
                        
                        // 当速度足够小时停止
                        if currentVelocity < 5 {
                            timer?.invalidate()
                        }
                    }
                }
                
            default:
                break
            }
        }
    }
}

extension NSView {
    var scrollView: NSScrollView? {
        if let superview, superview is NSScrollView {
            return superview as? NSScrollView
        }
        
        return superview?.scrollView
    }
}

// 为了兼容性，定义一个通用的减速率类型
extension NSScrollView {
    enum DecelerationRate {
        case normal
        case fast
    }
}
#endif

// 修改 InfiniteScrollView 结构体以支持跨平台
struct InfiniteScrollView<Content: View>: View {
    var spacing: CGFloat = 10
    @ViewBuilder var content: Content
    
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        GeometryReader {
            let size = $0.size
             
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    Group(subviews: content) { collection in
                        HStack(spacing: spacing) {
                            ForEach(collection) { view in
                                view
                                
                            }
                        }
                        .onGeometryChange(for: CGSize.self) { $0.size
                        } action: { newValue in
                            contentSize = .init(width: newValue.width, height: newValue.height)
                        }

                        let averageWidth = contentSize.width / CGFloat(collection.count)
                        let repeatingCount = contentSize.width > 0 ? Int((size.width / averageWidth).rounded()) + 1 : 1
                        
                        HStack(spacing: spacing) {
                            ForEach(0..<repeatingCount, id: \.self) { index in
                                let view = Array(collection)[index % collection.count]
                                view
                            }
                        }
                        
                    }
                }
                #if os(iOS)
                .background(InfiniteScrollHelper(contentSize: $contentSize, declarationRate: .constant(.fast)))
                #elseif os(macOS)
                .background(InfiniteScrollHelper(contentSize: $contentSize, declarationRate: .constant(.fast)))
                #endif
            }
        }
    }
}

#Preview {
    ContentView()
}
