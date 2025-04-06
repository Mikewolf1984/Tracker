import UIKit

final class TrackersViewController: UIViewController {
    
    static let shared = TrackersViewController()
    private let cellIdentifier = "trackercell"
    private let categoriesService = CategoriesService.shared
    private let tracker1: Tracker = .init(
        id: UUID(),
        type: .habit,
        name: "Первая привычка",
        color: UIColor(named: "selColor1 1") ?? .red,
        emoji: "🐈",
        schedule: [.monday, .wednesday, .friday]
    )
    
    private let tracker2: Tracker = .init(
        id: UUID(),
        type: .habit,
        name: "Вторая привычка",
        color: UIColor(named: "selColor1 2") ?? .blue,
        emoji: "😇",
        schedule: [.tuesday, .thursday, .saturday]
    )
    
    private let tracker3: Tracker = .init(
        id: UUID(),
        type: .irregularEvent,
        name: "Третья привычка",
        color: UIColor(named: "selColor1 3") ?? .blue,
        emoji: "😇",
        schedule: [.tuesday, .wednesday, .saturday]
    )
    
    
    
    private  let addButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(UIImage(named: "addButton"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(addButtonTouch), for: .touchUpInside)
        return button
    }()
    
    private  let datePickerButton = UIDatePicker()
    private  let trackersLabel = UILabel()
    private  let searchField = UISearchBar()
    
    private var completedTrackers: [TrackerRecord] = []
    
    
    private  let categories = CategoriesService.shared.categories
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !CategoriesService.shared.categories.contains(where: { $0.name == "Привычки" }) {
            let cat1: TrackerCategory = .init(name: "Привычки", trackers: [tracker1,tracker2])
            categoriesService.categories.append(cat1)}
        if !CategoriesService.shared.categories.contains(where: { $0.name == "Обязанности" }) {
            let cat2: TrackerCategory = .init(name: "Обязанности", trackers: [tracker3])
            categoriesService.categories.append(cat2)
        }
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        configureTrackersView()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        
        
    }
    
    private func showTrackersOrStub (trackers: [Tracker]) {
        if trackers.count != 0 {
            
            view.addSubview(collectionView)
            
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            ])
            
        } else {
            let dizzyImageView = UIImageView(image: UIImage(named: "dizzy"))
            view.addSubview(dizzyImageView)
            dizzyImageView.translatesAutoresizingMaskIntoConstraints = false
            dizzyImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            dizzyImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            dizzyImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            dizzyImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            let dizzyLabel = UILabel()
            dizzyLabel.text = "Что будем отслеживать?"
            dizzyLabel.font = .systemFont(ofSize: 12, weight: .medium)
            dizzyLabel.textColor = .black
            view.addSubview(dizzyLabel)
            dizzyLabel.translatesAutoresizingMaskIntoConstraints = false
            dizzyLabel.centerXAnchor.constraint(equalTo: dizzyImageView.centerXAnchor).isActive = true
            dizzyLabel.topAnchor.constraint(equalTo: dizzyImageView.bottomAnchor, constant: 8).isActive = true
        }
    }
    
    private func configureTrackersView() {
        
        
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6).isActive = true
        addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        datePickerButton.datePickerMode = .date
        datePickerButton.preferredDatePickerStyle = .compact
        view.addSubview(datePickerButton)
        
        datePickerButton.translatesAutoresizingMaskIntoConstraints = false
        datePickerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        datePickerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        
        trackersLabel.text = "Трекеры"
        trackersLabel.font  = UIFont.systemFont(ofSize: 34, weight: .bold)
        trackersLabel.textColor = .black
        view.addSubview(trackersLabel)
        
        trackersLabel.translatesAutoresizingMaskIntoConstraints = false
        trackersLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 1).isActive = true
        trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        view.addSubview(searchField)
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7).isActive = true
        searchField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        searchField.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -16).isActive = true
        searchField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        searchField.searchBarStyle = .minimal
        searchField.placeholder = "Поиск"
        
        showTrackersOrStub(trackers: [tracker1, tracker2])
        
    }
    
    @objc func addButtonTouch() {
        let addNewTrackerViewController = AddNewTrackerViewController(delegate: self)
        addNewTrackerViewController.modalPresentationStyle = .automatic
        present(addNewTrackerViewController, animated: true, completion: nil)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TrackersViewController.shared.categories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return TrackersViewController.shared.categories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCollectionViewCell
        let stubTrackers = TrackersViewController.shared.categories[indexPath.section].trackers
        cell?.configureCell(with: stubTrackers[indexPath.item])
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! TrackersSupplementaryView
        view.titleLabel.text = TrackersViewController.shared.categories[indexPath.section].name
        return view
    }
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 8) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

extension TrackersViewController: AddHabitOrTrackerDelegate {
    func trackerDidCreated(tracker: Tracker, category: TrackerCategory)  {
        print(category)
        categoriesService.categories
        self.dismiss(animated: true)
    }
    
    func trackerDidCanceled() {
        print("Creating tracker canceled")
        self.dismiss(animated: true)
    }
}
