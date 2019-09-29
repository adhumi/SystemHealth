import Foundation

class Context {
    let cpuMonitor = CPUMonitor()
    let ramMonitor = RAMMonitor()
    let batteryMonitor = BatteryMonitor()

    let settingsStore = SettingsStore()

    init() {
        cpuMonitor.checkStatus = { [weak self] (report, previousReport) in
            guard let self = self else { return .none }
            guard let alertingPreferences = self.settingsStore.preferences["cpu"] else { return .none }
            guard alertingPreferences.active else { return .none }

            if report.user >= alertingPreferences.threshold && previousReport.user < alertingPreferences.threshold {
                return .reached
            } else if alertingPreferences.cooldownAlert && report.user < alertingPreferences.threshold && previousReport.user >= alertingPreferences.threshold {
                return .cooldown
            }
            return .none
        }
        ramMonitor.checkStatus = { [weak self] (report, previousReport) in
            guard let self = self else { return .none }
            guard let alertingPreferences = self.settingsStore.preferences["ram"] else { return .none }
            guard alertingPreferences.active else { return .none }

            if report.usage >= alertingPreferences.threshold && previousReport.usage < alertingPreferences.threshold {
                return .reached
            } else if alertingPreferences.cooldownAlert && report.usage < alertingPreferences.threshold && previousReport.usage >= alertingPreferences.threshold {
                return .cooldown
            }
            return .none
        }
        batteryMonitor.checkStatus = { [weak self] (report, previousReport) in
            guard let self = self else { return .none }
            guard let alertingPreferences = self.settingsStore.preferences["battery"] else { return .none }
            guard alertingPreferences.active else { return .none }

            if report.level < alertingPreferences.threshold && previousReport.level >= alertingPreferences.threshold {
                return .reached
            } else if alertingPreferences.cooldownAlert && report.level >= alertingPreferences.threshold && previousReport.level < alertingPreferences.threshold {
                return .cooldown
            }
            return .none
        }
    }

    func startMonitoring() {
        cpuMonitor.start()
        ramMonitor.start()
        batteryMonitor.start()
    }

    func stopMonitoring() {
        cpuMonitor.stop()
        ramMonitor.stop()
        batteryMonitor.stop()
    }
}
