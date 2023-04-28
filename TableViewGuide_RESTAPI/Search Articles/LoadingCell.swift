import UIKit

class LoadingCell: UITableViewCell {

    var activityIndicatorView = UIActivityIndicatorView()
        
    override func layoutSubviews() {
        super.layoutSubviews()
        setupIndicatorView()
    }
    
    private func setupIndicatorView() {
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        activityIndicatorView.center = contentView.center
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
        contentView.addSubview(activityIndicatorView)
    }
}
