import UIKit

class AddTrackerCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .textBackGround
        self.accessoryType = .none
    }
    
    func updateTexts(title: String?, subtitle: String?) {
        if #available(iOS 14.0, *) {
            var content = self.defaultContentConfiguration()
            if let title {
                content.text = title }
            content.textProperties.font = .systemFont(ofSize: 17, weight: .medium)
            if let subtitle {
                content.secondaryText = subtitle
                content.secondaryTextProperties.font = .systemFont(ofSize: 13,weight: .medium)
                content.secondaryTextProperties.color = .lightGray }
            self.contentConfiguration = content
        } else {
            self.textLabel?.text = "Add Tracker"
            self.detailTextLabel?.text  = "Add a new tracker"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
