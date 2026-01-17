//
//  SoundManager.swift
//  PomodoroTimer
//
//  音效管理器
//

import Foundation
import AVFoundation
import UIKit

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    // 設置音頻會話
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音頻會話設置失敗: \(error.localizedDescription)")
        }
    }
    
    // 播放系統音效
    func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    // 播放開始音效
    func playStartSound() {
        // 使用系統音效：Tink (1057)
        AudioServicesPlaySystemSound(1057)
    }
    
    // 播放完成音效
    func playCompletionSound() {
        // 使用系統音效：Fanfare (1025) 或 Anticipate (1020)
        AudioServicesPlaySystemSound(1025)
    }
    
    // 播放暫停音效
    func playPauseSound() {
        // 使用系統音效：Tink (1057)
        AudioServicesPlaySystemSound(1057)
    }
    
    // 播放重置音效
    func playResetSound() {
        // 使用系統音效：Tink (1057)
        AudioServicesPlaySystemSound(1057)
    }
    
    // 震動反饋
    func vibrate() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // 輕微震動
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // 中等震動
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
