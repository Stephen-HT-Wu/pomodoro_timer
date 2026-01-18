//
//  SandglassView.swift
//  pomodoro_timer
//
//  數位沙漏視圖 - 真實沙漏外型和沙子流動效果
//

import SwiftUI

struct SandglassView: View {
    @ObservedObject var timer: PomodoroTimer
    let isWorkSession: Bool
    
    private let sandglassWidth: CGFloat = 200
    private let sandglassHeight: CGFloat = 380
    private let topWidth: CGFloat = 160  // 頂部寬度
    private let bottomWidth: CGFloat = 160  // 底部寬度
    private let neckWidth: CGFloat = 20   // 中間窄處寬度（更窄更真實）
    private let neckY: CGFloat = 0.5  // 中間位置（50%）
    
    // 平滑計算進度，避免跳動
    @State private var smoothProgress: Double = 0.0
    
    // 計算上下部分的高度（根據進度）
    private var topHeight: CGFloat {
        let containerHeight = sandglassHeight * 0.48  // 上半部分容器高度
        return containerHeight * CGFloat(1 - smoothProgress)
    }
    
    private var bottomHeight: CGFloat {
        let containerHeight = sandglassHeight * 0.48  // 下半部分容器高度
        return containerHeight * CGFloat(smoothProgress)
    }
    
    var body: some View {
        ZStack {
            // 沙漏外框（使用真實的沙漏形狀）- 添加 3D 玻璃質感
            ZStack {
                // 外層陰影（深層立體感）
                SandglassShape(
                    topWidth: topWidth,
                    bottomWidth: bottomWidth,
                    neckWidth: neckWidth,
                    neckY: neckY
                )
                .fill(Color.black.opacity(0.15))
                .offset(x: 3, y: 3)
                .blur(radius: 8)
                
                // 玻璃主體（更透明的玻璃質感）
                SandglassShape(
                    topWidth: topWidth,
                    bottomWidth: bottomWidth,
                    neckWidth: neckWidth,
                    neckY: neckY
                )
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.05),
                            Color.clear
                        ]),
                        center: UnitPoint(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                
                // 玻璃邊框（立體邊框效果）
                SandglassShape(
                    topWidth: topWidth,
                    bottomWidth: bottomWidth,
                    neckWidth: neckWidth,
                    neckY: neckY
                )
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.8),
                            Color.gray.opacity(0.5),
                            Color.black.opacity(0.3),
                            Color.gray.opacity(0.5),
                            Color.white.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                
                // 內層邊框（厚度感）
                SandglassShape(
                    topWidth: topWidth,
                    bottomWidth: bottomWidth,
                    neckWidth: neckWidth,
                    neckY: neckY
                )
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                .offset(x: -1, y: -1)
                
