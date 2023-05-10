import UIKit
import Kingfisher
import Alamofire
import AlamofireImage

extension UIImageView {
    
    // MARK: - download thumbnail by Kingfisher
    
    func downloadImage(url: URL) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url,
                              placeholder: UIImage(named: "placeholderImage"),
                              options: [
                                .scaleFactor(UIScreen.main.scale),
                                .cacheOriginalImage,
                                .transition(.fade(0.25))
                              ])
    }
    
    // MARK: - download thumbnail by AlamofireImage
    
    func downloadThumbnail(url: URL) {
        AF.request(url).responseImage { response in
            switch response.result {
            case .success(_):
                let image: UIImage! = response.value
                DispatchQueue.main.async {
                    self.image = image
                }
            case .failure(let error):
                print("Error Occured: \(error.localizedDescription)")
            }
        }
    }
}


