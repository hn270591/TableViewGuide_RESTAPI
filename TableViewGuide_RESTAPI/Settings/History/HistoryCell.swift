import UIKit

class HistoryCell: UITableViewCell {
    
    private lazy var headlineLabel: UILabel = {
        let headline = UILabel()
        headline.numberOfLines = 0
        contentView.addSubview(headline)
        return headline
    }()
    
    private lazy var thumbnailView: UIImageView = {
        let thumbnail = UIImageView()
        thumbnail.contentMode = .scaleToFill
        contentView.addSubview(thumbnail)
        return thumbnail
    }()
    
    public lazy var createdTimeLabel: UILabel = {
        let createdTime = UILabel()
        createdTime.textColor = .secondaryLabel
        createdTime.textAlignment = .right
        createdTime.font = UIFont.systemFont(ofSize: 15, weight: .light)
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // layout thumbnailView
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        thumbnailView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        thumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        
        // layout headline
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        headlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
        headlineLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 10).isActive = true
        headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true

        // layout createdTime
        createdTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        createdTimeLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 0).isActive = true
        createdTimeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        createdTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        createdTimeLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 10).isActive = true
    }
}


