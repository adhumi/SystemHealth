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

        tableView.register(cellType: UITableViewCell.self)
        tableView.register(headerFooterType: DashboardHeaderView.self)
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = "Soon"
        cell.detailTextLabel?.text = "Very soon"
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        let header = tableView.dequeueReusableHeaderFooter(headerFooterType: DashboardHeaderView.self)
        let viewModel = DashboardHeaderVM(context: context)
        header.configure(with: viewModel)
        return header
    }
}
