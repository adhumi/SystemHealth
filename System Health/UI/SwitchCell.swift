import UIKit

class SwitchCell: UITableViewCell {
    private let switchView = UISwitch()

    var valueChanged: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        accessoryView = switchView
        switchView.addTarget(self, action: #selector(onSwitchValueChanged(_:)), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(value: Bool) {
        switchView.isOn = value
    }

    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        valueChanged?(sender.isOn)
    }
}
