import UIKit

enum StatColors {
    static let redAccent = UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1)
    static let greenAccent = UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1)
    static let blueAccent = UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1)
    static let colors: [CGColor] = [
        redAccent.cgColor,
        greenAccent.cgColor,
        blueAccent.cgColor
    ]
}

final class StatisticsTableViewCell: UITableViewCell {
    
    // MARK: - public properties
    static let reuseIdentifier = "StatisticsTableViewCell"
    
    // MARK: - private properties
    private let gradientLayer = CAGradientLayer()
    private let borderMask = CAShapeLayer()
    private let statisticsCellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .black// Colors.primary
        return label
    }()
    
    private let statisticLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black // Colors.primary
        return label
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - public methods
    func configure(counter: Int, statistics: String) {
        statisticLabel.text = statistics
        switch statistics {
        case "Трекеров завершено": counterLabel.text = "\(counter)"
        default: counterLabel.text = "-"
        }
    }
    
    // MARK: - private Methods
    private func setup() {
        backgroundColor = .clear
        contentView.addSubview(statisticsCellView)
        statisticsCellView.addSubview(counterLabel)
        statisticsCellView.addSubview(statisticLabel)
        NSLayoutConstraint.activate([
            statisticsCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            statisticsCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statisticsCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            statisticsCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            counterLabel.topAnchor.constraint(equalTo: statisticsCellView.topAnchor, constant: 12),
            counterLabel.leadingAnchor.constraint(equalTo: statisticsCellView.leadingAnchor, constant: 12),
            statisticLabel.bottomAnchor.constraint(equalTo: statisticsCellView.bottomAnchor, constant: -12),
            statisticLabel.leadingAnchor.constraint(equalTo: statisticsCellView.leadingAnchor, constant: 12),
        ])
        setupGradientBorder()
    }
    
    private func setupGradientBorder() {
        gradientLayer.colors = StatColors.colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 102 - 12)
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(
            roundedRect: gradientLayer.bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: 16
        ).cgPath
        shape.lineWidth = 1
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shape
        statisticsCellView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
