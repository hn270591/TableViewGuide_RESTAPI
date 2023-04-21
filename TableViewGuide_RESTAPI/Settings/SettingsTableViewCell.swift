import UIKit

class SettingsTableViewCell: UITableViewCell {

    var headlineLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.accessoryType = .disclosureIndicator
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        headlineLabel.numberOfLines = 1
        contentView.addSubview(headlineLabel)
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        headlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
    }
}
