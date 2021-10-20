import UIKit
import Lottie


class HomeOverscrollView: UIView {
    private lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var attributedText: NSAttributedString? {
        get { textLabel.attributedText }
        set { textLabel.attributedText = newValue }
    }
    
    private lazy var animationView: AnimationView = {
        let view = AnimationView(animation: nil)
        return view
    }()
    
    var animation: Animation? {
        get { animationView.animation }
        set { animationView.animation = newValue }
    }
    
    var isAnimating: Bool {
        get { animationView.isAnimationPlaying }
        set {
            if newValue == true {
                animationView.play { _ in
                    self.didFinishPreviousAnimation = true
                }
            } else {
                animationView.stop()
                animationView.currentTime = 0
                didFinishPreviousAnimation = false
            }
        }
    }
    
    private(set) var didFinishPreviousAnimation: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        textLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        animationView.setContentCompressionResistancePriority(.required, for: .horizontal)
        animationView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let stackView = UIStackView(arrangedSubviews: [textLabel, animationView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.alignment = .center

        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, constant: -16),
            stackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
