import UIKit

class AlertsVC: UITableViewController {
    let context: Context

    init(context: Context) {
        self.context = context
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "System Health"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.register(DashboardHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: DashboardHeaderView.self))
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = "Soon"
        cell.detailTextLabel?.text = "Very soon"
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: DashboardHeaderView.self)) as? DashboardHeaderView else { return nil }
        let viewModel = DashboardHeaderVM(context: context)
        header.configure(with: viewModel)
        return header
    }
}
