import UIKit

final class StatisticsViewController: UIViewController {
    
    //MARK: - private properties
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .black
        label.text = "Статистика"
        return label
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    
    private let dizzyView = UIImageView(image: UIImage(named: "statisticsDizzy"))
    private let dizzyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.text = "Анализировать пока нечего"
        
        return label
    }()
    private var allCount: Int = 0
    private let recordsStore = TrackerRecordStore.shared
    
    
    //MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try recordsStore.updateRecords()
        }
        catch {
            print ("Error updating store")
        }
        allCount = recordsStore.records.count
        setupTitleLabel()
        view.backgroundColor = .systemBackground
        if allCount == 0 {
            setupDizzyView()
        } else {
            configureTableView()
            tableView.dataSource = self
            tableView.delegate = self
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerRecordsDidChange),
            name: .trackerRecordsDidChange,
            object: nil
        )
    }
    //MARK: - private methods
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(44))
        ])
    }
    
    private func setupDizzyView() {
            tableView.removeFromSuperview()
            view.addSubview(dizzyView)
            view.addSubview(dizzyLabel)
            dizzyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dizzyView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                dizzyView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                dizzyView.widthAnchor.constraint(equalToConstant: 80),
                dizzyView.heightAnchor.constraint(equalToConstant: 80)
            ])
            dizzyLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dizzyLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                dizzyLabel.topAnchor.constraint(equalTo: dizzyView.bottomAnchor, constant: 8)
            ])
        
        }
    
    private func configureTableView() {
        view.addSubview(tableView)
        dizzyView.removeFromSuperview()
        dizzyLabel.removeFromSuperview()
        tableView.register(StatisticsTableViewCell.self, forCellReuseIdentifier: StatisticsTableViewCell.reuseIdentifier)
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    //MARK: - objc methods
    @objc private func handleTrackerRecordsDidChange() {
        
        allCount = recordsStore.records.count
        if allCount == 0 {
            setupDizzyView()
        } else {
            configureTableView()
            tableView.reloadData()
        }
    }
}



//MARK: - extensions

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.reuseIdentifier, for: indexPath) as? StatisticsTableViewCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            cell.configure(counter: 0, statistics: "Лучший период")
        case 1:
            cell.configure(counter: 0, statistics: "Идеальные дни")
        case 2:
            cell.configure(counter: allCount, statistics: "Трекеров завершено")
        case 3:
            cell.configure(counter: 0, statistics: "Среднее значение")
        default:
            break
        }
        return cell
    }
}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}
