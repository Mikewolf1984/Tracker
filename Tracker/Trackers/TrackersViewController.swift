import UIKit
import Foundation

final class TrackersViewController: UIViewController {
    
    //MARK: - private properties
    //Временные трекеры для проверки
    private let tracker1: Tracker = .init(
        id: UUID(),
        type: .habit,
        name: "Первая привычка",
        color: UIColor(named: "selColor1 1") ?? .red,
        emoji: "🐈",
        schedule: [.monday, .wednesday, .friday],
        date: 0
    )
    private let tracker2: Tracker = .init(
        id: UUID(),
        type: .habit,
        name: "Вторая привычка",
        color: UIColor(named: "selColor1 2") ?? .blue,
        emoji: "😇",
        schedule: [.tuesday, .thursday, .saturday],
        date: 0
    )
    private let tracker3: Tracker = .init(
        id: UUID(),
        type: .habit,
        name: "Третья привычка",
        color: UIColor(named: "selColor1 3") ?? .blue,
        emoji: "😇",
        schedule: [.saturday],
        date: 0
    ) //
    
    private var currentDate: Date = Date()
    private var currentDayOfWeek: DayOfWeek = .monday
    private let daysOfWeek: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private let cellIdentifier = "trackercell"
    private var completedTrackers: Set<TrackerRecord> = []
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var dateFormatter = DateFormatter()
    
    private  let trackersLabel = UILabel()
    private  let searchField = UISearchBar()
    private  let addButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(UIImage(named: "addButton"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(addButtonTouch), for: .touchUpInside)
        return button
    }()
    
    private  let datePickerButton: UIDatePicker = {
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_Ru")
        datePicker.addTarget(self, action: #selector(dateDidChanged), for: .valueChanged)
        return datePicker
    }()
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    //MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // временные категории
        if !categories.contains(where: { $0.name == "Хобби" }) {
            let cat1: TrackerCategory = .init(name: "Хобби", trackers: [tracker1,tracker2])
            categories.append(cat1)}
        if !categories.contains(where: { $0.name == "Обязанности" }) {
            let cat2: TrackerCategory = .init(name: "Обязанности", trackers: [tracker3])
            categories.append(cat2)
        } //
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        configureTrackersView()
        
        currentDate = datePickerButton.date
        dateRefresh()
        showTrackersOrStub()
    }
    
    //MARK: - private methods
    private func showTrackersOrStub () {
        if filteredCategories.count > 0 {
            view.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
                
            ])
            collectionView.reloadData()
        } else {
            if collectionView.superview != nil {
                collectionView.removeFromSuperview()
            }
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
        showTrackersOrStub()
    }
    
    private func isTrackerCompletedToday(_ tracker: Tracker) -> Bool {
        let trackerRecord = TrackerRecord(id: tracker.id, date: currentDate.toInt())
        return completedTrackers.contains(trackerRecord)
    }
    
    private func countOfCompletionsOfTracker(_ tracker: Tracker) -> Int {
        let count = completedTrackers.filter { $0.id == tracker.id }.count
        return count
    }
    
    private func dateRefresh() {
        switch Calendar.current.component(.weekday, from: currentDate) {
        case 2: currentDayOfWeek = .monday
        case 3: currentDayOfWeek = .tuesday
        case 4: currentDayOfWeek = .wednesday
        case 5: currentDayOfWeek = .thursday
        case 6: currentDayOfWeek = .friday
        case 7: currentDayOfWeek = .saturday
        case 1: currentDayOfWeek = .sunday
        default:
            currentDayOfWeek = .sunday
        }
        filteredCategories = []
        for category in categories {
            var filteredTrackers: [Tracker] = []
            for tracker in category.trackers {
                if tracker.schedule.contains(currentDayOfWeek)||tracker.date == currentDate.toInt() {
                    filteredTrackers.append(tracker)
                }
            }
            if filteredTrackers.count > 0 {
                let newCategory = TrackerCategory(name: category.name, trackers: filteredTrackers)
                filteredCategories.append(newCategory)
            }
        }
    }
    //MARK: - objc methods
    @objc func addButtonTouch() {
        let addNewTrackerViewController = AddNewTrackerViewController(delegate: self, categories: categories)
        addNewTrackerViewController.modalPresentationStyle = .automatic
        present(addNewTrackerViewController, animated: true, completion: nil)
    }
    
    @objc func dateDidChanged() {
        currentDate = datePickerButton.date
        dateRefresh()
        showTrackersOrStub()
        dismiss(animated: true)
    }
}

//MARK:  - Extensions

extension TrackersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {return UICollectionViewCell()}
        let trackerToShow = filteredCategories[indexPath.section].trackers[indexPath.item]
        cell.configureCell(with: trackerToShow, daysCount: countOfCompletionsOfTracker(trackerToShow), isCompleted: (isTrackerCompletedToday(trackerToShow)), delegate: self)
        
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersSupplementaryView else {return UICollectionReusableView()}
        view.titleLabel.text = filteredCategories[indexPath.section].name
        return view
    }
    
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
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
}


extension TrackersViewController: AddHabitOrTrackerDelegate {
    
    func trackerDidCreated(tracker: Tracker, category: TrackerCategory)  {
        let newTracker = Tracker(
            id: tracker.id, type: tracker.type, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule, date: currentDate.toInt())
        
        var updatedTrackers = category.trackers
        updatedTrackers.append(newTracker)
        let updatedCategory  = TrackerCategory(name: category.name, trackers: updatedTrackers)
        let categoryIndex = categories.firstIndex(where: { $0.name == category.name }) ?? 0
        categories[categoryIndex] = updatedCategory
        dateRefresh()
        showTrackersOrStub()
        self.dismiss(animated: true)
    }
    
    func trackerDidCanceled() {
        collectionView.reloadData()
        self.dismiss(animated: true)
    }
}

extension TrackersViewController: CompleteButtonDelegate {
    
    func didTapCompleteButton(tracker: Tracker)
    {
        if isTrackerCompletedToday(tracker) {
            completedTrackers.remove(TrackerRecord(id: tracker.id, date: currentDate.toInt()))
        } else {
            if currentDate.toInt() <= Date().toInt() {
                let newRecord = TrackerRecord(id: tracker.id, date: currentDate.toInt())
                completedTrackers.insert(newRecord)
            }
        }
        collectionView.reloadData()
    }
}

