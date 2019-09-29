import UIKit

class DashboardHeaderView: UITableViewHeaderFooterView {
    var viewModel: DashboardHeaderVM?

    let cpuUsedLabel = UILabel()
    let cpuIdleLabel = UILabel()

    let ramFreeLabel = UILabel()
    let ramActiveLabel = UILabel()
    let ramInactiveLabel = UILabel()
    let ramWiredLabel = UILabel()
    let ramUsageLabel = UILabel()

    let batteryLevelLabel = UILabel()
    let batteryStateLabel = UILabel()

    private var timer: CADisplayLink?

    private let font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let stackView = UIStackView(arrangedSubviews: [cpuStackView, ramStackView, batteryStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    private var cpuStackView: UIStackView {
        let stackView = columnStackView

        cpuUsedLabel.font = font
        cpuUsedLabel.text = "User:"
        stackView.addArrangedSubview(cpuUsedLabel)

        cpuIdleLabel.font = font
        cpuIdleLabel.text = "Idle:"
        stackView.addArrangedSubview(cpuIdleLabel)

        return stackView
    }

    private var ramStackView: UIStackView {
        let stackView = columnStackView

        ramActiveLabel.font = font
        ramActiveLabel.text = "Active:"
        stackView.addArrangedSubview(ramActiveLabel)

        ramWiredLabel.font = font
        ramWiredLabel.text = "Wired:"
        stackView.addArrangedSubview(ramWiredLabel)

        ramInactiveLabel.font = font
        ramInactiveLabel.text = "Inactive:"
        stackView.addArrangedSubview(ramInactiveLabel)

        ramFreeLabel.font = font
        ramFreeLabel.text = "Free:"
        stackView.addArrangedSubview(ramFreeLabel)

        ramUsageLabel.font = font
        ramUsageLabel.text = "Usage:"
        stackView.addArrangedSubview(ramUsageLabel)

        return stackView
    }

    private var batteryStackView: UIStackView {
        let stackView = columnStackView

        batteryLevelLabel.font = font
        batteryLevelLabel.text = "Level:"
        stackView.addArrangedSubview(batteryLevelLabel)

        batteryStateLabel.font = font
        batteryStateLabel.text = "State:"
        stackView.addArrangedSubview(batteryStateLabel)

        return stackView
    }

    private var columnStackView: UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        return stackView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: DashboardHeaderVM) {
        self.viewModel = viewModel
        self.viewModel?.updateCPUState = { [weak self] report in
            self?.updateCPU(report)
        }
        self.viewModel?.updateRAMState = { [weak self] report in
            self?.updateRAM(report)
        }
        self.viewModel?.updateBatteryState = { [weak self] report in
            self?.updateBattery(report)
        }

        viewModel.lastCPUReport.map { updateCPU($0) }
        viewModel.lastRAMReport.map { updateRAM($0) }
        viewModel.lastBatteryReport.map { updateBattery($0) }
    }

    func updateCPU(_ report: CPUMonitor.CPUReport) {
        cpuUsedLabel.text = String(format: "User: %.2f\u{202f}%%", report.user * 100)
        cpuIdleLabel.text = String(format: "Idle: %.2f\u{202f}%%", report.idle * 100)
    }

    func updateRAM(_ report: RAMMonitor.RAMReport) {
        ramActiveLabel.text = String(format: "Active: %.2f\u{00a0}Gb", report.active)
        ramWiredLabel.text = String(format: "Wired: %.2f\u{00a0}Gb", report.wired)
        ramInactiveLabel.text = String(format: "Inactive: %.2f\u{00a0}Gb", report.inactive)
        ramFreeLabel.text = String(format: "Free: %.2f\u{00a0}Gb", report.free)
        ramUsageLabel.text = String(format: "Usage: %.f\u{202f}%%", report.usage * 100)
    }

    func updateBattery(_ report: BatteryMonitor.BatteryReport) {
        batteryLevelLabel.text = String(format: "Level: %.f\u{202f}%%", report.level * 100)
        batteryStateLabel.text = "State: \(report.state.readableValue)"
    }
}
