import UIKit

class SettingsVC: UITableViewController {
    let context: Context

    init(context: Context) {
        self.context = context
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(onClose(_:)))

        tableView.register(cellType: UITableViewCell.self)
        tableView.register(cellType: SwitchCell.self)
        tableView.register(cellType: ThresholdCell.self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        context.settingsStore.preferences.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // General switch, threshold, cooldown switch
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let key = context.settingsStore.preferenceKeys[indexPath.section]
        let preferences = context.settingsStore.preferences[key]

        switch indexPath.row {
        case 0:
            let switchCell = tableView.dequeueReusableCell(for: indexPath, cellType: SwitchCell.self)
            switchCell.configure(value: preferences?.active ?? false)
            switchCell.valueChanged = { [weak self] value in
                guard var preferences = preferences else { return }
                preferences.active = value
                self?.context.settingsStore.save(preference: preferences, for: key)
            }
            switchCell.textLabel?.text = "Activate tracking"
            cell = switchCell
        case 1:
            let thresholdCell = tableView.dequeueReusableCell(for: indexPath, cellType: ThresholdCell.self)
            thresholdCell.configure(with: preferences?.threshold ?? 0.5)
            thresholdCell.valueChanged = { [weak self] value in
                guard var preferences = preferences else { return }
                preferences.threshold = value
                self?.context.settingsStore.save(preference: preferences, for: key)
            }
            thresholdCell.textLabel?.text = "Threshold"
            cell = thresholdCell
        case 2:
            let switchCell = tableView.dequeueReusableCell(for: indexPath, cellType: SwitchCell.self)
            switchCell.configure(value: preferences?.cooldownAlert ?? false)
            switchCell.valueChanged = { [weak self] value in
                guard var preferences = preferences else { return }
                preferences.cooldownAlert = value
                self?.context.settingsStore.save(preference: preferences, for: key)
            }
            switchCell.textLabel?.text = "Cooldown notifications"
            cell = switchCell
        default:
            cell = tableView.dequeueReusableCell(for: indexPath)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return context.settingsStore.preferenceKeys[section]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func onClose(_ sender: UIBarButtonItem) {
        parent?.dismiss(animated: true)
    }
}
