import UIKit

class RootVC: UIViewController {
    let context: Context

    let alertsVC: DashboardVC

    private var thresholdsObservers: [NSObjectProtocol] = []

    init(context: Context) {
        self.context = context
        self.alertsVC = DashboardVC(context: context)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationController = UINavigationController(rootViewController: alertsVC)
        addChildViewController(navigationController)

        alertsVC.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(onPresentSettings(_:)))

        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: CPUMonitor.thresholdReachedNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let report = notification.object as? CPUMonitor.CPUReport else { return }
            self?.presentAlert(title: "Threshold reached", message: String(format: "Using %.2f\u{202f}%% of CPU", report.user * 100))
        })
        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: CPUMonitor.thresholdCooldownNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let report = notification.object as? CPUMonitor.CPUReport else { return }
            self?.presentAlert(title: "Cooldown", message: String(format: "Using %.2f\u{202f}%% of CPU", report.user * 100))
        })
        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: RAMMonitor.thresholdReachedNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let report = notification.object as? RAMMonitor.RAMReport else { return }
            self?.presentAlert(title: "Threshold reached", message: String(format: "Using %.2f\u{202f}%% of RAM", report.usage * 100))
        })
        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: RAMMonitor.thresholdCooldownNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
        guard let report = notification.object as? RAMMonitor.RAMReport else { return }
            self?.presentAlert(title: "Cooldown", message: String(format: "Using %.2f\u{202f}%% of RAM", report.usage * 100))
        })
        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: BatteryMonitor.thresholdReachedNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let report = notification.object as? BatteryMonitor.BatteryReport else { return }
            self?.presentAlert(title: "Threshold reached", message: String(format: "%.2f\u{202f}%% of battery remaining", report.level * 100))
        })
        thresholdsObservers.append(NotificationCenter.default.addObserver(forName: BatteryMonitor.thresholdCooldownNotificationName, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let report = notification.object as? BatteryMonitor.BatteryReport else { return }
            self?.presentAlert(title: "Cooldown", message: String(format: "%.2f\u{202f}%% of battery remaining", report.level * 100))
        })
    }

    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .default) { [weak self] (action) in
            self?.dismiss(animated: true)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }

    @IBAction func onPresentSettings(_ sender: UIBarButtonItem) {
        let settingsVC = SettingsVC(context: context)
        let navigationController = UINavigationController(rootViewController: settingsVC)
        present(navigationController, animated: true)
    }
}
