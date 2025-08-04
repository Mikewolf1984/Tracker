import UIKit

final class StartScreenViewController: UIViewController {
    
    // MARK: - private properties
    private let odsKey: String =  "onboardingDidShown"
    private lazy var ypImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.image = UIImage(named: "ypLogo")
        return view
    }()
    
    // MARK: - override methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor(named: "ypBlue")
        self.view.addSubview(ypImageView)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            view.widthAnchor.constraint(equalToConstant: 91)
        ])
        print("StartScreen shown")
        let onboardingDidShowKey = UserDefaults.standard.bool(forKey: odsKey)
        if onboardingDidShowKey {
            let tabViewBarController = TabBarViewController()
            tabViewBarController.modalPresentationStyle = .fullScreen
            present(tabViewBarController, animated: true, completion: nil)
        } else {
            let onboardingViewController = OnboardingViewController()
            onboardingViewController.modalPresentationStyle = .fullScreen
            present(onboardingViewController, animated: true)
        }
    }
}


