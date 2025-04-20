import UIKit

final class AddHabitOrEventViewController: UIViewController {
    
    //MARK: - Init
    init(trackerType: TrackerType, delegate: AddHabitOrTrackerDelegate, categories: [TrackerCategory]) {
        self.trackerType = trackerType
        self.delegate = delegate
        self.categories = categories
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - private properties
    private let emojiOrColorCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    private let tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.register(AddTrackerCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = YPColors.ypBackGroundColor
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private let nameTextField: UITextField = {
        let textField: UITextField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = YPColors.ypBackGroundColor
        textField.layer.cornerRadius = 16
        
        let clearTextButton = UIButton(type: .custom)
        let xMarkImage = UIImage(named: "xmark.circle")
        clearTextButton.setImage(xMarkImage, for: .normal)
        clearTextButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        clearTextButton.addTarget(self, action: #selector(didTapClearTextButton), for: .touchUpInside)
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: clearTextButton.frame.width + 12, height: clearTextButton.frame.height))
        rightPaddingView.addSubview(clearTextButton)
        textField.rightView = rightPaddingView
        textField.rightViewMode = .whileEditing
        return textField
    }()
    
    private let limitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let createButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = YPColors.ypGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 16
        button.isEnabled = true
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let  trackerTypeLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    weak var delegate: AddHabitOrTrackerDelegate?
    private let categories: [TrackerCategory]
    private var selectedDays: [DayOfWeek] = []
    private var selectedCategory: TrackerCategory?
    private let trackerType: TrackerType
    private var tracker: Tracker?
    private var tableViewTopAnchor: NSLayoutConstraint?
    private var tableViewData = ["Категория","Расписание"]
    private let collectionViewIdentifier: String = "EmojiOrColorCollectionViewCell"
    private let emojies = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private let colors = [YPColors.ypColor1, YPColors.ypColor2, YPColors.ypColor3, YPColors.ypColor4, YPColors.ypColor5,
                          YPColors.ypColor6, YPColors.ypColor7, YPColors.ypColor8, YPColors.ypColor9, YPColors.ypColor10,
                          YPColors.ypColor11, YPColors.ypColor12, YPColors.ypColor13, YPColors.ypColor14, YPColors.ypColor15,
                          YPColors.ypColor16, YPColors.ypColor17, YPColors.ypColor18]
    private var emojiIndexPath: IndexPath?
    private var colorIndexPath: IndexPath?
    
    //MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureView()
        tableView.delegate = self
        tableView.dataSource = self
        emojiOrColorCollectionView.register(EmojiOrColorCell.self, forCellWithReuseIdentifier: collectionViewIdentifier)
        emojiOrColorCollectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        emojiOrColorCollectionView.delegate = self
        emojiOrColorCollectionView.dataSource = self
        nameTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    //MARK: - private methods
    private func configureView() {
        switch trackerType {
        case .habit: tableViewData = ["Категория","Расписание"]
        case .irregularEvent: tableViewData = ["Категория"]
        }
        view.addSubview(trackerTypeLabel)
        trackerTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        switch trackerType {
        case .habit: trackerTypeLabel.text = "Новая привычка"
        case .irregularEvent: trackerTypeLabel.text = "Новое нерегулярное событие"
        }
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(limitLabel)
        limitLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emojiOrColorCollectionView)
        emojiOrColorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        updateConstraints()
        
        
    }
    
    private func updateConstraints() {
        NSLayoutConstraint.activate([
            trackerTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackerTypeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28)]
        )
        NSLayoutConstraint.activate([
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60)])
        let viewWidth = view.frame.width
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            cancelButton.widthAnchor.constraint(equalToConstant: (viewWidth-48)/2),
            cancelButton.heightAnchor.constraint(equalToConstant: 60)])
        NSLayoutConstraint.activate([
            limitLabel.topAnchor.constraint(equalTo: nameTextField.topAnchor, constant: 83),
            limitLabel.centerXAnchor.constraint(equalTo: nameTextField.centerXAnchor)])
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: trackerTypeLabel.bottomAnchor, constant: 38),
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.widthAnchor.constraint(equalToConstant: view.frame.width  - 32)])
        tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        tableViewTopAnchor?.isActive = true
        NSLayoutConstraint.activate([tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     tableView.widthAnchor.constraint(equalToConstant: view.frame.width  - 32),
                                     tableView.heightAnchor.constraint(equalToConstant: CGFloat(tableViewData.count*75))])
        
        NSLayoutConstraint.activate([emojiOrColorCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
                                     emojiOrColorCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor ,constant: -110),
                                     emojiOrColorCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     emojiOrColorCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width  - 32)])
        
    }
    
    private func showLimitLabel() {
        limitLabel.isHidden = false
        tableViewTopAnchor?.constant = 48
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideLimitLabel() {
        limitLabel.isHidden = true
        tableViewTopAnchor?.constant = 24
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func createButtonEnableCheck() {
        var conditionName: Bool
        var conditionCategory: Bool
        var conditionSchedule: Bool
        var conditionColorAndEmoji: Bool
        if let text = nameTextField.text {
            conditionName = !text.isEmpty
        } else {
            conditionName = false
        }
        if let selectedCategory {conditionCategory = true
        } else {conditionCategory = false}
        conditionSchedule = !selectedDays.isEmpty
        conditionColorAndEmoji = (emojiIndexPath != nil) && (colorIndexPath != nil)
        switch trackerType {
        case .habit:
            if conditionName && conditionCategory && conditionSchedule && conditionColorAndEmoji {
                createButton.isEnabled = true
                createButton.backgroundColor = .black
            } else {
                createButton.isEnabled = false
                createButton.backgroundColor = YPColors.ypGray
            }
        case .irregularEvent:
            if conditionName && conditionCategory && conditionColorAndEmoji {
                createButton.isEnabled = true
                createButton.backgroundColor = .black
            } else {
                createButton.isEnabled = false
                createButton.backgroundColor = YPColors.ypGray
            }
        }
    }
    //MARK: - objc methods
    @objc  private func cancelButtonTapped() {
        delegate?.trackerDidCanceled()
        dismiss(animated: true)
    }
    
    @objc  private func createButtonTapped() {
        let newTracker: Tracker = .init(
            id: UUID(),
            type: trackerType,
            name: nameTextField.text ?? "",
            color: colors[colorIndexPath?.item ?? 0],
            emoji: emojies[emojiIndexPath?.item ?? 0],
            schedule: selectedDays,
            date: 0
        )
        guard let category = selectedCategory else { return }
        delegate?.trackerDidCreated(tracker: newTracker, category: category)
        dismiss(animated: true)
    }
    
    @objc private  func didTapClearTextButton() {
        nameTextField.text = ""
        hideLimitLabel()
    }
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
        createButtonEnableCheck()
    }
}
//MARK: - extensions

