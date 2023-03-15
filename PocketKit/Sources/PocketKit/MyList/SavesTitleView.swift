import UIKit
import Textile

struct SavesSelection {
    let title: String
    let image: UIImage?
    let handler: () -> Void
}

/// Sets up a view that is used to filter between views in the top nav.
/// For the SwiftUI version see SavesSelectorButtonStyle which can be used in combination with a SwiftUI toolbar
class SavesTitleView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    private let selections: [SavesSelection]
    private var buttons: [UIButton] = []

    init(selections: [SavesSelection]) {
        self.selections = selections

        super.init(frame: .zero)

        accessibilityIdentifier = "saves-selection-switcher"
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        buttons = selections.map { selection in
            SavesSelectionButton(
                selection: selection,
                action: UIAction(title: selection.title, image: selection.image) { [weak self] action in
                    selection.handler()

                    guard let selectedButton = action.sender as? UIButton else {
                        return
                    }

                    self?.select(selectedButton)
                }
            )
        }

        buttons.forEach { button in
            stackView.addArrangedSubview(button)

            // Avoid a weird layout issue when a button's label is rendered for the first time
            // We need to know button's full size (and thus the label's size)
            // So we temporarily set it as selected before doing a layout pass.
            button.isSelected = true
            button.setNeedsLayout()
            button.layoutIfNeeded()
            button.isSelected = false
        }

        buttons.first?.isSelected = true
    }

    private func select(_ selectedButton: UIButton) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?._select(selectedButton)
        }
    }

    private func _select(_ selectedButton: UIButton) {
        buttons.forEach { button in
            button.isSelected = button === selectedButton
            button.setNeedsLayout()
            button.layoutIfNeeded()
        }

        stackView.setNeedsLayout()
        stackView.layoutIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
}

private class SavesSelectionButton: UIButton {
    private let selection: SavesSelection

    init(selection: SavesSelection, action: UIAction) {
        self.selection = selection
        super.init(frame: .zero)

        accessibilityLabel = selection.title

        configuration = UIButton.Configuration.plain()
        configuration?.background.cornerRadius = 16
        configuration?.background.backgroundColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
            guard self?.isSelected ?? false else { return .clear }
            return UIColor(.ui.teal6)
        }

        configuration?.image = selection.image
        configuration?.imagePadding = 8

        addAction(action, for: .primaryActionTriggered)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConfiguration() {
        guard isSelected else {
            configuration?.attributedTitle = nil
            configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in
                UIColor(.ui.grey1)
            }
            return
        }

        configuration?.attributedTitle = AttributedString(
            selection.title,
            attributes: Style.selected.attributes
        )

        configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in
            UIColor(.ui.teal1)
        }
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h8
    static let selected: Style = .title.with(color: .ui.teal1)
}
