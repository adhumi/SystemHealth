import Foundation

class RAMMonitor: Monitor {
    struct RAMReport: Report {
        /// There are more data avalable in `vm_statistics64` but those as the most widely used when tracking RAM usage.
        let free: Double
        let active: Double
        let inactive: Double
        let wired: Double

        let pressure: Double

        let timestamp = NSDate().timeIntervalSince1970

        init(statistics: vm_statistics64) {
            self.free = Double(statistics.free_count)
            self.active = Double(statistics.active_count)
            self.inactive = Double(statistics.inactive_count)
            self.wired = Double(statistics.wire_count)

            /// Compute the Memory Pressure value, as displayed in macOS' Activity Monitor
            /// Source: https://github.com/beltex/SystemKit/blob/master/SystemKit/System.swift#L353
            let gigabyte: Double = pow(2, 30) // Convert from bytes to gigabytes
            self.pressure = Double(statistics.compressor_page_count) * Double(vm_kernel_page_size) / gigabyte
        }
    }

    private let refreshRate: TimeInterval = 1 // In seconds

    var history: [RAMReport] = []

    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(timeInterval: refreshRate, target: self, selector: #selector(checkRAM), userInfo: nil, repeats: true)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc
    private func checkRAM() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let statistics = try? RAMMonitor.memoryStatistics() {
                self?.store(statistics: statistics)
            }
        }
    }

    private func store(statistics: vm_statistics64) {
        let report = RAMReport(statistics: statistics)
        history.append(report)
        print(report)
    }
}

enum RAMMonitorErrors: Error {
    case invalidResult(code: Int32)
}

extension RAMMonitor {
    private static func memoryStatistics() throws -> vm_statistics64 {
        let hostCPULoadInfoCount = MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(hostCPULoadInfoCount)
        let info = vm_statistics64_t.allocate(capacity: 1)

        let result = info.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
        }

        let data = info.move()
        info.deallocate()

        if result != KERN_SUCCESS {
            throw RAMMonitorErrors.invalidResult(code: result)
        }

        return data
    }
}
