import UIKit

class TrackerCollectionViewCell: UICollectionViewCell {
    
    
    private let rectView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .blue
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "collectionCellBorderColor")?.cgColor 
        return view
    }()
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "📅"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = "Название"
        return label
    }()
    private let daysCounterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = "0 дней"
        
        return label
        
    }()
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.imageView?.image = UIImage(named: "plusWhite")
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.addTarget(self, action: #selector(toggleCompleteButton), for: .touchUpInside)
        return button
    }()
    private var isCompleted: Bool = false
    private var tracker: Tracker?
    weak var delegate: CompleteButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(rectView)
        rectView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rectView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            rectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rectView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            rectView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: rectView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: rectView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: rectView.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: rectView.leadingAnchor, constant: 12),
            titleLabel.widthAnchor.constraint(equalToConstant: 143),
            titleLabel.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        contentView.addSubview(daysCounterLabel)
        daysCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysCounterLabel.topAnchor.constraint(equalTo: rectView.topAnchor, constant: 106),
            daysCounterLabel.leadingAnchor.constraint(equalTo: rectView.leadingAnchor, constant: 12),
            daysCounterLabel.widthAnchor.constraint(equalToConstant: 101),
            daysCounterLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        contentView.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completeButton.trailingAnchor.constraint(equalTo: rectView.trailingAnchor, constant: -12),
            completeButton.topAnchor.constraint(equalTo: rectView.topAnchor, constant: 100),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with tracker: Tracker, daysCount: Int, isCompleted: Bool, delegate: CompleteButtonDelegate) {
        self.delegate = delegate
        self.tracker = tracker
        rectView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        titleLabel.text = tracker.name
        var textDays: String = ""
        switch daysCount {
        case 1: textDays = "\(daysCount) день"
        case 2, 3, 4: textDays = "\(daysCount) дня"
        default: textDays = "\(daysCount) дней"
        }
        daysCounterLabel.text = textDays
        redrawCompleteButton(isCompleted: isCompleted)
    }
    
    func redrawCompleteButton(isCompleted: Bool) {
        if isCompleted {
            completeButton.setImage(UIImage(named: "doneWhite"), for: .normal)
            completeButton.backgroundColor = tracker?.color.withAlphaComponent(0.3)
        } else {
            completeButton.setImage(UIImage(named: "addButton"), for: .normal)
            completeButton.backgroundColor = tracker?.color
        }
    }
    @objc func toggleCompleteButton() {
        guard let tracker = tracker else { return }
        delegate?.didTapCompleteButton(tracker: tracker)
        redrawCompleteButton(isCompleted: !isCompleted)
    }
}

