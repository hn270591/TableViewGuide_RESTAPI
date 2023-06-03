import UIKit

class BookmarkedArticleCell: UITableViewCell {
    
    private lazy var headlineLabel: UILabel = {
        let headline = UILabel()
        headline.font = .fontOfHeadline()
        headline.numberOfLines = 0
        contentView.addSubview(headline)
        return headline
    }()
    
    private lazy var thumbnailView: UIImageView = {
        let thumbnail = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 100))
        thumbnail.contentMode = .scaleToFill
        contentView.addSubview(thumbnail)
        return thumbnail
    }()
    
    private lazy var publishedDateLabel: UILabel = {
        let publishedTime = UILabel()
        publishedTime.textColor = .secondaryLabel
        publishedTime.textAlignment = .right
        publishedTime.font = .fontOfSubtitle()
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
    
    func configureUI() {
        self.headlineLabel.font = .fontOfHeadline()
        self.publishedDateLabel.font = .fontOfSubtitle()
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
        publishedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // set thumbnailView
        thumbnailView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        thumbnailView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2).isActive = true
        let thumbnailTopAnchor = thumbnailView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2)
        thumbnailTopAnchor.priority = UILayoutPriority(999)
        thumbnailTopAnchor.isActive = true
        
        // set headlineLabel
        headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        headlineLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 10).isActive = true
        headlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        
        // set publishedTimeLabel
        publishedDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3).isActive = true
        publishedDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        publishedDateLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 10).isActive = true
    }
}
