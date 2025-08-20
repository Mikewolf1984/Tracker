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
    private var trackers: [Tracker] = []
    private var filteredTrackers: [Tracker] = []
    private var records: [TrackerRecord] = []
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var dateFormatter = DateFormatter()
    
    private let trackerStore = TrackerStore.shared
    private let trackerCategoryStore = TrackerCategoryStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private let dataProvider = TrackersDataProvider.shared
    
    private  let trackersLabel = UILabel()
    private  let searchField = UISearchBar()
    private  let addButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(UIImage(named: "addButton"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(addButtonTouch), for: .touchUpInside)
        return button
    }()
    
    private  let filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.setTitle(NSLocalizedString("filters", comment: "Фильтры") , for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filtersButtonTouch), for: .touchUpInside)
        return button
    }()
    
    private  let datePickerButton: UIDatePicker = {
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        //datePicker.locale = Locale(identifier: "ru_Ru")
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsService.shared.reportEvent(
            event: "open",
            params: ["screen": "Main"]
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        AnalyticsService.shared.reportEvent(
            event: "close",
            params: ["screen": "Main"]
        )
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateModelFromDB ()
        currentDate = datePickerButton.date
        if #available(iOS 15.0, *) {
            currentDateString = currentDate.formatted(date: .numeric, time: .omitted)
        } else {
            currentDateString = ""
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        configureTrackersView()
        dateRefresh()
        //showTrackersOrStub()
    }
    
    //MARK: - private methods
    private func updateModelFromDB ()
    {
        trackers = dataProvider.getAllTrackers()
        categories = dataProvider.getAllCategories()
      
        completedTrackers = Set(dataProvider.getCompletedTrackers())
        
    }
    
    private func filterCategoriesByCurrentDate() {
        filteredCategories = []
        for category in categories {
            var filteredTrackers: [Tracker] = []
            for tracker in category.trackers {
                if tracker.schedule.contains(currentDayOfWeek)||tracker.date == dateFormatter.string(from: currentDate) {
                    filteredTrackers.append(tracker)
                }
            }
            if filteredTrackers.count > 0 {
                let newCategory = TrackerCategory(name: category.name, trackers: filteredTrackers)
                filteredCategories.append(newCategory)
            }
        }
}
    
    
    
    private func showDeleteConfirmationAlert(for tracker: Tracker) {
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let title = NSAttributedString(
            string: NSLocalizedString("delete_tracker_confirm", comment: "подтверждение удаления"),
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]
        )
        alert.setValue(title, forKey: "attributedTitle")
        
        let deleteTitle =  NSLocalizedString("delete_tracker", comment: "Удалить")
        alert.addAction(UIAlertAction(title: deleteTitle, style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            do {
                try dataProvider.deleteTracker(id: tracker.id)
                try dataProvider.deleteRecords(for: tracker)
                
                
                self.dateRefresh()
                
            } catch {
                print("Error deleting tracker: \(error)")
            }
        }))
let cancelTitle =  NSLocalizedString("cancel_button", comment: "отменить")
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    
    private func showTrackersOrStub () {
        if (categories.count)*(trackers.count) > 0 {
            view.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
                
            ])
            view.addSubview(filtersButton)
            configureFiltersButton()
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
                dizzyLabel.text = NSLocalizedString("what_to_track", comment: "Что будем отслеживать?")
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
        trackersLabel.text = NSLocalizedString("trackers_title", comment: "Трекеры")
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
        searchField.placeholder =  NSLocalizedString("search", comment: "Поиск")
        showTrackersOrStub()
    }
    
    private func configureFiltersButton () {
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 130),
            filtersButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -130),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
        updateModelFromDB()
        filterCategoriesByCurrentDate()
        showTrackersOrStub()
        
    }
    
    func isTrackerCompletedToday(_ tracker: Tracker) -> Bool {
        let trackerRecord = TrackerRecord(id: tracker.id, date: currentDateString)
            return completedTrackers.contains(trackerRecord)
        }
        
        func countOfCompletionsOfTracker(_ tracker: Tracker) -> Int {
            let count = completedTrackers.filter { $0.id == tracker.id }.count
            return count
        }
    
    
    //MARK: - objc methods
    @objc  private func addButtonTouch() {
        AnalyticsService.shared.reportEvent(
            event: "click",
            params: [
                "screen": "Main",
                "item": "add_track"
            ]
        )
        let addNewTrackerViewController = AddNewTrackerViewController(delegate: self, categories: categories)
        addNewTrackerViewController.modalPresentationStyle = .automatic
        present(addNewTrackerViewController, animated: true, completion: nil)
    }
    
    @objc  private func filtersButtonTouch() {
        AnalyticsService.shared.reportEvent(
            event: "click",
            params: [
                "screen": "Main",
                "item": "filter"
            ]
        )
    }
    
    @objc  private func dateDidChanged() {
        currentDate = datePickerButton.date
        dateRefresh()
        showTrackersOrStub()
        collectionView.reloadData()
        dismiss(animated: true)
    }
    
    @objc  private func handleEditHabit(trackerId: UUID) {
        guard let tracker = trackers.first(where: { $0.id == trackerId }) else { return }
        
        let editHabitOrEventViewController = EditHabitOrEventViewController(tracker: tracker, trackerType: .habit, delegate: self, categories: categories)
        editHabitOrEventViewController.modalPresentationStyle = .automatic
        present(editHabitOrEventViewController, animated: true, completion: nil)
    }
    
   
}

