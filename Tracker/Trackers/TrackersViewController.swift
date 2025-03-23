import UIKit

final class TrackersViewController: UIViewController {

    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTrackersView()
    }
    private func configureTrackersView() {
        let safeArea = view.safeAreaLayoutGuide
        let dizzyImageView = UIImageView(image: UIImage(named: "dizzy"))
        view.addSubview(dizzyImageView)
        dizzyImageView.translatesAutoresizingMaskIntoConstraints = false
        dizzyImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        dizzyImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
        dizzyImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        dizzyImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let dizzyLabel = UILabel()
        dizzyLabel.text = "Что будем отслеживать?"
        dizzyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dizzyLabel.textColor = .black
        view.addSubview(dizzyLabel)
        dizzyLabel.translatesAutoresizingMaskIntoConstraints = false
        dizzyLabel.centerXAnchor.constraint(equalTo: dizzyImageView.centerXAnchor).isActive = true
        dizzyLabel.topAnchor.constraint(equalTo: dizzyImageView.bottomAnchor, constant: 8).isActive = true
        
        
        let addButton: UIButton = {
            let button: UIButton = UIButton(type: .system)
            button.setImage(UIImage(named: "addButton"), for: .normal)
            button.tintColor = .black
            
            button.addTarget(self, action: #selector(addButtonTouch), for: .touchUpInside)
            return button
        }()
        
        view.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 6).isActive = true
        addButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 1).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        let datePickerButton = UIDatePicker()
        datePickerButton.datePickerMode = .date
        datePickerButton.preferredDatePickerStyle = .compact
        view.addSubview(datePickerButton)
        
        datePickerButton.translatesAutoresizingMaskIntoConstraints = false
        datePickerButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 1).isActive = true
        datePickerButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16).isActive = true
        
        let trackersLabel = UILabel()
        trackersLabel.text = "Трекеры"
        trackersLabel.font  = UIFont.systemFont(ofSize: 34, weight: .bold)
        trackersLabel.textColor = .black
        view.addSubview(trackersLabel)
        
        trackersLabel.translatesAutoresizingMaskIntoConstraints = false
        trackersLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 1).isActive = true
        trackersLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16).isActive = true
        
        let searchField = UISearchBar()
        view.addSubview(searchField)
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7).isActive = true
        searchField.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        searchField.widthAnchor.constraint(equalTo: safeArea.widthAnchor, constant: -16).isActive = true
        searchField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        searchField.searchBarStyle = .minimal
        
    }
    
    @objc func addButtonTouch() {
        let addNewTrackerViewController = AddNewTrackerViewController()
        addNewTrackerViewController.modalPresentationStyle = .automatic
        present(addNewTrackerViewController, animated: true, completion: nil)
    }
}


