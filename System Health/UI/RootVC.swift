import UIKit

class RootVC: UIViewController {
    let context: Context

    let alertsVC: AlertsVC

    init(context: Context) {
        self.context = context
        self.alertsVC = AlertsVC(context: context)
        
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
    }

    @IBAction func onPresentSettings(_ sender: UIBarButtonItem) {
        let settingsVC = SettingsVC(context: context)
        let navigationController = UINavigationController(rootViewController: settingsVC)
        present(navigationController, animated: true)
    }
}
