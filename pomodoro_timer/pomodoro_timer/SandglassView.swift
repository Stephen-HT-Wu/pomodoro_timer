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
            // 沙漏外框（使用真實的沙漏形狀）- 添加玻璃質感
            ZStack {
                // 玻璃主體（半透明填充）
                SandglassShape(
                    topWidth: topWidth,
                    bottomWidth: bottomWidth,
                    neckWidth: neckWidth,
                    neckY: neckY
                )
                .fill(Color.white.opacity(0.15))
                
                // 玻璃邊框（更明顯的邊緣）
                SandglassShape(
                    topWidth: topWidth,
                    bottomWidth: bottomWidth,
                    neckWidth: neckWidth,
                    neckY: neckY
                )
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.6),
                            Color.gray.opacity(0.4),
                            Color.white.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                
                // 高光效果（模擬玻璃反光）
                SandglassHighlightShape(
                    topWidth: topWidth,
                    bottomWidth: bottomWidth,
                    neckWidth: neckWidth,
                    neckY: neckY
                )
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
            }
            .frame(width: sandglassWidth, height: sandglassHeight)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 2, y: 2)
            .shadow(color: Color.white.opacity(0.3), radius: 4, x: -1, y: -1)
            
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

// 上半部分沙子視圖（從底部向上填充，添加真實沙質質感）
struct TopSandView: View {
    let containerHeight: CGFloat
    let height: CGFloat
    let topWidth: CGFloat
    let neckWidth: CGFloat
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            // 沙子填充，使用多層漸變模擬真實沙子的質感和顆粒感
            ZStack {
                // 主體沙子（帶質感漸變）
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.95),
                                color.opacity(0.88),
                                color.opacity(0.82),
                                color.opacity(0.75)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // 添加沙粒質感（細微紋理效果）
                SandGrainPattern()
                    .blendMode(BlendMode.overlay)
                    .opacity(0.1)
            }
            .frame(height: max(height, 0))
        }
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
            // 細沙粒流動效果 - 多個小粒子模擬細沙
            ForEach(0..<8, id: \.self) { index in
                // 細小沙粒（圓形，更真實）
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.95),
                                color.opacity(0.8)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 1.5
                        )
                    )
                    .frame(width: 2.5, height: 2.5)
                    .offset(
                        x: CGFloat.random(in: -neckWidth*0.3...neckWidth*0.3),
                        y: neckCenterY + particleOffset + CGFloat(index * 3.5) - 12
                    )
                    .opacity(0.85 - Double(index) * 0.08)
                
                // 更小的沙粒粒子
                Circle()
                    .fill(color.opacity(0.7))
                    .frame(width: 1.5, height: 1.5)
                    .offset(
                        x: CGFloat.random(in: -neckWidth*0.25...neckWidth*0.25),
                        y: neckCenterY + particleOffset + CGFloat(index * 3.5) - 10 + 1.5
                    )
                    .opacity(0.7 - Double(index) * 0.06)
            }
            
            // 連續的沙流（細線條模擬細沙流）
            Path { path in
                let centerX: CGFloat = 0
                let startY = neckCenterY + particleOffset - 12
                let endY = neckCenterY + particleOffset + 12
                
                // 主要沙流
                path.move(to: CGPoint(x: centerX, y: startY))
                path.addLine(to: CGPoint(x: centerX, y: endY))
            }
            .stroke(color.opacity(0.6), lineWidth: 1.5)
            
            // 兩側細流
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
            .stroke(color.opacity(0.4), lineWidth: 1)
        }
        .onAppear {
            // 平滑流動動畫：細沙連續流下
            withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: false)) {
                particleOffset = 20
            }
        }
    }
}

// 下半部分沙子視圖（添加真實沙質質感）
struct BottomSandView: View {
    let containerHeight: CGFloat
    let height: CGFloat
    let bottomWidth: CGFloat
    let neckWidth: CGFloat
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            // 沙子填充，使用多層漸變模擬真實沙子的質感
            ZStack {
                // 主體沙子（帶質感漸變）
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.75),
                                color.opacity(0.82),
                                color.opacity(0.88),
                                color.opacity(0.95)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // 添加沙粒質感（細微紋理效果）
                SandGrainPattern()
                    .blendMode(BlendMode.overlay)
                    .opacity(0.1)
            }
            .frame(height: max(height, 0))
        }
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
