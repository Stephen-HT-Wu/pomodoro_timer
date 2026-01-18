//
//  PomodoroTimer.swift
//  PomodoroTimer
//
//  Pomodoro Timer 核心邏輯模型
//

import Foundation
import Combine
import UIKit

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
    
    func duration(settings: TimerSettings) -> TimeInterval {
        switch self {
        case .work:
            return TimeInterval(settings.workDurationMinutes * 60)
        case .shortBreak:
            return TimeInterval(settings.shortBreakMinutes * 60)
        case .longBreak:
            return TimeInterval(settings.longBreakMinutes * 60)
        }
    }
    
    // 為了向後兼容，保留一個默認的 duration（使用默認設置）
    var duration: TimeInterval {
        let settings = TimerSettings.shared
        return self.duration(settings: settings)
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
    private let notificationManager = NotificationManager.shared
    private let soundManager = SoundManager.shared
    private let settings = TimerSettings.shared
    private var settingsCancellable: AnyCancellable?
    
    var progress: Double {
        let total = currentSession.duration(settings: settings)
        return 1.0 - (timeRemaining / total)
    }
    
    init() {
        // 監聽設置變化，當設置改變時重置計時器（如果處於 idle 狀態）
        settingsCancellable = Publishers.CombineLatest3(
            settings.$workDurationMinutes,
            settings.$shortBreakMinutes,
            settings.$longBreakMinutes
        )
        .sink { [weak self] _ in
            guard let self = self, self.state == .idle else { return }
            self.timeRemaining = self.currentSession.duration(settings: self.settings)
        }
        
        // 初始化時間
        timeRemaining = currentSession.duration(settings: settings)
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
            timeRemaining = currentSession.duration(settings: settings)
        }
        
        state = .running
        startTime = Date()
        
        // 播放開始音效和震動
        soundManager.playStartSound()
        soundManager.lightImpact()
        
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
        
        // 播放暫停音效
        soundManager.playPauseSound()
        soundManager.lightImpact()
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        state = .idle
        timeRemaining = currentSession.duration(settings: settings)
        pausedTime = 0
        
        // 播放重置音效
        soundManager.playResetSound()
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
        
        // 播放完成音效和震動
        soundManager.playCompletionSound()
        soundManager.vibrate()
        
        // 發送通知
        notificationManager.sendCompletionNotification(
            sessionType: currentSession,
            completedPomodoros: completedPomodoros
        )
        
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
        
        timeRemaining = currentSession.duration(settings: settings)
        pausedTime = 0
    }
    
    deinit {
        timer?.invalidate()
    }
}
