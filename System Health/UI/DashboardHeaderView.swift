import UIKit

class DashboardHeaderView: UITableViewHeaderFooterView {
    var viewModel: DashboardHeaderVM?

    let cpuUsedLabel = UILabel()
    let cpuIdleLabel = UILabel()

    private var timer: CADisplayLink?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let stackView = UIStackView(arrangedSubviews: [cpuStackView, columnStackView, columnStackView])
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

        cpuUsedLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        cpuUsedLabel.text = "Usage:"
        stackView.addArrangedSubview(cpuUsedLabel)

        cpuIdleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        cpuIdleLabel.text = "Idle:"
        stackView.addArrangedSubview(cpuIdleLabel)

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
            self?.cpuUsedLabel.text = String(format: "Usage: %.2f", report.user)
            self?.cpuIdleLabel.text = String(format: "Idle: %.2f", report.idle)
        }
    }
}
