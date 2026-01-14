//
//  PomodoroTimer.swift
//  PomodoroTimer
//
//  Pomodoro Timer 核心邏輯模型
//

import Foundation
import Combine

enum TimerState {
    case idle
    case running
    case paused
    case completed
}

enum SessionType {
    case work
    case shortBreak
    case longBreak
    
    var duration: TimeInterval {
        switch self {
        case .work:
            return 25 * 60 // 25 分鐘
        case .shortBreak:
            return 5 * 60  // 5 分鐘
        case .longBreak:
            return 15 * 60 // 15 分鐘
        }
    }
    
    var title: String {
        switch self {
        case .work:
            return "工作時間"
        case .shortBreak:
            return "短休息"
        case .longBreak:
            return "長休息"
        }
    }
}

class PomodoroTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var state: TimerState = .idle
    @Published var currentSession: SessionType = .work
    @Published var completedPomodoros: Int = 0
    
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    
    var progress: Double {
        let total = currentSession.duration
        return 1.0 - (timeRemaining / total)
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func start() {
        guard state != .running else { return }
        
        if state == .paused {
            // 從暫停狀態恢復
            timeRemaining = pausedTime
        } else {
            // 新開始
            timeRemaining = currentSession.duration
        }
        
        state = .running
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        guard state == .running else { return }
        
        pausedTime = timeRemaining
        state = .paused
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        state = .idle
        timeRemaining = currentSession.duration
        pausedTime = 0
    }
    
    func skip() {
        timer?.invalidate()
        timer = nil
        state = .idle
        nextSession()
    }
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            completeSession()
        }
    }
    
    private func completeSession() {
        timer?.invalidate()
        timer = nil
        state = .completed
        
        if currentSession == .work {
            completedPomodoros += 1
        }
        
        // 自動進入下一個階段
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.nextSession()
        }
    }
    
    func nextSession() {
        state = .idle
        
        if currentSession == .work {
            // 完成工作後，每 4 個 Pomodoro 後長休息，否則短休息
            if completedPomodoros % 4 == 0 && completedPomodoros > 0 {
                currentSession = .longBreak
            } else {
                currentSession = .shortBreak
            }
        } else {
            // 休息結束後回到工作
            currentSession = .work
        }
        
        timeRemaining = currentSession.duration
        pausedTime = 0
    }
    
    deinit {
        timer?.invalidate()
    }
}
