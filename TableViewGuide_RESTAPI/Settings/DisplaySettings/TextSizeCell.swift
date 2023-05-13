import UIKit

class TextSizeCell: UITableViewCell {

    static let identifier = "TextSizeCell"
    
    lazy var headlineLabel: UILabel = {
        let headline = UILabel()
        headline.font = .fontOfHeadline()
        contentView.addSubview(headline)
        return headline
    }()
    
    public var textSize: TextSize! {
        didSet {
            headlineLabel.text = textSize.headline
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        headlineLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

}
