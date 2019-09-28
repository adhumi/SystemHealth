import UIKit

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}

extension UITableView {
    final func register<T: UITableViewCell>(cellType: T.Type) {
        self.register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }

    final func register<T: UITableViewHeaderFooterView>(headerFooterType: T.Type) {
        self.register(headerFooterType, forHeaderFooterViewReuseIdentifier: headerFooterType.reuseIdentifier)
    }

    final func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). Maybe the cell was not registerd beforehand.")
        }
        return cell
    }

    final func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>(headerFooterType: T.Type = T.self) -> T {
        guard let headerFooter = self.dequeueReusableHeaderFooterView(withIdentifier: headerFooterType.reuseIdentifier) as? T else {
            fatalError("Failed to dequeue a header/footer with identifier \(headerFooterType.reuseIdentifier) matching type \(headerFooterType.self). Maybe the header/footer was not registerd beforehand.")
        }
        return headerFooter
    }
}