                // 高光效果（模擬玻璃反光和立體感）
                SandglassHighlightShape(
                    topWidth: topWidth,
                    bottomWidth: bottomWidth,
                    neckWidth: neckWidth,
                    neckY: neckY
                )
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.2),
                            Color.clear
                        ]),
                        center: UnitPoint(x: 0.25, y: 0.25),
                        startRadius: 0,
                        endRadius: 100
                    )
                )
            }
            .frame(width: sandglassWidth, height: sandglassHeight)
            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 3, y: 4)
            .shadow(color: Color.white.opacity(0.4), radius: 6, x: -2, y: -2)
            
            // 上半部分（剩餘時間）- 從頂部開始
            TopSandView(
                containerHeight: sandglassHeight * 0.48,
                height: topHeight,
                topWidth: topWidth,
                neckWidth: neckWidth,
                color: isWorkSession ? Color.blue : Color.green
            )
            .frame(width: sandglassWidth, height: sandglassHeight * 0.48)
            .clipShape(
                TopSandContainerShape(
                    topWidth: topWidth,
                    neckWidth: neckWidth,
                    neckY: neckY
                )
            )
            .offset(y: -(sandglassHeight / 2 - sandglassHeight * 0.48 / 2))
            
            // 中間通道 - 沙子流動效果（固定在中間窄通道位置）
            if timer.state == .running && smoothProgress > 0.01 && smoothProgress < 0.99 {
                SandFlowView(
                    neckWidth: neckWidth,
                    sandglassHeight: sandglassHeight,
                    neckY: neckY,
                    color: isWorkSession ? Color.blue : Color.green
                )
                .frame(width: sandglassWidth, height: sandglassHeight)
            }
            
            // 下半部分（已過時間）- 從窄通道下方開始
            BottomSandView(
                containerHeight: sandglassHeight * 0.48,
                height: bottomHeight,
                bottomWidth: bottomWidth,
                neckWidth: neckWidth,
                color: isWorkSession ? Color.blue : Color.green
            )
            .frame(width: sandglassWidth, height: sandglassHeight * 0.48)
            .clipShape(
                BottomSandContainerShape(
                    bottomWidth: bottomWidth,
                    neckWidth: neckWidth,
                    neckY: neckY
                )
            )
            .offset(y: (sandglassHeight / 2 - sandglassHeight * 0.48 / 2))
            
            // 時間文字顯示（中央，使用半透明背景提高可讀性）
            VStack(spacing: 4) {
                Text(timer.formattedTime)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .shadow(color: .white.opacity(0.8), radius: 2)
                
                Text(timer.state == .running ? "進行中" : timer.state == .paused ? "已暫停" : "準備就緒")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.systemBackground).opacity(0.7))
                    .blur(radius: 1)
            )
        }
        .frame(width: sandglassWidth, height: sandglassHeight)
        .onChange(of: timer.progress) { newValue in
            // 使用平滑插值減少跳動，但保持即時響應
            withAnimation(.linear(duration: 0.5)) {
                smoothProgress = newValue
            }
        }
        .onAppear {
            smoothProgress = timer.progress
        }
    }
}

// 沙漏外框形狀（更真實的沙漏外型）
struct SandglassShape: Shape {
    let topWidth: CGFloat
    let bottomWidth: CGFloat
    let neckWidth: CGFloat
    let neckY: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        let neckCenterY = height * neckY
        let neckHeight = height * 0.06  // 中間連接部分高度
        
        // 上半部分（倒梯形，使用直線但更真實的比例）
        path.move(to: CGPoint(x: (width - topWidth) / 2, y: 0))
        path.addLine(to: CGPoint(x: width - (width - topWidth) / 2, y: 0))
        path.addLine(to: CGPoint(x: centerX + neckWidth / 2, y: neckCenterY - neckHeight / 2))
        path.addLine(to: CGPoint(x: centerX - neckWidth / 2, y: neckCenterY - neckHeight / 2))
        path.closeSubpath()
        
        // 下半部分（正梯形）
        path.move(to: CGPoint(x: centerX - neckWidth / 2, y: neckCenterY + neckHeight / 2))
        path.addLine(to: CGPoint(x: centerX + neckWidth / 2, y: neckCenterY + neckHeight / 2))
        path.addLine(to: CGPoint(x: width - (width - bottomWidth) / 2, y: height))
        path.addLine(to: CGPoint(x: (width - bottomWidth) / 2, y: height))
        path.closeSubpath()
        
        return path
    }
}

// 上半部分容器形狀（用於 clipShape）
struct TopSandContainerShape: Shape {
    let topWidth: CGFloat
    let neckWidth: CGFloat
    let neckY: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        let neckCenterY = height * (neckY / 0.48)  // 調整比例
        let neckHeight = height * 0.12
        
        path.move(to: CGPoint(x: (width - topWidth) / 2, y: 0))
        path.addLine(to: CGPoint(x: width - (width - topWidth) / 2, y: 0))
        path.addLine(to: CGPoint(x: centerX + neckWidth / 2, y: neckCenterY))
        path.addLine(to: CGPoint(x: centerX - neckWidth / 2, y: neckCenterY))
        path.closeSubpath()
        
        return path
    }
}

// 下半部分容器形狀（用於 clipShape）
struct BottomSandContainerShape: Shape {
    let bottomWidth: CGFloat
    let neckWidth: CGFloat
    let neckY: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        
        path.move(to: CGPoint(x: centerX - neckWidth / 2, y: 0))
        path.addLine(to: CGPoint(x: centerX + neckWidth / 2, y: 0))
        path.addLine(to: CGPoint(x: width - (width - bottomWidth) / 2, y: height))
        path.addLine(to: CGPoint(x: (width - bottomWidth) / 2, y: height))
        path.closeSubpath()
        
