import Foundation
import UserNotifications

class Context {
    let cpuMonitor = CPUMonitor()
    let ramMonitor = RAMMonitor()
    let batteryMonitor = BatteryMonitor()

    let settingsStore = SettingsStore()

    let store = CoreDataManager()

    private var thresholdsObservers: [NSObjectProtocol] = []

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

        setupThresholdsObservers()
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

    private func setupThresholdsObservers() {
        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: CPUMonitor.thresholdReachedNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? CPUMonitor.CPUReport else { return }

            _ = Alert(metric: "cpu", value: report.user, state: "reached", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()

            let title = "CPU usage above threshold"
            let message = String(format: "Value: %.2f\u{202f}%%", report.user * 100)
            self.sendNotification(title: title, message: message, report: report)
        })

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: CPUMonitor.thresholdCooldownNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? CPUMonitor.CPUReport else { return }

            _ = Alert(metric: "cpu", value: report.user, state: "cooldown", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()

            let title = "CPU usage back below threshold"
            let message = String(format: "Value: %.2f\u{202f}%%", report.user * 100)
            self.sendNotification(title: title, message: message, report: report)
        })

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: RAMMonitor.thresholdReachedNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? RAMMonitor.RAMReport else { return }

            _ = Alert(metric: "ram", value: report.usage, state: "reached", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()

            let title = "Memory usage above threshold"
            let message = String(format: "Value: %.2f\u{202f}%%", report.usage * 100)
            self.sendNotification(title: title, message: message, report: report)
        })

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: RAMMonitor.thresholdCooldownNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? RAMMonitor.RAMReport else { return }

            _ = Alert(metric: "ram", value: report.usage, state: "cooldown", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()

            let title = "Memory usage back below threshold"
            let message = String(format: "Value: %.2f\u{202f}%%", report.usage * 100)
            self.sendNotification(title: title, message: message, report: report)
        })

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: BatteryMonitor.thresholdReachedNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? BatteryMonitor.BatteryReport else { return }
            _ = Alert(metric: "battery", value: report.level, state: "reached", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()

            let title = "Battery level below threshold"
            let message = String(format: "Value: %.f\u{202f}%%", report.level * 100)
            self.sendNotification(title: title, message: message, report: report)
        })

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: CPUMonitor.thresholdCooldownNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? BatteryMonitor.BatteryReport else { return }
            _ = Alert(metric: "battery", value: report.level, state: "cooldown", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()

            let title = "Battery level back above threshold"
            let message = String(format: "Value: %.f\u{202f}%%", report.level * 100)
            self.sendNotification(title: title, message: message, report: report)
        })
    }

    func sendNotification(title: String, message: String, report: Report) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "fr.adhumi.SystemHealth.\(Int(report.timestamp))", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
}
