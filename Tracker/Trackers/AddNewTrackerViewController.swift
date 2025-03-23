import UIKit

final class AddNewTrackerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let  trackerCreateLabel: UILabel = {
            let label: UILabel = UILabel()
            label.text = "Создание трекера"
            label.textColor = .black
            label.font = .systemFont(ofSize: 16, weight: .medium)
            return label
        }()
        
        let habitCreateButton: UIButton = {
            let button: UIButton = UIButton(type: .system)
            button.setTitle("Привычка", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.backgroundColor = .black
            button.layer.cornerRadius = 16
            button.addTarget(self, action: #selector(handleAddHabit), for: .touchUpInside)
            return button
        }()
        
        let irregularEventCreateButton: UIButton = {
            let button: UIButton = UIButton(type: .system)
            button.setTitle("Нерегулярное событие", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.backgroundColor = .black
            button.layer.cornerRadius = 16
            button.addTarget(self, action: #selector(handleAddIrregularEvent), for: .touchUpInside)
            return button
        }()
        
        view.backgroundColor = .white
        view.addSubview(trackerCreateLabel)
        view.addSubview(habitCreateButton)
        view.addSubview(irregularEventCreateButton)
        
        trackerCreateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackerCreateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackerCreateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28)]
        )
        habitCreateButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            habitCreateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitCreateButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitCreateButton.widthAnchor.constraint(equalToConstant: 335),
            habitCreateButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        irregularEventCreateButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            irregularEventCreateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEventCreateButton.topAnchor.constraint(equalTo: habitCreateButton.bottomAnchor, constant: 16),
        irregularEventCreateButton.widthAnchor.constraint(equalToConstant: 335),
            irregularEventCreateButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func handleAddHabit() {
        
        let addHabitOrEventViewController = AddHabitOrEventViewController()
        addHabitOrEventViewController.trackerType = .habit
        addHabitOrEventViewController.modalPresentationStyle = .automatic
        present(addHabitOrEventViewController, animated: true, completion: nil)
    }
    
    @objc func handleAddIrregularEvent() {
        let addHabitOrEventViewController = AddHabitOrEventViewController()
        addHabitOrEventViewController.trackerType = .irregularEvent
        addHabitOrEventViewController.modalPresentationStyle = .automatic
        present(addHabitOrEventViewController, animated: true, completion: nil)
    }
    
}
