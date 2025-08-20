import UIKit

final class CreateNewCategoryViewController: UIViewController {
    
    // MARK: - public properties
    var category: TrackerCategory?
    
    var categoryName: String?
    
    var onCategoryCreated: ((TrackerCategory) -> Void)?
    
    // MARK: - private properties
    private let categoryNameMaxLength = 38
    private let categoryStore = TrackerCategoryStore.shared
    private let dataProvider = TrackersDataProvider.shared
    private var titleLabel: UILabel = UILabel()
    private var categoryNameTextField: UITextField = UITextField()
    private var createCategoryButton: UIButton = UIButton(type: .system)
    private lazy var categoryNameFieldWarningMessage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .red
        return label
    }()
    private var shouldShowWarningCell = false
    
    // MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTitleLabel()
        setupCategoryNameTextField()
        setupCategoryNameFieldWarningMessage()
        setupCreateCategoryButton()
        toggleWarningMessage()
        createCategoryButton.isEnabled = false
    }
    
    // MARK: - private Methods
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.clipsToBounds = true
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.text = "Новая категория"
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
        ])
    }
    
    private func setupCategoryNameTextField() {
        categoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryNameTextField.clipsToBounds = true
        categoryNameTextField.placeholder = "Введите название категории"
        categoryNameTextField.font = .systemFont(ofSize: 17)
        categoryNameTextField.textColor = .black
        categoryNameTextField.backgroundColor = YPColors.ypBackGroundColor
        categoryNameTextField.layer.cornerRadius = 16
        categoryNameTextField.layer.borderWidth = 0
        categoryNameTextField.delegate = self
        categoryNameTextField.addTarget(self, action: #selector(categoryNameTextFieldDidChange), for: .editingChanged)
        
        let paddingView = UIView(
            frame: CGRect(
                x: 0, y: 0, width: 16, height: categoryNameTextField.frame.height))
        categoryNameTextField.leftView = paddingView
        categoryNameTextField.rightView = paddingView
        categoryNameTextField.leftViewMode = .always
        categoryNameTextField.rightViewMode = .always
        view.addSubview(categoryNameTextField)
        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
        ])
    }
    
    private func setupCategoryNameFieldWarningMessage() {
        view.addSubview(categoryNameFieldWarningMessage)
        NSLayoutConstraint.activate([
            categoryNameFieldWarningMessage.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor, constant: 8),
            categoryNameFieldWarningMessage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryNameFieldWarningMessage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryNameFieldWarningMessage.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupCreateCategoryButton() {
        createCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        createCategoryButton.setTitle("Готово", for: .normal)
        createCategoryButton.setTitleColor(.white, for: .normal)
        createCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createCategoryButton.backgroundColor = .black
        createCategoryButton.layer.cornerRadius = 16
        createCategoryButton.addTarget(self, action: #selector(createCategoryButtonTapped), for: .touchUpInside)
        view.addSubview(createCategoryButton)
        NSLayoutConstraint.activate([
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func toggleWarningMessage() {
        categoryNameFieldWarningMessage.isHidden = !shouldShowWarningCell
    }
    
    @objc private func createCategoryButtonTapped() {
        guard let categoryName = categoryNameTextField.text, !categoryName.isEmpty else { return }
        do {
            let newCategory = try categoryStore.createCategory(name: categoryName)
            onCategoryCreated?(newCategory)
            //dataProvider.refreshStore()
            self.dismiss(animated: true)
        } catch {
            print("Error creating category: \(error)")
        }
    }
    //MARK: - objc methods
    
    @objc private func categoryNameTextFieldDidChange() {
        let hasText = !(categoryNameTextField.text?.isEmpty ?? true)
        createCategoryButton.isEnabled = hasText
        createCategoryButton.alpha = hasText ? 1 : 0.3
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - extensions
extension CreateNewCategoryViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(
            in: stringRange, with: string)
        if updatedText.count <= categoryNameMaxLength {
            categoryName = updatedText
            if shouldShowWarningCell {
                shouldShowWarningCell = false
                toggleWarningMessage()
            }
            return true
        } else {
            if !shouldShowWarningCell {
                shouldShowWarningCell = true
                toggleWarningMessage()
            }
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

