import UIKit

final class AddTrackerCell: UITableViewCell {
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = ypColors.ypBackGroundColor
        accessoryType = .none
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - private properties
    private let separatorLine: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "divider"))
        imageView.tintColor = ypColors.ypGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //MARK: - public methods
    func updateTexts(title: String?, subtitle: String?, isLastCell: Bool) {
        if #available(iOS 14.0, *) {
            var content = defaultContentConfiguration()
            if let title {
                content.text = title }
            content.textProperties.font = .systemFont(ofSize: 17, weight: .regular)
            if let subtitle {
                content.secondaryText = subtitle
                content.secondaryTextProperties.font = .systemFont(ofSize: 17,weight: .regular)
                content.secondaryTextProperties.color = .lightGray }
            contentConfiguration = content
        } else {
            textLabel?.text = title
            detailTextLabel?.text  = subtitle
        }
        if !isLastCell {
            addSubview(separatorLine)
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                separatorLine.centerXAnchor.constraint(equalTo: centerXAnchor),
                separatorLine.topAnchor.constraint(equalTo: bottomAnchor),
                separatorLine.widthAnchor.constraint(equalTo: widthAnchor, constant: -32),
                separatorLine.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
}
