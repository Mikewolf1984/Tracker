import UIKit
import Foundation

final class TrackersViewController: UIViewController {
    
    //MARK: - public properties
    
    var currentDate: Date = Date()
    var currentDateString: String = ""
    var currentDayOfWeek: DayOfWeek = .monday
    
    //MARK: - private properties
    
    private let daysOfWeek: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private let cellIdentifier = "trackercell"
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var dateFormatter = DateFormatter()
    
    private let trackerStore = TrackerStore.shared
    private let trackerCategoryStore = TrackerCategoryStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private let dataProvider = TrackersDataProvider()
    
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
        
        currentDate = datePickerButton.date
        if #available(iOS 15.0, *) {
            currentDateString = currentDate.formatted(date: .numeric, time: .omitted)
        } else {
            currentDateString = ""
        }
        dateRefresh()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        configureTrackersView()
        showTrackersOrStub()
    }
    
    //MARK: - private methods
    private func showTrackersOrStub () {
        if dataProvider.numberOfSections() > 0 {
            view.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
                
            ])} else {
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
        trackerRecordStore?.isCompletedInDate(for: tracker, date: currentDateString) ?? false
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
        collectionView.reloadData()
        if #available(iOS 15.0, *) {
            currentDateString = currentDate.formatted(date: .numeric, time: .omitted)
        } else {
            currentDateString = "fail"
        }
    }
    private func countOfTrackersForSection(section: Int) -> Int {
        let trackersForSection = dataProvider.todayTrackersForSection(day: currentDayOfWeek, section: section)
        return trackersForSection.count
    }
    //MARK: - objc methods
    @objc  private func addButtonTouch() {
        let addNewTrackerViewController = AddNewTrackerViewController(delegate: self, categories: categories)
        addNewTrackerViewController.modalPresentationStyle = .automatic
        present(addNewTrackerViewController, animated: true, completion: nil)
    }
    
    @objc  private func dateDidChanged() {
        currentDate = datePickerButton.date
        dateRefresh()
        showTrackersOrStub()
        collectionView.reloadData()
        dismiss(animated: true)
    }
}

//MARK:  - Extensions

extension TrackersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataProvider.numberOfRowsInSection(day: currentDayOfWeek, section: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataProvider.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {return UICollectionViewCell()}
        let trackerObjectToShow = dataProvider.object(at: indexPath, day: currentDayOfWeek, currentDate: currentDateString)
        cell.configureCell(with: trackerObjectToShow.tracker, daysCount: trackerObjectToShow.daysCount, isCompleted: trackerObjectToShow.isCompleted, delegate: self)
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
        
        if countOfTrackersForSection(section: indexPath.section)>0 { view.titleLabel.text = dataProvider.categoryName(section: indexPath.section)
        } else {view.frame = CGRect.zero
            view.titleLabel.text = ""}
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 8) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if countOfTrackersForSection(section: section) > 0 {
            return 8
        } else {return 0}
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if countOfTrackersForSection(section: section) > 0 {
            return UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
        } else {return UIEdgeInsets.zero}
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if countOfTrackersForSection(section: section) > 0 {
            return CGSize(width: collectionView.bounds.width, height: 18)
        } else {return CGSize.zero}
    }
}


extension TrackersViewController: AddHabitOrTrackerDelegate {
    func trackerDidCreated(tracker: Tracker, category: TrackerCategory) {
        let newTracker: Tracker
        if #available(iOS 15.0, *) {
            newTracker = Tracker(
                id: tracker.id, type: tracker.type, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule, date: currentDate.formatted(date: .numeric, time: .omitted))
        } else {
            newTracker = Tracker(
                id: tracker.id, type: tracker.type, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule, date: "")
        }
        
        var updatedTrackers = category.trackers
        updatedTrackers.append(newTracker)
        do {
            try trackerStore?.addNewTracker(newTracker)
            try trackerCategoryStore?.addTrackerToCategory(newTracker, categoryName: category.name)
        } catch {return}
        dateRefresh()
        showTrackersOrStub()
        dismiss(animated: true)
    }
    
    func trackerDidCanceled() {
        collectionView.reloadData()
        dismiss(animated: true)
    }
}

extension TrackersViewController: CompleteButtonDelegate {
    func didTapCompleteButton(tracker: Tracker)
    {
        if isTrackerCompletedToday(tracker) {
            let record = TrackerRecord(id: tracker.id, date: currentDateString)
            do {
                try trackerRecordStore?.removeRecord(record) }
            catch {
                print("Error removing record")
            }
            
        } else {
            if currentDate <= Date() {
                let newRecord = TrackerRecord(id: tracker.id, date: currentDateString)
                do {
                    try trackerRecordStore?.addRecord(newRecord)
                } catch {
                    print("Error adding record")
                }
            }
        }
        collectionView.reloadData()
    }
}
