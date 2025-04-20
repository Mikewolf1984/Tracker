import UIKit
import Foundation

final class EmojiOrColorCell: UICollectionViewCell {
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        //contentView.addSubview(rectView)
        //contentView.addSubview(cellTextLabel)
        //
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - public properties
    //MARK: - private properties
    private var cellType: EmojiOrColorType?
    private let rectView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .blue
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
        
    }()
    
    private let cellTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    //MARK: - override methods
    //MARK: - public methods
    
    func configureView(cellText: String?, cellColor: UIColor?, isCellSelected: Bool) {
        
        if let cellText  {
            contentView.subviews.forEach({ $0.removeFromSuperview() })
            contentView.addSubview(cellTextLabel)
            contentView.layer.cornerRadius = 16
            cellTextLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([ cellTextLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                                          cellTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])
            cellTextLabel.text = cellText
            
            contentView.layer.borderColor = UIColor.white.cgColor
            
            if isCellSelected {
                contentView.backgroundColor = YPColors.ypBackGroundColor
            } else  {
                contentView.backgroundColor = .white
            }
        }
            
        if let cellColor {
            contentView.subviews.forEach({ $0.removeFromSuperview() })
            contentView.addSubview(rectView)
            contentView.layer.cornerRadius = 8
            contentView.layer.borderWidth = 3
            rectView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([ rectView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                                          rectView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                          rectView.widthAnchor.constraint(equalToConstant: 40),
                                          rectView.heightAnchor.constraint(equalToConstant: 40)])
            rectView.layer.backgroundColor = cellColor.cgColor
            if isCellSelected {
                contentView.layer.borderColor = cellColor.withAlphaComponent(0.3).cgColor
            } else {
                contentView.layer.borderColor = UIColor.white.cgColor }
        }
    }
}
//MARK: - private methods

//MARK: - objc methods
//MARK: - extensions


