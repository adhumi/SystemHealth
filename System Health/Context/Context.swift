import Foundation

class Context {
    let cpuMonitor = CPUMonitor()
    let ramMonitor = RAMMonitor()
    let batteryMonitor = BatteryMonitor()

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
