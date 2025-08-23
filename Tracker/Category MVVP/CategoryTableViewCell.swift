import UIKit

final class CategoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryTableViewCell"
    
    let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let separatorLine: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "divider"))
        imageView.tintColor = ypColors.ypGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var viewModel: CategoryViewModel?

    func configure(with viewModel: CategoryViewModel, isLastCell: Bool) {
        
        self.viewModel = viewModel
        backgroundColor = ypColors.ypBackGroundColor
        viewModel.categoryNameBinding = { [ weak self ] categoryName in
            self?.categoryNameLabel.text = categoryName
        }
        selectionStyle = .none
        contentView.addSubview(categoryNameLabel)
        NSLayoutConstraint.activate([
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
       
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.categoryNameBinding = nil
    }
}


