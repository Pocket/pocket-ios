import UIKit


class MyListTitleView: UIView {
    private let stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    private var selection: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(.ui.grey1).cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private var selections: [MyListSelection]

    private var buttons: [UIButton] = []
    private var lastSelectedButton: UIButton? = nil

    init(selections: [MyListSelection]) {
        self.selections = selections
        
        super.init(frame: .zero)
        
        addSubview(selection)
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        buttons = selections.enumerated().map { offset, selection -> UIButton in
            let button = MyListSelectionButton()
            button.accessibilityLabel = selection.title
            
            let action = UIAction(title: selection.title, image: selection.image) { _ in
                self.updateSelection(button)
                selection.handler()
            }
            button.addAction(action, for: .touchUpInside)

            return button
        }
        buttons.forEach(stackView.addArrangedSubview)
        updateSelection(buttons[0])

        accessibilityIdentifier = "my-list-selection-switcher"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selection.frame = lastSelectedButton?.frame ?? .zero
        selection.layer.cornerRadius = selection.frame.height / 2
        selection.layer.borderColor = UIColor(.ui.grey1).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    private func updateSelection(_ button: UIButton) {
        lastSelectedButton?.isSelected = false

        button.isSelected = true
        lastSelectedButton = button

        UIView.animate(withDuration: 0.3) {
            self.selection.frame = button.frame
        }
    }
}

struct MyListSelection {
    let title: String
    let image: UIImage?
    let handler: () -> ()
}

private class MyListSelectionButton: UIButton {
    private let actionImageView = UIImageView()
    private let actionLabel = UILabel()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve) {
                self.actionLabel.alpha = self.isSelected ? 1 : 0
                self.actionLabel.isHidden = !self.isSelected
            }
        }
    }
    
    override func addAction(_ action: UIAction, for controlEvents: UIControl.Event) {
        super.addAction(action, for: controlEvents)
        
        actionLabel.text = action.title
        actionImageView.tintColor = UIColor(.ui.grey1)
        actionImageView.image = action.image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.addArrangedSubview(actionImageView)
        stackView.addArrangedSubview(actionLabel)
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        actionLabel.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
}
