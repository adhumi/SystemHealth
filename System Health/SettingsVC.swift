import UIKit

class SettingsVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(onClose(_:)))
    }

    @IBAction func onClose(_ sender: UIBarButtonItem) {
        parent?.dismiss(animated: true)
    }
}
