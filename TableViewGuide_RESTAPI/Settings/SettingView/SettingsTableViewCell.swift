import UIKit

class SettingsTableViewCell: UITableViewCell {

    lazy var headlineLabel: UILabel = {
        let headline = UILabel()
        headline.numberOfLines = 1
        contentView.addSubview(headline)
        return headline
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        headlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
    }
}