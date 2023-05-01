import UIKit

class LoadingCell: UITableViewCell {
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        contentView.addSubview(indicatorView)
        return indicatorView
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = contentView.center
    }
}
