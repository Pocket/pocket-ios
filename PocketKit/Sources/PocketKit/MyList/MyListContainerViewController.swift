import UIKit


struct SelectionItem {
    let title: String
    let image: UIImage
}

protocol SelectableViewController: UIViewController {
    var selectionItem: SelectionItem { get }
}

class MyListContainerViewController: UIViewController {
    private let viewControllers: [SelectableViewController]

    init(viewControllers: [SelectableViewController]) {
        self.viewControllers = viewControllers

        super.init(nibName: nil, bundle: nil)

        viewControllers.forEach { vc in
            addChild(vc)
            vc.didMove(toParent: vc)
        }

        let selections = viewControllers.map { vc in
            MyListSelection(title: vc.selectionItem.title, image: vc.selectionItem.image) { [weak self] in
                self?.select(child: vc)
            }
        }

        navigationItem.titleView = MyListTitleView(selections: selections)
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.accessibilityIdentifier = "my-list"
        select(child: viewControllers.first)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func select(child: SelectableViewController?) {
        guard let child = child else {
            return
        }

        navigationItem.backButtonTitle = child.selectionItem.title
        viewControllers
            .compactMap(\.viewIfLoaded)
            .forEach { $0.removeFromSuperview() }
        view.addSubview(child.view)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
