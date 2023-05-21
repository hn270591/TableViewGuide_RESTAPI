import UIKit

protocol DisplaySettingsCellDelegate: AnyObject {
    func checkmarkImageDidTap(_ cell: DisplaySettingsCell)
}

class DisplaySettingsCell: UITableViewCell {
    
    public lazy var headlineLabel: UILabel = {
        let headline = UILabel()
        headline.font = .fontOfHeadline()
        contentView.addSubview(headline)
        return headline
    }()
    
    private lazy var checkmarkImage: UIImageView = {
        let checkmark = UIImageView()
        checkmark.tintColor = .gray
        checkmark.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(checkmarkAction))
        checkmark.addGestureRecognizer(tap)
        contentView.addSubview(checkmark)
        return checkmark
    }()
    
    public lazy var descriptionLabel: UILabel = {
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
            let named = isCheckmark ? "checkmark.circle.fill" : "circle"
            checkmarkImage.image = imageSystem(named )
            checkmarkImage.tintColor = isCheckmark ? .tintColor : .gray
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

// MARK: - Utilities

extension UIImage.Configuration {
    static let font = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 22))
}

func imageSystem(_ named: String, config: UIImage.Configuration = .font) -> UIImage? {
    return UIImage(systemName: named, withConfiguration: config)
}