extension AddHabitOrEventViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nameTextField.resignFirstResponder()
        if tableViewData[indexPath.row] == "Расписание" {
            let scheduleSelectViewController = ScheduleSelectViewController(selectedDays: selectedDays, delegate: self)
            present(scheduleSelectViewController, animated: true, completion: nil)
        } else {
            let index = categories.firstIndex(where: { $0.name == selectedCategory?.name }) ?? nil
            let categorySelectController = CategorySelectController(selectedCategoryNumber: index, delegate: self, categories: categories)
            present(categorySelectController, animated: true, completion: nil)
        }
    }
}

extension AddHabitOrEventViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var daysString: String = ""
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                as? AddTrackerCell else {return UITableViewCell()}
        
        if (indexPath.row == tableViewData.count - 1)&&(trackerType == .habit) {
            if selectedDays.count == 7 {
                daysString = "Каждый день"
            } else {
                daysString = selectedDays.map { day in
                    switch day {
                    case .monday:
                        return("Пн")
                    case .tuesday:
                        return("Вт")
                    case .wednesday:
                        return("Ср")
                    case .thursday:
                        return("Чт")
                    case .friday:
                        return("Пт")
                    case .saturday:
                        return("Сб")
                    case .sunday:
                        return("Вс")
                    }
                }.joined(separator: ", ")
            }
            if daysString.isEmpty {
                cell.updateTexts(title: "Расписание", subtitle: nil, isLastCell: true)
            } else {
                cell.updateTexts(title: "Расписание", subtitle: daysString, isLastCell: true)
            }
        } else {
            cell.updateTexts(title: "Категория", subtitle: selectedCategory?.name, isLastCell: false)
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension AddHabitOrEventViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        let maxLength = 38
        if newText.count <= maxLength {
            hideLimitLabel()
            return true
        } else {
            showLimitLabel()
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        createButtonEnableCheck()
        return true
    }
}

extension AddHabitOrEventViewController: ScheduleControllerDelegate {
    func daysDidSelected(days: [DayOfWeek])
    {
        selectedDays  = days.sorted(by: { $0.rawValue < $1.rawValue })
        tableView.reloadData()
        createButtonEnableCheck()
    }
}

extension AddHabitOrEventViewController: CategoryControllerDelegate {
    func categoryDidSelected(category: TrackerCategory) {
        selectedCategory = category
        tableView.reloadData()
        createButtonEnableCheck()
    }
}

extension AddHabitOrEventViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellType: EmojiOrColorType = indexPath.section == 0 ? .emojiType  : .colorType
        if cellType == .emojiType {
            emojiIndexPath = indexPath
        } else {
            colorIndexPath = indexPath
        }
        let cell = collectionView.cellForItem(at: indexPath) as! EmojiOrColorCell
        let text = emojies[indexPath.item]
        let color = colors[indexPath.item]
        if indexPath.section == 0 {
            cell.configureView(cellText: text, cellColor: nil, isCellSelected: indexPath == emojiIndexPath)
        } else {
            cell.configureView(cellText: nil, cellColor: color, isCellSelected: indexPath == colorIndexPath)
        }
        collectionView.reloadData()
        createButtonEnableCheck()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersSupplementaryView else {return UICollectionReusableView()}
        if indexPath.section == 0 {
            view.titleLabel.text = "Emoji"
        }  else {
            view.titleLabel.text = "Цвет"
        }
        
        return view
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
}

extension AddHabitOrEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        18
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewIdentifier, for: indexPath) as! EmojiOrColorCell
        let text = emojies[indexPath.item]
        let color = colors[indexPath.item]
        if indexPath.section == 0 {
            cell.configureView(cellText: text, cellColor: nil, isCellSelected: indexPath == emojiIndexPath)
        } else {
            cell.configureView(cellText: nil, cellColor: color, isCellSelected: indexPath == colorIndexPath)
        }
        return cell
    }
}
