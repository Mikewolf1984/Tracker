import UIKit

enum TrackerFilter {
    case all
    case today
    case completed
    case uncompleted
}

final class FiltersViewController: UIViewController {
    
    // MARK: - public properties
    var selectedFilter: TrackerFilter?
    
    var onFilterSelected: ((TrackerFilter) -> Void)?
    
    // MARK: - private properties
    private var titleLabel: UILabel = UILabel()
    private var filtersTableView = UITableView()
    private let filters: [(String, TrackerFilter)] = [
        ("Все трекеры", .all),
        ("Трекеры на сегодня", .today),
        ("Завершенные", .completed),
        ("Незавершенные", .uncompleted),
    ]
    
   
    
    // MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTitleLabel()
        setupFiltersTableView()
    }
    
    // MARK: - private methods
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.clipsToBounds = true
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.text = "Фильтры"
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
        ])
    }
    
    private func setupFiltersTableView() {
        view.addSubview(filtersTableView)
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
        filtersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        filtersTableView.translatesAutoresizingMaskIntoConstraints = false
        filtersTableView.clipsToBounds = true
        filtersTableView.separatorStyle = .none
        filtersTableView.backgroundColor = YPColors.ypBackGroundColor
        filtersTableView.layer.cornerRadius = 16
        NSLayoutConstraint.activate([
            filtersTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filtersTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: 75 * 4)
        ])
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Colors.background
        
        if indexPath.item < 3 {
            let separatorLine: UIImageView = {
                let imageView = UIImageView(image: UIImage(named: "divider"))
                imageView.tintColor = YPColors.ypGray
                imageView.contentMode = .scaleAspectFill
                return imageView
            }()
            
            cell.contentView.addSubview(separatorLine)
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                separatorLine.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                separatorLine.topAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                separatorLine.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor, constant: -32),
                separatorLine.heightAnchor.constraint(equalToConstant: 1)
            ])
            
            
        }
        let filter = filters[indexPath.row].1
        if filter == .completed || filter == .uncompleted {
            cell.accessoryType = (filter == selectedFilter) ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = filters[indexPath.row].0
        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.row].1
        onFilterSelected?(selectedFilter)
        dismiss(animated: true)
    }
}
