import UIKit
import StepSlider

let FontUpdateNotification = Notification.Name("TextSizeViewController.fontUpdated")

class FontSizeViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var sliderView: StepSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Text Size"
        setSliderView()
    }
    
    func setSliderView() {
        let index = UserDefaults.getCurrentFontSize().index
        sliderView.index = index
        sliderView.setTrackCircleImage(UIImage(named: "unselected_dot"), for: .normal)
        sliderView.setTrackCircleImage(UIImage(named: "selected_dot"), for: .selected)
        sliderView.addTarget(self, action: #selector(sliderAction), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fontSize = UserDefaults.getCurrentFontSize()
        sliderLabel.font = UIFont.systemFont(ofSize: fontSize.size)
        sliderLabel.text = fontSize.name
    }
    
    @objc func sliderAction() {
        let index = Int(sliderView.index)
        let fontSize = FontSize.size(index: index)
        // reset slider label
        sliderLabel.text = fontSize.name
        sliderLabel.font = sliderLabel.font.withSize(CGFloat(fontSize.size))

        // save in userDefaults
        UserDefaults.setCurrentFontSize(fontSize)

        // Notification
        NotificationCenter.default.post(name: FontUpdateNotification, object: self)
    }
}