//MARK:  - Extensions

extension TrackersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {return UICollectionViewCell()}
        let trackerToShow = filteredCategories[indexPath.section].trackers[indexPath.item]
        let daysCount = countOfCompletionsOfTracker(trackerToShow)
        let isCompleted = isTrackerCompletedToday(trackerToShow)
        cell.configureCell(with: trackerToShow, daysCount: daysCount, isCompleted: isCompleted, delegate: self)

       cell.onEditButtonTapped = { [weak self] tracker in
           AnalyticsService.shared.reportEvent(
               event: "click",
               params: [
                   "screen": "Main",
                   "item": "edit"
               ]
           )
           self?.handleEditHabit(trackerId: tracker.id)
        }
        
        cell.onDeleteButtonTapped = { [weak self] tracker in
            AnalyticsService.shared.reportEvent(
                event: "click",
                params: [
                    "screen": "Main",
                    "item": "delete"
                ]
            )
            self?.showDeleteConfirmationAlert(for: tracker)
        }
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
        
        if filteredCategories[indexPath.section].trackers.count>0 { view.titleLabel.text = filteredCategories[indexPath.section].name
        } else {view.frame = CGRect.zero
            view.titleLabel.text = ""}
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 8) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if filteredCategories[section].trackers.count > 0 {
            return 8
        } else {return 0}
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if filteredCategories[section].trackers.count > 0 {
            return UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
        } else {return UIEdgeInsets.zero}
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if filteredCategories[section].trackers.count > 0 {
            return CGSize(width: collectionView.bounds.width, height: 18)
        } else {return CGSize.zero}
    }
}


extension TrackersViewController: EditHabitOrTrackerDelegate {
    func trackerDidEdited(tracker: Tracker, category: TrackerCategory) {
       
        do {
            guard let categoryCD = try trackerCategoryStore.getCategoryCDByName(category.name) else {return}
            try trackerStore.editTracker(tracker, category: categoryCD)
            
        } catch {
            print ("error editing")
            return
        }
        dateRefresh()
        updateModelFromDB()
        showTrackersOrStub()
        
        dismiss(animated: true)
        
    }
    
   /* func trackerDidCanceled() {
        collectionView.reloadData()
        dismiss(animated: true)
    }*/
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
            try dataProvider.addTracker(newTracker, category: category)
            try trackerCategoryStore.addTrackerToCategory(newTracker, categoryName: category.name)
        } catch {
            print ("error creating")
            return
        }
        dateRefresh()
        updateModelFromDB()
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
            completedTrackers.remove(TrackerRecord(id: tracker.id, date: currentDateString))
            let record = TrackerRecord(id: tracker.id, date: currentDateString)
            
            do {
                try trackerRecordStore.removeRecord(record) }
            catch {
                print("Error removing record")
            }
            
        } else {
            if currentDate <= Date() {
                
                
                let newRecord = TrackerRecord(id: tracker.id, date: currentDateString)
                completedTrackers.insert(newRecord)
                do {
                    try trackerRecordStore.addRecord(newRecord)
                } catch {
                    print("Error adding record")
                }
            }
        }
        updateModelFromDB ()
        collectionView.reloadData()
    }
}
