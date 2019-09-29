import Foundation

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
        })

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: CPUMonitor.thresholdCooldownNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? CPUMonitor.CPUReport else { return }
            _ = Alert(metric: "cpu", value: report.user, state: "cooldown", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()
        })

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: RAMMonitor.thresholdReachedNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? RAMMonitor.RAMReport else { return }
            _ = Alert(metric: "ram", value: report.usage, state: "reached", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()
        })

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: RAMMonitor.thresholdCooldownNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? RAMMonitor.RAMReport else { return }
            _ = Alert(metric: "ram", value: report.usage, state: "cooldown", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()
        })

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: BatteryMonitor.thresholdReachedNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? BatteryMonitor.BatteryReport else { return }
            _ = Alert(metric: "battery", value: report.level, state: "reached", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()
        })

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: CPUMonitor.thresholdCooldownNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self, let report = notification.object as? BatteryMonitor.BatteryReport else { return }
            _ = Alert(metric: "battery", value: report.level, state: "cooldown", date: Date(timeIntervalSince1970: report.timestamp), context: self.store.context)
            self.store.save()
        })
    }
}
