//
//  ContentView.swift
//  PomodoroTimer
//
//  主視圖
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timer = PomodoroTimer()
    @StateObject private var settings = TimerSettings.shared
    @State private var hasRequestedNotification = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // 背景漸變
            LinearGradient(
                gradient: Gradient(colors: [
                    timer.currentSession == .work ? Color.blue.opacity(0.3) : Color.green.opacity(0.3),
                    Color.purple.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // 標題和設置按鈕
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                                .opacity(0.6)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }
                    
                    Text(timer.currentSession.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("已完成 \(timer.completedPomodoros) 個 Pomodoro")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // 根據設置顯示不同的視圖
                if settings.viewStyle == .circular {
                    // 圓形進度條視圖
                    CircularTimerView(timer: timer)
                } else {
                    // 數位沙漏視圖
                    SandglassView(
                        timer: timer,
                        isWorkSession: timer.currentSession == .work
                    )
                }
                
                Spacer()
                
                // 控制按鈕
                HStack(spacing: 20) {
                    // 重置按鈕
                    Button(action: {
                        timer.reset()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .disabled(timer.state == .idle)
                    
                    // 主要控制按鈕（開始/暫停）
                    Button(action: {
                        if timer.state == .running {
                            timer.pause()
                        } else {
                            timer.start()
                        }
                    }) {
                        Image(systemName: timer.state == .running ? "pause.fill" : "play.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(
                                timer.currentSession == .work ? Color.blue : Color.green
                            )
                            .clipShape(Circle())
                            .shadow(color: (timer.currentSession == .work ? Color.blue : Color.green).opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    
                    // 跳過按鈕
                    Button(action: {
                        timer.skip()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.orange.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .disabled(timer.state == .idle)
                }
                .padding(.bottom, 60)
            }
            .padding()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            // 應用啟動時請求通知權限
            if !hasRequestedNotification {
                NotificationManager.shared.requestAuthorization()
                hasRequestedNotification = true
            }
        }
    }
}

#Preview {
    ContentView()
}
