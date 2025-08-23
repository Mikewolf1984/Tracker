import UIKit


final class ScheduleSelectViewController: UIViewController {
    //MARK: - Init
    init(selectedDays: [DayOfWeek], delegate: ScheduleControllerDelegate?) {
        self.selectedDays = selectedDays
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - private properties
    private let daysOfWeek: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private var selectedDays: [DayOfWeek]
    weak var delegate: ScheduleControllerDelegate?
    
    //MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    //MARK: - private methods
    private func configureView() {
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
            tableView.backgroundColor = ypColors.ypBackGroundColor
            tableView.separatorStyle = .none
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
    
    //MARK: - objc methods
    @objc  private func readyButtonTouch() {
        delegate?.daysDidSelected(days: selectedDays)
        dismiss(animated: true)
    }
}

//MARK: - extensions

extension ScheduleSelectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ScheduleSwitchCell else {return}
        cell.switchChangeState()
        let day = daysOfWeek[indexPath.row]
        if let index = selectedDays.firstIndex(of: day) {
            selectedDays.remove(at: index)
        } else {
            selectedDays.append(daysOfWeek[indexPath.row])
        }
    }
}

extension ScheduleSelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleSwitchCell",for: indexPath)
                as? ScheduleSwitchCell else {return UITableViewCell(style: .default, reuseIdentifier: "scheduleSwitchCell")}
        cell.switchView.isOn = selectedDays.contains(daysOfWeek[indexPath.row])
        cell.updateTexts(title: daysOfWeek[indexPath.row].nameOfDay, isLastCell: indexPath.row == 7)
        return cell
    }
}
