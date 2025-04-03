import UIKit

final class AddHabitOrEventViewController: UIViewController {
    var trackerType = TrackerType.habit
    private let emojies = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let categories = TrackersViewController.shared.categories
    private var tableViewData = ["Категория","Расписание"]
    private let colors = [UIColor(named: "selColor1 1"),UIColor(named: "selColor1 2"),UIColor(named: "selColor1 3"),UIColor(named: "selColor1 4"),UIColor(named: "selColor1 5"), UIColor(named: "selColor1 6"),UIColor(named: "selColor1 7"),UIColor(named: "selColor1 8"),UIColor(named: "selColor1 9"),UIColor(named: "selColor1 10"), UIColor(named: "selColor1 11"),UIColor(named: "selColor1 12"),UIColor(named: "selColor1 13"),UIColor(named: "selColor1 14"),UIColor(named: "selColor1 15"),UIColor(named: "selColor1 16"),UIColor(named: "selColor1 17"),UIColor(named: "selColor1 18")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureView()
    }
    private func configureView() {
        
        switch trackerType {
        case .habit: tableViewData = ["Категория","Расписание"]
        case .irregularEvent: tableViewData = ["Расписание"]
        }
        
        let  trackerTypeLabel: UILabel = {
            let label: UILabel = UILabel()
            label.textColor = .black
            label.font = .systemFont(ofSize: 16, weight: .medium)
            return label
        }()
        view.addSubview(trackerTypeLabel)
        
        trackerTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackerTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackerTypeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28)]
        )
        switch trackerType {
        case .habit: trackerTypeLabel.text = "Новая привычка"
        case .irregularEvent: trackerTypeLabel.text = "Новое нерегулярное событие"
        }
        
        let cancelButton: UIButton = {
            let button: UIButton = UIButton(type: .system)
            button.setTitle("Отменить", for: .normal)
            button.backgroundColor = .white
            button.layer.borderColor = UIColor.red.cgColor
            button.layer.borderWidth = 1
            button.setTitleColor(.red, for: .normal)
            button.layer.cornerRadius = 16
            button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
            return button
        }()
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let viewWidth = view.frame.width
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            cancelButton.widthAnchor.constraint(equalToConstant: (viewWidth-48)/2),
            cancelButton.heightAnchor.constraint(equalToConstant: 60)])
        
        let createButton: UIButton = {
            let button: UIButton = UIButton(type: .system)
            button.setTitle("Создать", for: .normal)
            button.backgroundColor = .lightGray
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 16
            button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
            return button
        }()
        view.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60)])
        
        let nameTextField: UITextField = {
            let textField: UITextField = UITextField()
            textField.placeholder = "Введите название трекера"
            textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
            textField.leftView = leftPaddingView
            textField.leftViewMode = .always
            textField.backgroundColor = UIColor(named: "textBackGroundColor")
            textField.layer.cornerRadius = 16
            return textField
        }()
        
        
        
        view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: trackerTypeLabel.bottomAnchor, constant: 38),
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.widthAnchor.constraint(equalToConstant: view.frame.width  - 32)])
        
        let tableView: UITableView = {
            let tableView: UITableView = UITableView()
            tableView.register(AddTrackerCell.self, forCellReuseIdentifier: "cell")
            tableView.layer.cornerRadius = 16
            tableView.backgroundColor = UIColor(named: "textBackGroundColor")
            tableView.separatorStyle = .singleLine
            return tableView
        }()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.widthAnchor.constraint(equalToConstant: view.frame.width  - 32),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(tableViewData.count*75))])
        
        
        
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
    
    
    
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func createButtonTapped() {
        
    }
    
    
}

extension AddHabitOrEventViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableViewData[indexPath.row] == "Расписание" {
            let scheduleSelectViewController = ScheduleSelectViewController()
            present(scheduleSelectViewController, animated: true, completion: nil)
        } else {
            
            let categorySelectController = CategorySelectController()
            present(categorySelectController, animated: true, completion: nil)
        }
    }
}

extension AddHabitOrEventViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddTrackerCell
        if indexPath.row == tableViewData.count - 1 {
            cell.updateTexts(title: "Расписание", subtitle: nil)
            
        } else {
            cell.updateTexts(title: "Категория", subtitle: categories[indexPath.row].name)
            
        }
       
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