        return path
    }
}

// 上半部分沙子視圖（從窄通道往上填充，減少時從頂部開始消失）
struct TopSandView: View {
    let containerHeight: CGFloat
    let height: CGFloat
    let topWidth: CGFloat
    let neckWidth: CGFloat
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width
            let frameHeight = geometry.size.height // 容器的總高度（從頂部到窄通道）
            let actualHeight = max(height, 0) // 沙子從窄通道往上填充的高度
            
            ZStack {
                // 錐形沙子（從窄通道往上填充，減少時頂部往下移動）
                TopSandConeShape(
                    containerWidth: frameWidth,
                    containerHeight: frameHeight,
                    sandHeight: actualHeight,
                    topWidth: topWidth,
                    neckWidth: neckWidth
                )
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.98),
                            color.opacity(0.92),
                            color.opacity(0.85),
                            color.opacity(0.78),
                            color.opacity(0.70)
                        ]),
                        center: UnitPoint(x: 0.5, y: 1.0), // 光源在下方（窄通道處）
                        startRadius: 0,
                        endRadius: frameWidth * 0.8
                    )
                )
                .shadow(color: Color.black.opacity(0.25), radius: 5, x: 2, y: 3)
                
                // 添加沙粒質感
                SandGrainPattern()
                    .blendMode(BlendMode.overlay)
                    .opacity(0.08)
                    .mask(
                        TopSandConeShape(
                            containerWidth: frameWidth,
                            containerHeight: frameHeight,
                            sandHeight: actualHeight,
                            topWidth: topWidth,
                            neckWidth: neckWidth
                        )
                    )
            }
        }
        .frame(height: containerHeight) // 固定容器高度
    }
}

// 上半部分沙子的錐形形狀（從窄通道往上填充，減少時頂部往下移動）
struct TopSandConeShape: Shape {
    let containerWidth: CGFloat
    let containerHeight: CGFloat
    let sandHeight: CGFloat
    let topWidth: CGFloat
    let neckWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let containerHeight = rect.height // 容器總高度（從頂部到窄通道，固定）
        let centerX = width / 2
        
        // 計算錐形（從窄通道往上填充）
        // 底部固定在窄通道處（容器底部，y = containerHeight，不變）
        let bottomY = containerHeight // 底部（窄通道處，固定不動，最後消失的地方）
        
        // 頂部會隨著沙子減少而往下移動
        // 當 sandHeight 減少時，topY 從容器頂部往下移動
        let topY = containerHeight - sandHeight // 頂部（隨著沙子減少而往下移動）
        
        // 底部寬度（窄通道處，較窄，固定不變）
        let bottomWidth = neckWidth
        
        // 頂部寬度（根據錐形角度和沙子高度計算）
        // 當沙子減少時，sandHeight 減少，頂部寬度也隨之變小
        let angle = CGFloat.pi / 6 // 約 30 度（自然堆積角度）
        let topWidthAtHeight = bottomWidth + (sandHeight * tan(angle) * 2)
        let currentTopWidth = min(topWidthAtHeight, topWidth)
        
        // 繪製錐形路徑（從窄通道往上形成錐形）
        // 底部較窄（窄通道，固定），頂部較寬（隨沙子減少而往下移動並變窄）
        // 當沙子減少時，bottomY 不變，但 topY 往下移動，所以從頂部開始消失
        path.move(to: CGPoint(x: centerX - bottomWidth / 2, y: bottomY))
        path.addLine(to: CGPoint(x: centerX + bottomWidth / 2, y: bottomY))
        path.addLine(to: CGPoint(x: centerX + currentTopWidth / 2, y: topY))
        path.addLine(to: CGPoint(x: centerX - currentTopWidth / 2, y: topY))
        path.closeSubpath()
        
        return path
    }
}

// 中間沙子流動視圖（模擬細細流下的沙子質地）
struct SandFlowView: View {
    let neckWidth: CGFloat
    let sandglassHeight: CGFloat
    let neckY: CGFloat
    let color: Color
    
