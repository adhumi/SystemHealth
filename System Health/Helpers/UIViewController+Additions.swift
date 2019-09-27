import UIKit

extension UIViewController {
    public func addChildViewController(_ viewController: UIViewController, insets: UIEdgeInsets = .zero) {
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)
        addChild(viewController)
        viewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom)
        ])
    }
}
