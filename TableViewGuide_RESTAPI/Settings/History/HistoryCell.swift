import UIKit

class HistoryCell: UITableViewCell {
    
    private var headlineLabel = UILabel()
    private var thumbnailView = UIImageView()
    
    var readArticle: ReadArticle? {
        didSet {
            guard let readArticle = readArticle else { return }
            headlineLabel.text = readArticle.title
            if let urlString =  readArticle.imageURL {
                let url = URL(string: urlString)!
                thumbnailView.downloadImage(url: url)
            } else {
                thumbnailView.image = UIImage(systemName: "photo")
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
        thumbnailView.image = nil
        thumbnailView.contentMode = .scaleToFill
        contentView.addSubview(thumbnailView)
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        thumbnailView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        thumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        
        headlineLabel.numberOfLines = 0
        contentView.addSubview(headlineLabel)
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        headlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10).isActive = true
        headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        headlineLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 10).isActive = true
    }
}
