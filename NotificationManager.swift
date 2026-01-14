//
//  NotificationManager.swift
//  PomodoroTimer
//
//  通知管理器
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // 請求通知權限
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知權限已授予")
            } else if let error = error {
                print("通知權限錯誤: \(error.localizedDescription)")
            }
        }
    }
    
    // 檢查通知權限狀態
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // 發送完成通知
    func sendCompletionNotification(sessionType: SessionType, completedPomodoros: Int) {
        let content = UNMutableNotificationContent()
        
        switch sessionType {
        case .work:
            content.title = "工作時間完成！"
            content.body = "你已完成 \(completedPomodoros) 個 Pomodoro，該休息了！"
            content.sound = .default
        case .shortBreak, .longBreak:
            content.title = "休息時間結束"
            content.body = "準備好開始新的工作階段了嗎？"
            content.sound = .default
        }
        
        content.badge = NSNumber(value: completedPomodoros)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoro_completion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("發送通知錯誤: \(error.localizedDescription)")
            }
        }
    }
    
    // 取消所有待處理的通知
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
