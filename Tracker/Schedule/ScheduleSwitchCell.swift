import UIKit

final class ScheduleSwitchCell : UITableViewCell {
    
    //MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = ypColors.ypBackGroundColor
        selectionStyle = .none
        accessoryType = .none
        addSubview(switchView)
        switchView.onTintColor = .systemBlue
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        switchView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchView.isEnabled = true
        textLabelView.textColor = .black
        textLabelView.font = .systemFont(ofSize: 17, weight: .regular)
        addSubview(textLabelView)
        textLabelView.translatesAutoresizingMaskIntoConstraints = false
        textLabelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - public properties
    let switchView = UISwitch()
    //MARK: - private properties
    private let textLabelView = UILabel()
    private let separatorLine: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "divider"))
        imageView.tintColor = ypColors.ypGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //MARK: - public methods
    func updateTexts(title: String?, isLastCell: Bool) {
        guard let title else {return}
        textLabelView.text = title
        if !isLastCell {
            addSubview(separatorLine)
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                separatorLine.centerXAnchor.constraint(equalTo: centerXAnchor),
                separatorLine.topAnchor.constraint(equalTo: bottomAnchor),
                separatorLine.leadingAnchor.constraint(equalTo: textLabelView.leadingAnchor),
                separatorLine.trailingAnchor.constraint(equalTo: switchView.trailingAnchor),
                separatorLine.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
    func switchChangeState()
    {
        switchView.isOn.toggle()
    }
}
