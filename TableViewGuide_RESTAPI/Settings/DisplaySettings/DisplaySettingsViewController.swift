import UIKit

struct DisplaySettings {
    var headline: String
    var description: String
}

enum Titles: String {
    case automatic = "Automatic"
    case dark = "Dark"
    case light = "Light"
}

enum Description: String {
    case automatic = "User your device setting to determine appearance. The app will change modes when your device setting is changed"
    case dark = "Ignore your device setting and always render is dark mode"
    case light = "Ignore your device setting and always render is light mode"
}

class DisplaySettingsViewController: UIViewController {
    
    private let reuseIdentifier = "DisplaySettingsCell"
    private let userDefaults = UserDefaults.standard
    private var displaySettings: [String: [DisplaySettings]] = [:]
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DisplaySettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 100
        return tableView
    }()
    
    override func loadView() {
         view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Display Settings"
        tableView.dataSource = self
        initDisplaySettings()
    }
    
    func initDisplaySettings() {
        let automatic = DisplaySettings(headline: Titles.automatic.rawValue, description: Description.automatic.rawValue)
        let dark = DisplaySettings(headline: Titles.dark.rawValue, description: Description.dark.rawValue)
        let light = DisplaySettings(headline: Titles.light.rawValue, description: Description.light.rawValue)
        
        let headlineForSection = "APPEARANCE"
        let displaySettings = [headlineForSection: [automatic, dark, light] ]
        self.displaySettings = displaySettings
    }
}

// MARK: - TableView Datasource and Delegate

extension DisplaySettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return displaySettings.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let values = Array(displaySettings.values)[section]
        return values.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keys = Array(Array(displaySettings.keys))
        return keys[section]
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! DisplaySettingsCell
        let values = Array(Array(displaySettings.values))[indexPath.section]
        let displaySettings = values[indexPath.row]
        
        cell.index = indexPath.row
        cell.delegate = self
        cell.displaySettings = displaySettings
        cell.isCheckmark = userDefaults.getIsCheckmark()[indexPath.row]
        return cell
    }
}

// MARK: - DisplaySettingsCell Delegate

extension DisplaySettingsViewController: DisplaySettingsCellDelegate {
    func checkmarkImageDidTap(_ cell: DisplaySettingsCell) {
        UserInterfaceStyle.changeStyle(style: .setIndex(index: cell.index!))
        tableView.reloadData()
    }
}
