import UIKit
import UserNotifications

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

        requestNotificationAuthorization()
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (granted, error) in
            if granted {
                print("Notifications: success")
            } else {
                print("Notifications: error")
            }
        }
    }

    @IBAction func onPresentSettings(_ sender: UIBarButtonItem) {
        let settingsVC = SettingsVC(context: context)
        let navigationController = UINavigationController(rootViewController: settingsVC)
        present(navigationController, animated: true)
    }
}
