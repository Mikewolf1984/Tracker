import UIKit

class ScheduleSwitchCell : UITableViewCell {
    
    private let switchView = UISwitch()
    private let textLabelView = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .textBackGround
        self.selectionStyle = .none
        self.accessoryType = .none
        
        addSubview(switchView)
        switchView.onTintColor = .systemBlue
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        switchView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchView.isEnabled = true
        textLabelView.textColor = .black
        textLabelView.font = .systemFont(ofSize: 17, weight: .medium)
        addSubview(textLabelView)
        textLabelView.translatesAutoresizingMaskIntoConstraints = false
        textLabelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
    }
    
    func updateTexts(title: String?) {
        guard let title else {return}
        textLabelView.text = title
    }
    
    func switchChangeState()
    {
        switchView.isOn.toggle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
