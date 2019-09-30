import UIKit
import CoreData

class DashboardVC: UITableViewController {
    let context: Context
    let alertsFRC: NSFetchedResultsController<Alert>

    init(context: Context) {
        self.context = context
        self.alertsFRC = context.alerts()

        super.init(style: .plain)

        self.alertsFRC.delegate = self
        try? self.alertsFRC.performFetch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "System Health"

        tableView.register(cellType: AlertCell.self)
        tableView.register(headerFooterType: DashboardHeaderView.self)
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let alerts = alertsFRC.fetchedObjects else { return 0 }
        return alerts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: AlertCell.self)
        let alert = alertsFRC.object(at: indexPath)
        cell.configure(with: alert)
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

extension DashboardVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = newIndexPath {
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        default: break
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
