//
//  SettingsView.swift
//  pomodoro_timer
//
//  設置界面
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = TimerSettings.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("計時器時間設置")) {
                    // 工作時間
                    HStack {
                        Text("工作時間")
                        Spacer()
                        Stepper(
                            value: $settings.workDurationMinutes,
                            in: 1...120,
                            step: 1
                        ) {
                            Text("\(settings.workDurationMinutes) 分鐘")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // 短休息時間
                    HStack {
                        Text("短休息")
                        Spacer()
                        Stepper(
                            value: $settings.shortBreakMinutes,
                            in: 1...60,
                            step: 1
                        ) {
                            Text("\(settings.shortBreakMinutes) 分鐘")
                                .foregroundColor(.green)
                        }
                    }
                    
                    // 長休息時間
                    HStack {
                        Text("長休息")
                        Spacer()
                        Stepper(
                            value: $settings.longBreakMinutes,
                            in: 1...120,
                            step: 1
                        ) {
                            Text("\(settings.longBreakMinutes) 分鐘")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Section(footer: Text("設置會自動保存。修改時間只會影響新的計時器，不會影響正在運行的計時。")) {
                    Button(action: {
                        settings.resetToDefaults()
                    }) {
                        HStack {
                            Spacer()
                            Text("恢復默認值")
                                .foregroundColor(.orange)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("設置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
