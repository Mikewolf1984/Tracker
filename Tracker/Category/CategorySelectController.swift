import UIKit
final class CategorySelectController: UIViewController {
    
    let categories = TrackersViewController.shared.categories
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureView()
    }
    
    func configureView() {
        let safeArea = view.safeAreaLayoutGuide
        
        let topLabel = UILabel()
        topLabel.text = "Категория"
        topLabel.font  = UIFont.systemFont(ofSize: 16, weight: .medium)
        topLabel.textColor = .black
        view.addSubview(topLabel)
        
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28).isActive = true
        
        if categories.isEmpty {
            
            let dizzyImageView = UIImageView(image: UIImage(named: "dizzy"))
            view.addSubview(dizzyImageView)
            dizzyImageView.translatesAutoresizingMaskIntoConstraints = false
            dizzyImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
            dizzyImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
            dizzyImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            dizzyImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            let dizzyLabel = UILabel()
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
        } else
        {
            let tableView: UITableView = {
                let tableView: UITableView = UITableView()
                tableView.register(AddTrackerCell.self, forCellReuseIdentifier: "cell")
                tableView.layer.cornerRadius = 16
                tableView.backgroundColor = UIColor(named: "textBackGroundColor")
                tableView.separatorStyle = .singleLine
                return tableView
            }()
            view.addSubview(tableView)
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 24),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.widthAnchor.constraint(equalToConstant: view.frame.width  - 32),
                tableView.heightAnchor.constraint(equalToConstant: CGFloat(categories.count*75))])
            
            tableView.delegate = self
            tableView.dataSource = self
        }
        
    let addOrSelectButton: UIButton = {
            let button: UIButton = UIButton(type: .system)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
            button.layer.cornerRadius = 16
            button.setTitle("Добавить категорию", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.setTitleColor(.white, for: .normal)
            
            button.addTarget(self, action: #selector(addOrSelectButtonTouch), for: .touchUpInside)
            return button
        }()
        
        view.addSubview(addOrSelectButton)
        
        addOrSelectButton.translatesAutoresizingMaskIntoConstraints = false
        
        addOrSelectButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        addOrSelectButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -50).isActive = true
        addOrSelectButton.widthAnchor.constraint(equalToConstant: view.frame.width-32).isActive = true
        addOrSelectButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
    }
    
    @objc func addOrSelectButtonTouch() {
        
    }
}

extension CategorySelectController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType != .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }
}

extension CategorySelectController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddTrackerCell
        cell.updateTexts(title: categories[indexPath.row].name, subtitle: nil)
        
        return cell
    }
}
