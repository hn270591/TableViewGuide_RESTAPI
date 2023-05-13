import UIKit
import StepSlider

class TextSizeViewController: UIViewController {
    
    @IBOutlet weak var sliderLabel: UILabel!
    private let userDefaults = UserDefaults.standard
    
    private lazy var sliderView: StepSlider = {
        let slider = StepSlider(frame: CGRect(x: 0, y: 0, width: 270, height: 30))
        slider.maxCount = 4
        slider.sliderCircleColor = .blue
        view.addSubview(slider)
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Text Size"
        setSliderView()
    }
    
    func setSliderView() {
        let index = FontStyle.setSliderIndex()
        sliderView.index = UInt(index)
        sliderView.setTrackCircleImage(UIImage(named: "unselected_dot"), for: .normal)
        sliderView.setTrackCircleImage(UIImage(named: "selected_dot"), for: .selected)
        sliderView.addTarget(self, action: #selector(sliderAction), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let font = FontStyle.setFontStyle(index: Float(sliderView.index))
        sliderLabel.text = font.1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSliderView()
    }
    
    func layoutSliderView() {
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.topAnchor.constraint(equalTo: sliderLabel.topAnchor, constant: 50).isActive = true
        sliderView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -5).isActive = true
    }
    
    @objc func sliderAction() {
        let font = FontStyle.setFontStyle(index: Float(sliderView.index))
        let currentSize = font.0, currentText = font.1
        
        // reset slider label
        sliderLabel.text = currentText
        sliderLabel.font = sliderLabel.font.withSize(CGFloat(currentSize))

        // save in userDefaults
        userDefaults.setFontStyle(size: currentSize)
    }
}
    
    
