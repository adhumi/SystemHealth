import UIKit

class ThresholdCell: UITableViewCell {
    let slider = UISlider()

    var valueChanged: ((Float) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(onValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(onReleased(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(onReleased(_:)), for: .touchUpOutside)
        contentView.addSubview(slider)

        if let textLabel = textLabel, let detailTextLabel = detailTextLabel {
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            detailTextLabel.translatesAutoresizingMaskIntoConstraints = false
            detailTextLabel.text = "0\u{202f}%"

            NSLayoutConstraint.activate([
                textLabel.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
                textLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
                textLabel.heightAnchor.constraint(equalToConstant: 44),

                detailTextLabel.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 16),
                detailTextLabel.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
                detailTextLabel.heightAnchor.constraint(equalTo: textLabel.heightAnchor),
                detailTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor),

                slider.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
                slider.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
                slider.topAnchor.constraint(equalTo: textLabel.bottomAnchor),
                slider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with value: Float) {
        slider.value = value
        detailTextLabel?.text = String(format: "%.f\u{202f}%%", slider.value * 100)
    }

    @IBAction func onValueChanged(_ slider: UISlider) {
        detailTextLabel?.text = String(format: "%.f\u{202f}%%", slider.value * 100)
    }

    @IBAction func onReleased(_ slider: UISlider) {
        valueChanged?(slider.value)
    }
}
