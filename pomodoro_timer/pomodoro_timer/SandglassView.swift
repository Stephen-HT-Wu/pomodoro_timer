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
            // 沙漏外框（使用真實的沙漏形狀）
            SandglassShape(
                topWidth: topWidth,
                bottomWidth: bottomWidth,
                neckWidth: neckWidth,
                neckY: neckY
            )
            .stroke(Color.primary.opacity(0.3), lineWidth: 2)
            .frame(width: sandglassWidth, height: sandglassHeight)
            
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

// 上半部分沙子視圖（從底部向上填充）
struct TopSandView: View {
    let containerHeight: CGFloat
    let height: CGFloat
    let topWidth: CGFloat
    let neckWidth: CGFloat
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            // 沙子填充，使用漸變模擬真實沙子的質感
            // 從容器底部開始向上填充
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.95),
                            color.opacity(0.85),
                            color.opacity(0.75)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: max(height, 0))
        }
    }
}

// 中間沙子流動視圖（模擬沙子落下的效果）
struct SandFlowView: View {
    let neckWidth: CGFloat
    let sandglassHeight: CGFloat
    let neckY: CGFloat
    let color: Color
    
    @State private var particleOffset: CGFloat = 0
    @State private var particleOpacity: Double = 1.0
    
    // 窄通道的中心位置（在 ZStack 中，y=0 是中心，所以需要調整）
    private var neckCenterY: CGFloat {
        // neckY = 0.5 表示中間，所以在 ZStack 中就是 y = 0
        return (neckY - 0.5) * sandglassHeight
    }
    
    var body: some View {
        ZStack {
            // 多個沙粒粒子，形成連續流動效果
            ForEach(0..<3, id: \.self) { index in
                // 單個沙粒
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.9))
                    .frame(width: neckWidth * 0.6, height: 4)
                    .offset(y: neckCenterY + particleOffset + CGFloat(index * 6))
                    .opacity(particleOpacity)
            }
        }
        .onAppear {
            // 循環動畫：粒子從上往下移動
            withAnimation(.linear(duration: 0.4).repeatForever(autoreverses: false)) {
                particleOffset = 15
            }
            
            // 閃爍效果，模擬沙粒落下
            withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
                particleOpacity = 0.7
            }
        }
    }
}

// 下半部分沙子視圖（簡化版，使用 clipShape 裁切）
struct BottomSandView: View {
    let containerHeight: CGFloat
    let height: CGFloat
    let bottomWidth: CGFloat
    let neckWidth: CGFloat
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            // 沙子填充，使用漸變模擬真實沙子的質感
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.75),
                            color.opacity(0.85),
                            color.opacity(0.95)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: max(height, 0))
        }
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
