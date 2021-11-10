import UIKit
import Textile


private extension Style {
    static let saveTitle: Style = .header.sansSerif.p3.with(color: .ui.grey4).with(weight: .medium)
    static let saveTitleHighlighted: Style = .header.sansSerif.p3.with(color: .ui.grey1).with(weight: .medium)
}

class RecommendationSaveButton: UIButton {
    enum Mode {
        case save
        case saved

        var title: String {
            switch self {
            case .save:
                return "Save"
            case .saved:
                return "Saved"
            }
        }

        var image: ImageAsset {
            switch self {
            case .save:
                return .save
            case .saved:
                return .saved
            }
        }
    }

    var mode: Mode = .save {
        didSet {
            configuration?.image = UIImage(asset: mode.image)
            updateTitle()
        }
    }

    var isTitleHidden: Bool = false {
        didSet {
            updateTitle()
        }
    }

    init() {
        super.init(frame: .zero)
        configuration = .plain()
        configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 8,
            bottom: 8,
            trailing: 8
        )

        configuration?.imagePadding = 4

        configuration?.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
            return self?.imageColor() ?? UIColor(.ui.grey1)
        }

        configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [weak self] _ in
            return self?.textAttributes() ?? Style.saveTitle.attributes
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func textAttributes() -> AttributeContainer {
        switch state {
        case .selected, .highlighted:
            return Style.saveTitleHighlighted.attributes
        default:
            return Style.saveTitle.attributes
        }
    }

    private func imageColor() -> UIColor {
        let imageColor: ColorAsset = {
            switch state {
            case .highlighted, .selected:
                switch mode {
                case .save:
                    return .ui.grey1
                case .saved:
                    return .ui.coral1
                }
            default:
                switch mode {
                case .save:
                    return .ui.grey4
                case .saved:
                    return .ui.coral2
                }
            }
        }()

        return UIColor(imageColor)
    }

    private func updateTitle() {
        if isTitleHidden {
            configuration?.title = ""
        } else {
            configuration?.title = mode.title
        }
    }
}
