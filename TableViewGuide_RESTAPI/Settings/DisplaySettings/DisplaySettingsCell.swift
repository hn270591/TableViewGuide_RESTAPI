import UIKit

protocol DisplaySettingsCellDelegate: AnyObject {
    func checkmarkImageDidTap(_ cell: DisplaySettingsCell)
}

class DisplaySettingsCell: UITableViewCell {
    
    static let identifier = "DisplaySettingsCell"

    private lazy var headlineLabel: UILabel = {
        let headline = UILabel()
        headline.font = .fontOfHeadline()
        contentView.addSubview(headline)
        return headline
    }()
    
    private lazy var checkmarkImage: UIImageView = {
        let checkmark = UIImageView()
        checkmark.tintColor = .lightGray
        checkmark.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(checkmarkAction))
        checkmark.addGestureRecognizer(tap)
        contentView.addSubview(checkmark)
        return checkmark
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let description = UILabel()
        description.numberOfLines = 0
        description.textColor = .secondaryLabel
        description.font = .fontOfSubtitle()
        contentView.addSubview(description)
        return description
    }()
    
    public var index: Int?
    public weak var delegate: DisplaySettingsCellDelegate!
    public var isCheckmark: Bool! {
        didSet {
            checkmarkImage.image = isCheckmark ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        }
    }
    
    public var displaySettings: DisplaySettings! {
        didSet {
            headlineLabel.text = displaySettings.headline
            descriptionLabel.text = displaySettings.description
        }
    }
    
    func configureUI() {
        self.headlineLabel.font = .fontOfHeadline()
        self.descriptionLabel.font = .fontOfSubtitle()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // set checkmarkImage
        checkmarkImage.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        checkmarkImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        checkmarkImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        checkmarkImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        
        // set headlineLabel
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        headlineLabel.leadingAnchor.constraint(equalTo: checkmarkImage.trailingAnchor, constant: 10).isActive = true
        
        // set descriptionLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 5).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: checkmarkImage.trailingAnchor, constant: 10).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3).isActive = true
    }
    
    @objc private func checkmarkAction() {
        isCheckmark = true
        delegate?.checkmarkImageDidTap(self)
    }
}
