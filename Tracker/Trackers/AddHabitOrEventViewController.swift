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
    private let tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.register(AddTrackerCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = UIColor(named: "textBackGroundColor")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let nameTextField: UITextField = {
        let textField: UITextField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor(named: "textBackGroundColor")
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
        button.backgroundColor = UIColor(named: "ypGray") ?? .gray
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
    
    private let emojies = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private let colors = [UIColor(named: "selColor1 1"),UIColor(named: "selColor1 2"),UIColor(named: "selColor1 3"),UIColor(named: "selColor1 4"),UIColor(named: "selColor1 5"), UIColor(named: "selColor1 6"),UIColor(named: "selColor1 7"),UIColor(named: "selColor1 8"),UIColor(named: "selColor1 9"),UIColor(named: "selColor1 10"), UIColor(named: "selColor1 11"),UIColor(named: "selColor1 12"),UIColor(named: "selColor1 13"),UIColor(named: "selColor1 14"),UIColor(named: "selColor1 15"),UIColor(named: "selColor1 16"),UIColor(named: "selColor1 17"),UIColor(named: "selColor1 18")]
    
    //MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureView()
        tableView.delegate = self
        tableView.dataSource = self
        nameTextField.delegate = self
        
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
        updateConstraints()
        
        /*        let emojiesCollectionView: UICollectionView = {
         let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
         layout.scrollDirection = .vertical
         layout.itemSize = CGSize(width: 52, height: 52)
         let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
         return collectionView
         }()
         
         
         let colorsCollectionView: UICollectionView = {
         let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
         layout.scrollDirection = .vertical
         layout.itemSize = CGSize(width: 40, height: 40)
         let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
         return collectionView
         }()
         */
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
        if let text = nameTextField.text {
            conditionName = !text.isEmpty
        } else {
            conditionName = false
        }
        if let selectedCategory {conditionCategory = true
        } else {conditionCategory = false}
        conditionSchedule = !selectedDays.isEmpty
        switch trackerType {
        case .habit:
            if conditionName && conditionCategory && conditionSchedule {
                createButton.isEnabled = true
                createButton.backgroundColor = .black
            } else {
                createButton.isEnabled = false
                createButton.backgroundColor = UIColor(named: "ypGray") ?? .gray
            }
        case .irregularEvent:
            if conditionName && conditionCategory {
                createButton.isEnabled = true
                createButton.backgroundColor = .black
            } else {
                createButton.isEnabled = false
                createButton.backgroundColor = UIColor(named: "ypGray") ?? .gray
            }
        }
    }
    //MARK: - objc methods
    @objc func cancelButtonTapped() {
        delegate?.trackerDidCanceled()
        self.dismiss(animated: true)
    }
    
    @objc func createButtonTapped() {
        let newTracker: Tracker = .init(
            id: UUID(),
            type: trackerType,
            name: nameTextField.text ?? "",
            color: (colors.randomElement())!!, //Используем force unwrap потому что точно знаем, что массив цветов не пустой
            emoji: emojies.randomElement() ?? "😄",
            schedule: selectedDays,
            date: 0
        )
        guard let category = selectedCategory else { return }
        delegate?.trackerDidCreated(tracker: newTracker, category: category)
        self.dismiss(animated: true)
    }
    
    @objc func didTapClearTextButton() {
        nameTextField.text = ""
        hideLimitLabel()
    }
}
//MARK: - extensions

extension AddHabitOrEventViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddTrackerCell
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
