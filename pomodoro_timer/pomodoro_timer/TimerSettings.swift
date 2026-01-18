//
//  TimerSettings.swift
//  pomodoro_timer
//
//  計時器設置管理
//

import Foundation
import Combine

enum TimerViewStyle: String, CaseIterable {
    case circular = "circular"
    case sandglass = "sandglass"
    
    var displayName: String {
        switch self {
        case .circular:
            return "圓形進度條"
        case .sandglass:
            return "數位沙漏"
        }
    }
}

class TimerSettings: ObservableObject {
    static let shared = TimerSettings()
    
    private let defaults = UserDefaults.standard
    
    // UserDefaults keys
    private let workDurationKey = "workDurationMinutes"
    private let shortBreakKey = "shortBreakMinutes"
    private let longBreakKey = "longBreakMinutes"
    private let viewStyleKey = "timerViewStyle"
    
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
    
    @Published var viewStyle: TimerViewStyle {
        didSet {
            defaults.set(viewStyle.rawValue, forKey: viewStyleKey)
        }
    }
    
    private init() {
        // 從 UserDefaults 讀取設置，如果沒有則使用默認值
        self.workDurationMinutes = defaults.object(forKey: workDurationKey) as? Int ?? 25
        self.shortBreakMinutes = defaults.object(forKey: shortBreakKey) as? Int ?? 5
        self.longBreakMinutes = defaults.object(forKey: longBreakKey) as? Int ?? 15
        
        // 讀取視圖樣式
        if let styleString = defaults.string(forKey: viewStyleKey),
           let style = TimerViewStyle(rawValue: styleString) {
            self.viewStyle = style
        } else {
            self.viewStyle = .circular // 默認使用圓形視圖
        }
    }
    
    func resetToDefaults() {
        workDurationMinutes = 25
        shortBreakMinutes = 5
        longBreakMinutes = 15
    }
}
