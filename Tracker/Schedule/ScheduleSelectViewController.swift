import UIKit

final class ScheduleSelectViewController: UIViewController {
    
    private let daysOfWeek = ["Понедельник",
                              "Вторник",
                              "Среда",
                              "Четверг",
                              "Пятница",
                              "Суббота",
                              "Воскресенье"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .white
        let topLabel = UILabel()
        topLabel.text = "Расписание"
        topLabel.font  = UIFont.systemFont(ofSize: 16, weight: .medium)
        topLabel.textColor = .black
        view.addSubview(topLabel)
        
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28).isActive = true
        
        
        let tableView: UITableView = {
            let tableView: UITableView = UITableView()
            tableView.register(ScheduleSwitchCell.self, forCellReuseIdentifier: "scheduleSwitchCell")
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
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(7*75))])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let readyButton: UIButton = {
            let button: UIButton = UIButton(type: .system)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
            button.layer.cornerRadius = 16
            button.setTitle("Готово", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.setTitleColor(.white, for: .normal)
            
            button.addTarget(self, action: #selector(readyButtonTouch), for: .touchUpInside)
            return button
        }()
        
        view.addSubview(readyButton)
        
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        
        readyButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        readyButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -50).isActive = true
        readyButton.widthAnchor.constraint(equalToConstant: view.frame.width-32).isActive = true
        readyButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
    }
    
    @objc func readyButtonTouch() {
        dismiss(animated: true)
    }
}

extension ScheduleSelectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ScheduleSwitchCell
        cell.switchChangeState()
   
    }
}

extension ScheduleSelectViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleSwitchCell", for: indexPath) as! ScheduleSwitchCell
        cell.updateTexts(title: daysOfWeek[indexPath.row])
        return cell
    }
}