    @State private var particleOffset: CGFloat = 0
    
    // 窄通道的中心位置（在 ZStack 中，y=0 是中心，所以需要調整）
    private var neckCenterY: CGFloat {
        return (neckY - 0.5) * sandglassHeight
    }
    
    var body: some View {
        ZStack {
            // 細沙粒流動效果 - 多個小粒子模擬細沙（3D 立體感）
            ForEach(0..<8, id: \.self) { index in
                // 細小沙粒（圓形，3D 立體球體）
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.98),
                                color.opacity(0.85),
                                color.opacity(0.65)
                            ]),
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 2
                        )
                    )
                    .frame(width: 2.8, height: 2.8)
                    .shadow(color: color.opacity(0.5), radius: 1, x: 0.5, y: 0.5)
                    .shadow(color: Color.black.opacity(0.3), radius: 0.5, x: -0.3, y: -0.3)
                    .offset(
                        x: CGFloat.random(in: -neckWidth*0.3...neckWidth*0.3),
                        y: neckCenterY + particleOffset + CGFloat(Double(index) * 3.5) - 12
                    )
                    .opacity(0.85 - Double(index) * 0.08)
                
                // 更小的沙粒粒子（3D 效果）
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.9),
                                color.opacity(0.6)
                            ]),
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 1.5
                        )
                    )
                    .frame(width: 1.8, height: 1.8)
                    .shadow(color: color.opacity(0.4), radius: 0.8, x: 0.3, y: 0.3)
                    .offset(
                        x: CGFloat.random(in: -neckWidth*0.25...neckWidth*0.25),
                        y: neckCenterY + particleOffset + CGFloat(Double(index) * 3.5) - 10 + 1.5
                    )
                    .opacity(0.7 - Double(index) * 0.06)
            }
            
            // 連續的沙流（細線條模擬細沙流，帶 3D 立體感）
            Path { path in
                let centerX: CGFloat = 0
                let startY = neckCenterY + particleOffset - 12
                let endY = neckCenterY + particleOffset + 12
                
                // 主要沙流（帶立體陰影）
                path.move(to: CGPoint(x: centerX, y: startY))
                path.addLine(to: CGPoint(x: centerX, y: endY))
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0.7),
                        color.opacity(0.6),
                        color.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 2
            )
            .shadow(color: color.opacity(0.3), radius: 1, x: 0.5, y: 0.5)
            
            // 兩側細流（立體效果）
            Path { path in
                let leftX: CGFloat = -neckWidth * 0.2
                let rightX: CGFloat = neckWidth * 0.2
                let startY = neckCenterY + particleOffset - 8
                let endY = neckCenterY + particleOffset + 8
                
                path.move(to: CGPoint(x: leftX, y: startY))
                path.addLine(to: CGPoint(x: leftX, y: endY))
                
                path.move(to: CGPoint(x: rightX, y: startY))
                path.addLine(to: CGPoint(x: rightX, y: endY))
            }
            .stroke(color.opacity(0.5), lineWidth: 1.2)
            .shadow(color: color.opacity(0.2), radius: 0.8, x: 0.3, y: 0.3)
        }
        .onAppear {
            // 平滑流動動畫：細沙連續流下
            withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: false)) {
                particleOffset = 20
            }
        }
    }
}

