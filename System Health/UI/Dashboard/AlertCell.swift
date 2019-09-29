import UIKit

class AlertCell: UITableViewCell {
    let formatter = DateFormatter()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        textLabel?.numberOfLines = 0

        detailTextLabel?.numberOfLines = 0

        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        formatter.doesRelativeDateFormatting = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with alert: Alert) {
        switch alert.state {
        case "reached":
            let icon = UIImage(systemName: "exclamationmark.triangle")
            imageView?.image = icon
            imageView?.tintColor = .systemRed
            textLabel?.textColor = .systemRed
        case "cooldown":
            let icon = UIImage(systemName: "checkmark.circle")
            imageView?.image = icon
            imageView?.tintColor = .systemGreen
            textLabel?.textColor = .systemGreen
        default:
            imageView?.image = nil
            imageView?.tintColor = nil
            textLabel?.textColor = nil
        }

        textLabel?.text = alert.metric
        detailTextLabel?.text = String(format: "Value: %.2f\u{202f}%%\n%@", alert.value * 100, alert.date.map { formatter.string(from: $0) } ?? "")
    }
}
// xmark.circle
// checkmark.circle
