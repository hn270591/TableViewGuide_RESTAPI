import UIKit

class CategoriesCell: UITableViewCell {

    public lazy var titleLabel: UILabel = {
        let title = UILabel()
        contentView.addSubview(title)
        return title
    }()
    
    public var isBookmark: Bool! {
        didSet {
            self.accessoryType = isBookmark ? .checkmark : .none
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(origin: .init(x: 20, y: 0), size: contentView.frame.size)
        selectionStyle = .none
    }
}