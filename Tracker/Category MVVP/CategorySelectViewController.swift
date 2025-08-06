import UIKit
final class CategorySelectController: UIViewController {
    //MARK: - init
    
    init(selectedCategoryNumber: Int?, delegate: CategoryControllerDelegate, categories: [TrackerCategory])
    {
        self.delegate = delegate
        selectedRow = selectedCategoryNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:  - public properties
    var selectedCategory: TrackerCategory?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    //MARK: - private properties
    private weak var delegate: CategoryControllerDelegate?
    private var selectedRow: Int?
    private var viewModel: CategoriesViewModel?
    private var tableViewHeight: NSLayoutConstraint?
    private let dizzyImageView: UIImageView =  {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "dizzy")
        imageView.isHidden = true
        return imageView
    }()
    private let topLabel: UILabel = {
        let topLabel: UILabel = UILabel()
        topLabel.text = "Категория"
        topLabel.font  = UIFont.systemFont(ofSize: 16, weight: .medium)
        topLabel.textColor = .black
        return topLabel
    }()
    let dizzyLabel = UILabel()
    private let tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryTableViewCell")
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = YPColors.ypBackGroundColor
        tableView.separatorStyle = .none
        tableView.isHidden = true
        return tableView
    }()
    
    private let selectButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Выбрать категорию", for: .normal)
        button.addTarget(self, action: #selector(selectButtonTouch), for: .touchUpInside)
        button.backgroundColor = .lightGray
        button.isEnabled = false
        button.isHidden = true
        return button
    }()
    
    private let addButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Добавить категорию", for: .normal)
        button.addTarget(self, action: #selector(addButtonTouch), for: .touchUpInside)
        button.backgroundColor = .black
        button.isHidden = true
        return button
    }()
    
    
    //MARK: - override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewModel = CategoriesViewModel()
        guard let viewModel else { return }
        viewModel.categoryListBinding = { [weak self] categories in
            guard let self else { return }
            checkButtonsState()
            configureView()
        }
        viewModel.categoryListBinding?(viewModel.categories)
    }
    
    //MARK: - private methods
    private func checkButtonsState() {
        if viewModel?.categories != nil {
            if viewModel?.selectedCategory != nil {
                if !addButton.isHidden {
                    addButton.isHidden = true
                    addButton.removeFromSuperview()
                }
                view.addSubview(selectButton)
                selectButton.isHidden = false
                configureButton(button: selectButton, isActive: true)
            } else {
                view.addSubview(addButton)
                addButton.isHidden = false
                configureButton(button: addButton, isActive: true)
            }
        } else {
            view.addSubview(addButton)
            addButton.isHidden = false
            configureButton(button: addButton, isActive: true)
        }
    }
    
    private func configureButton(button: UIButton, isActive: Bool) {
        let safeArea = view.safeAreaLayoutGuide
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -50).isActive = true
        button.widthAnchor.constraint(equalToConstant: view.frame.width-32).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.backgroundColor = isActive ? .black: .lightGray
        button.isEnabled = isActive
    }
    
    private func showDizzyView() {
        let safeArea = view.safeAreaLayoutGuide
        if dizzyImageView.isHidden {
            view.addSubview(dizzyImageView)
            dizzyImageView.isHidden = false
        }
        dizzyImageView.translatesAutoresizingMaskIntoConstraints = false
        dizzyImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        dizzyImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
        dizzyImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        dizzyImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        dizzyLabel.numberOfLines = 2
        dizzyLabel.textAlignment = .center
        dizzyLabel.text = "Привычки и события можно \n объединить по смыслу"
        dizzyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dizzyLabel.textColor = .black
        view.addSubview(dizzyLabel)
        dizzyLabel.translatesAutoresizingMaskIntoConstraints = false
        dizzyLabel.centerXAnchor.constraint(equalTo: dizzyImageView.centerXAnchor).isActive = true
        dizzyLabel.topAnchor.constraint(equalTo: dizzyImageView.bottomAnchor, constant: 8).isActive = true
        dizzyLabel.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    private func showTableView() {
        if tableView.isHidden {
            view.addSubview(tableView)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.isHidden = false
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 24),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.widthAnchor.constraint(equalToConstant: view.frame.width  - 32)])
            tableViewHeight = tableView.heightAnchor.constraint(equalToConstant: 0)
            tableViewHeight?.isActive = false
            tableView.layer.cornerRadius = 16
            tableView.backgroundColor = YPColors.ypBackGroundColor
            tableView.translatesAutoresizingMaskIntoConstraints = false
        }
        tableViewHeightCalc()
        tableView.reloadData()
        tableView.layoutIfNeeded()
        view.layoutIfNeeded()
    }
    private func tableViewHeightCalc() {
        guard let categoriesCount = viewModel?.categories.count else {return}
        let heigthAnchorMax = categoriesCount < 8 ? categoriesCount*75 : 75*7
        tableViewHeight?.constant = CGFloat(heigthAnchorMax)
        tableViewHeight?.isActive = true
    }
    
    private func configureView() {
        view.addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28).isActive = true
        showTableOrDizzyView()
    }
    
    private func showTableOrDizzyView()
    {
        guard let viewModel else { return }
        if (viewModel.categories.isEmpty) {
            showDizzyView()
        } else
        {
            dizzyImageView.removeFromSuperview()
            dizzyImageView.isHidden = true
            dizzyLabel.removeFromSuperview()
            showTableView()
        }
    }
    //MARK: - objc methods
    
    @objc private func selectButtonTouch() {
        guard let category = viewModel?.selectedCategory else { return}
        delegate?.categoryDidSelected(category:  category)
        dismiss(animated: true, completion: nil)
    }
    @objc private func addButtonTouch() {
        let createNewCategoryViewController = CreateNewCategoryViewController()
        createNewCategoryViewController.onCategoryCreated = { [ weak self ] category in
            guard let self else { return }
            viewModel?.addCategory(category)
            selectedCategory = category
            tableViewHeightCalc()
            checkButtonsState()
        }
        createNewCategoryViewController.modalPresentationStyle = .automatic
        present(createNewCategoryViewController, animated: true, completion: nil)
    }
}

//MARK: - extensions

extension CategorySelectController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selected = selectedRow {
            tableView.cellForRow(at: [0, selected])?.accessoryType = .none
            
        }
        selectedCategory = viewModel?.categories[indexPath.item].category
        viewModel?.selectedCategory = selectedCategory
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if !addButton.isHidden {
            addButton.isHidden = true
            addButton.removeFromSuperview()
        }
        if selectButton.isHidden {
            view.addSubview(selectButton)
            selectButton.isHidden = false
            configureButton(button: selectButton, isActive: true)
        }
    }
}

extension CategorySelectController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as? CategoryTableViewCell
        else {
            return UITableViewCell()
        }
        guard let cellToShow = viewModel?.categories[indexPath.item] else {
            return cell
        }
        guard let categoriesCount = viewModel?.categories.count else {
            return cell
        }
        cell.configure(with: cellToShow, isLastCell: indexPath.item == categoriesCount )
        if viewModel?.categories[indexPath.item].categoryName == selectedCategory?.name {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

