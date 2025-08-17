import UIKit

final class TabBarViewController: UITabBarController {
    
    //MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    //MARK: - private methods
    private func configureTabBar() {
        view.backgroundColor = .white
        tabBar.isTranslucent = false
        let trackersViewController =  TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        trackersViewController.tabBarItem.title = NSLocalizedString("trackers_title", comment: "Трекеры")
        trackersViewController.tabBarItem.image = UIImage(named: "trackerLogo")
        statisticsViewController.tabBarItem.title = NSLocalizedString("statistics", comment: "Статистика")
        statisticsViewController.tabBarItem.image = UIImage(named: "statLogo")
        viewControllers = [trackersViewController, statisticsViewController]
        let topLine = CALayer()
        topLine.backgroundColor = UIColor.gray.cgColor
        topLine.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5)
        tabBar.layer.addSublayer(topLine)
    }
}
