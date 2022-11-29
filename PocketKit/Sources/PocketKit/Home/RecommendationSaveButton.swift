import UIKit
import Textile

private extension Style {
    static let saveTitle: Style = .header.sansSerif.p4.with(color: .ui.grey5).with(weight: .medium).with(maxScaleSize: 17)
    static let saveTitleHighlighted: Style = .header.sansSerif.p4.with(color: .ui.grey1).with(weight: .medium).with(maxScaleSize: 17)
}

class RecommendationSaveButton: UIButton {
    enum Mode {
        case save
        case saved

        var title: String {
            switch self {
            case .save:
                return "Save".localized()
            case .saved:
                return "Saved".localized()
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
            top: 16,
            leading: 8,
            bottom: 16,
            trailing: 8
        )

        configuration?.imagePadding = 6

        configuration?.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
            return self?.imageColor() ?? UIColor(.ui.coral2)
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
                    return .ui.coral1
                case .saved:
                    return .ui.coral1
                }
            default:
                switch mode {
                case .save:
                    return .ui.coral2
                case .saved:
                    return .ui.coral2
                }
            }
        }()

        return UIColor(imageColor)
    }

    private func updateTitle() {
        configuration?.title = mode.title
    }
}
