import UIKit

class HistoryCell: UITableViewCell {
    
    private lazy var headlineLabel: UILabel = {
        let headline = UILabel()
        headline.numberOfLines = 0
        headline.font = .fontOfHeadline()
        contentView.addSubview(headline)
        return headline
    }()
    
    private lazy var thumbnailView: UIImageView = {
        let thumbnail = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 120))
        thumbnail.contentMode = .scaleToFill
        contentView.addSubview(thumbnail)
        return thumbnail
    }()
    
    public lazy var createdTimeLabel: UILabel = {
        let createdTime = UILabel()
        createdTime.textColor = .secondaryLabel
        createdTime.textAlignment = .right
        createdTime.font = .fontOfSubtitle()
        contentView.addSubview(createdTime)
        return createdTime
    }()
    
    var readArticle: ReadArticle? {
        didSet {
            guard let readArticle = readArticle else { return }
            headlineLabel.text = readArticle.title
            if let urlString =  readArticle.imageURL, !urlString.isEmpty {
                let url = URL(string: urlString)!
                thumbnailView.downloadImage(url: url)
            } else {
                thumbnailView.image = UIImage(systemName: "photo")
                thumbnailView.tintColor = .lightGray
            }
        }
    }
    
    func configureUI() {
        self.headlineLabel.font = .fontOfHeadline()
        self.createdTimeLabel.font = .fontOfSubtitle()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        createdTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // layout thumbnailView
        thumbnailView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        thumbnailView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2).isActive = true
        let thumbnailTopAnchor = thumbnailView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2)
        thumbnailTopAnchor.priority = UILayoutPriority(999)
        thumbnailTopAnchor.isActive = true
        
        // layout headline
        headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10).isActive = true
        headlineLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 10).isActive = true
        headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        headlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true

        // layout createdTime
        createdTimeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3).isActive = true
        createdTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        createdTimeLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 10).isActive = true
    }
}


