import UIKit

class BookmarkedArticleCell: UITableViewCell {
    
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
    
    private lazy var publishedDateLabel: UILabel = {
        let publishedTime = UILabel()
        publishedTime.textColor = .secondaryLabel
        publishedTime.textAlignment = .right
        publishedTime.font = UIFont.systemFont(ofSize: 15, weight: .light)
        contentView.addSubview(publishedTime)
        return publishedTime
    }()
    
    var bookmarkStory: BookmarkedArticle? {
        didSet {
            guard let bookmarkStory = bookmarkStory else { return }
            let publishedDate = DateFormatter.publishedDateFormatterForArticles(dateString: bookmarkStory.publishedDate!)
            headlineLabel.text = bookmarkStory.title
            publishedDateLabel.text = publishedDate
            
            if let urlString =  bookmarkStory.imageURL, !urlString.isEmpty {
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
        // set thumbnailView
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        thumbnailView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        thumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        
        // set headlineLabel
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        headlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
        headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        headlineLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 10).isActive = true
        
        // set publishedTimeLabel
        publishedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        publishedDateLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 0).isActive = true
        publishedDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        publishedDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        publishedDateLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 10).isActive = true
    }
}