// 下半部分沙子視圖（錐形堆積效果，像真實沙漏一樣）
struct BottomSandView: View {
    let containerHeight: CGFloat
    let height: CGFloat
    let bottomWidth: CGFloat
    let neckWidth: CGFloat
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0) // 將沙子推到底部
            
            GeometryReader { geometry in
                let frameWidth = geometry.size.width
                let actualHeight = max(height, 0)
                
                ZStack {
                    // 錐形沙子堆積（從底部往上形成錐形小山丘）
                    BottomSandConeShape(
                        containerWidth: frameWidth,
                        containerHeight: actualHeight,
                        sandHeight: actualHeight,
                        bottomWidth: bottomWidth,
                        neckWidth: neckWidth
                    )
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.70),
                                color.opacity(0.78),
                                color.opacity(0.85),
                                color.opacity(0.92),
                                color.opacity(0.98)
                            ]),
                            center: UnitPoint(x: 0.5, y: 1.0), // 光源在底部（真實光照）
                            startRadius: 0,
                            endRadius: frameWidth * 0.9
                        )
                    )
                    .shadow(color: Color.black.opacity(0.25), radius: 5, x: -2, y: -3)
                    
                    // 添加沙粒質感
                    SandGrainPattern()
                        .blendMode(BlendMode.overlay)
                        .opacity(0.08)
                        .mask(
                            BottomSandConeShape(
                                containerWidth: frameWidth,
                                containerHeight: actualHeight,
                                sandHeight: actualHeight,
                                bottomWidth: bottomWidth,
                                neckWidth: neckWidth
                            )
                        )
                }
            }
            .frame(height: max(height, 0))
        }
    }
}

// 下半部分沙子的錐形形狀（從底部往上堆積成小山丘）
struct BottomSandConeShape: Shape {
    let containerWidth: CGFloat
    let containerHeight: CGFloat
    let sandHeight: CGFloat
    let bottomWidth: CGFloat
    let neckWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        
        // 計算錐形堆積（從底部往上堆積）
        let bottomY = height // 底部（容器底部，沙子堆積的起點）
        let topY = height - sandHeight // 頂部（錐形頂部，根據沙子高度計算）
        
        // 錐形頂部寬度（窄通道處，較窄）
        let topWidthAtHeight = neckWidth
        
        // 底部寬度（根據錐形角度計算，形成小山丘）
        // 使用自然堆積角度（約 30-35 度）
        let angle = CGFloat.pi / 6 // 約 30 度
        let calculatedBottomWidth = topWidthAtHeight + (sandHeight * tan(angle) * 2)
        let currentBottomWidth = min(calculatedBottomWidth, bottomWidth)
        
        // 繪製錐形路徑（從底部往上形成錐形，像小山丘一樣）
        // 底部是寬的（容器底部），頂部是窄的（靠近窄通道）
        path.move(to: CGPoint(x: centerX - currentBottomWidth / 2, y: bottomY))
        path.addLine(to: CGPoint(x: centerX + currentBottomWidth / 2, y: bottomY))
        path.addLine(to: CGPoint(x: centerX + topWidthAtHeight / 2, y: topY))
        path.addLine(to: CGPoint(x: centerX - topWidthAtHeight / 2, y: topY))
        path.closeSubpath()
        
        return path
    }
}

// 沙粒紋理圖案（模擬細沙的質感）- 使用簡單方式兼容所有 iOS 版本
struct SandGrainPattern: View {
    var body: some View {
        // 使用簡單的漸變紋理模擬沙粒質感（兼容 iOS 14+）
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .white.opacity(0.05), location: 0),
                .init(color: .clear, location: 0.3),
                .init(color: .white.opacity(0.08), location: 0.5),
                .init(color: .clear, location: 0.7),
                .init(color: .white.opacity(0.05), location: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blur(radius: 0.5)
    }
}

// 玻璃高光形狀（模擬玻璃反光效果）
struct SandglassHighlightShape: Shape {
    let topWidth: CGFloat
    let bottomWidth: CGFloat
    let neckWidth: CGFloat
    let neckY: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        
        // 高光區域（左上方的反光）
        // 上半部分高光
        path.move(to: CGPoint(x: centerX - topWidth * 0.2, y: height * 0.1))
        path.addCurve(
            to: CGPoint(x: centerX - neckWidth * 0.3, y: height * neckY * 0.7),
            control1: CGPoint(x: centerX - topWidth * 0.15, y: height * 0.3),
            control2: CGPoint(x: centerX - neckWidth * 0.4, y: height * neckY * 0.5)
        )
        path.addLine(to: CGPoint(x: centerX - topWidth * 0.3, y: height * neckY * 0.6))
        path.addLine(to: CGPoint(x: centerX - topWidth * 0.2, y: height * 0.1))
        
        return path
    }
}

#Preview {
    SandglassView(
        timer: PomodoroTimer(),
        isWorkSession: true
    )
    .frame(width: 300, height: 400)
    .padding()
}
