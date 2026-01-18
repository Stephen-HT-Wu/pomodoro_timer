//
//  TimerSettings.swift
//  pomodoro_timer
//
//  計時器設置管理
//

import Foundation
import Combine

class TimerSettings: ObservableObject {
    static let shared = TimerSettings()
    
    private let defaults = UserDefaults.standard
    
    // UserDefaults keys
    private let workDurationKey = "workDurationMinutes"
    private let shortBreakKey = "shortBreakMinutes"
    private let longBreakKey = "longBreakMinutes"
    
    @Published var workDurationMinutes: Int {
        didSet {
            defaults.set(workDurationMinutes, forKey: workDurationKey)
        }
    }
    
    @Published var shortBreakMinutes: Int {
        didSet {
            defaults.set(shortBreakMinutes, forKey: shortBreakKey)
        }
    }
    
    @Published var longBreakMinutes: Int {
        didSet {
            defaults.set(longBreakMinutes, forKey: longBreakKey)
        }
    }
    
    private init() {
        // 從 UserDefaults 讀取設置，如果沒有則使用默認值
        self.workDurationMinutes = defaults.object(forKey: workDurationKey) as? Int ?? 25
        self.shortBreakMinutes = defaults.object(forKey: shortBreakKey) as? Int ?? 5
        self.longBreakMinutes = defaults.object(forKey: longBreakKey) as? Int ?? 15
    }
    
    func resetToDefaults() {
        workDurationMinutes = 25
        shortBreakMinutes = 5
        longBreakMinutes = 15
    }
}
