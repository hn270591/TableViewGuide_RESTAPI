import UIKit

class TextSizeCell: UITableViewCell {

    static let identifier = "TextSizeCell"
    
    public lazy var headlineLabel: UILabel = {
        let headline = UILabel()
        contentView.addSubview(headline)
        return headline
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        headlineLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
