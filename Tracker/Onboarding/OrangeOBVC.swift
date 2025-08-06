import UIKit

final class OrangeOBVC: UIViewController {
    
    // MARK: - private properties
    private lazy var backgroundImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "OnboardingOrangeImage"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        let text = "Даже если это не литры воды и йога"
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        guard let imageHeight = backgroundImageView.image?.size.height else { return }
        if imageHeight < view.frame.height {
            NSLayoutConstraint.activate([
                backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(view.bounds.height * 0.333))
        ])
    }
}
