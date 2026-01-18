//
//  CircularTimerView.swift
//  pomodoro_timer
//
//  圓形計時器視圖（從 ContentView 提取出來）
//

import SwiftUI

struct CircularTimerView: View {
    @ObservedObject var timer: PomodoroTimer
    
    var body: some View {
        ZStack {
            // 背景圓圈
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 280, height: 280)
            
            // 進度圓圈
            Circle()
                .trim(from: 0, to: timer.progress)
                .stroke(
                    timer.currentSession == .work ? Color.blue : Color.green,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timer.progress)
            
            // 時間文字
            VStack(spacing: 4) {
                Text(timer.formattedTime)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(timer.state == .running ? "進行中" : timer.state == .paused ? "已暫停" : "準備就緒")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    CircularTimerView(timer: PomodoroTimer())
}
