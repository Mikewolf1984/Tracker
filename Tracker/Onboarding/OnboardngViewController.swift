import UIKit

final class OnboardingViewController: UIPageViewController {
    // MARK: - init
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - private properties
    private let odsKey: String =  "onboardingDidShown"
    private let pages: [UIViewController] = [BlueOBVC(), OrangeOBVC()]
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = 2
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPage = 0
        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return pageControl
    }()
    
    private var completeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        view.addSubview(completeButton)
        NSLayoutConstraint.activate([
            completeButton.heightAnchor.constraint(equalToConstant: 60),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
        ])
    }
    
    // MARK: - objc methods
    
    @objc private func completeButtonTapped() {
        UserDefaults.standard.set(true, forKey: odsKey)
        let tabBarViewController = TabBarViewController()
        tabBarViewController.modalPresentationStyle = .fullScreen
        present(tabBarViewController, animated: true, completion: nil)
    }
}

// MARK: - extensions
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < (pages.count - 1) else {
            return nil
        }
        return pages[currentIndex + 1]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
