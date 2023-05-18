import UIKit

class DisplaySettingsViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case displaySettings
        case textSizes
    }
    
    private var sections: [Section] = Section.allCases
    private var displaySettings: [DisplaySetting] = DisplaySetting.allCases
    private var textSettings: [TextSetting] = TextSetting.allCases
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(origin: .zero, size: view.frame.size), style: .grouped)
        tableView.register(DisplaySettingsCell.self, forCellReuseIdentifier: DisplaySettingsCell.identifier)
        tableView.register(TextSizeCell.self, forCellReuseIdentifier: TextSizeCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.sectionHeaderTopPadding = 0
        view.addSubview(tableView)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Display Settings"
        tableView.dataSource = self
        tableView.delegate = self
        
        // Notification when changed font size
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(updateUI), name: FontUpdateNotification, object: nil)
    }
    
    @objc func updateUI() {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = "Display Settings"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = nil
    }
}

// MARK: - TableView Datasource and Delegate

extension DisplaySettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .displaySettings:
            return displaySettings.count
        case .textSizes:
            return textSettings.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .displaySettings:
            return "Appearance"
        default:
            return nil
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .displaySettings:
            let cell = tableView.dequeueReusableCell(withIdentifier: DisplaySettingsCell.identifier) as! DisplaySettingsCell
            
            let setting = displaySettings[indexPath.row]
            let selected = UserDefaults.getCurrentDisplaySetting() == setting
            cell.index = indexPath.row
            cell.delegate = self
            cell.configureUI()
            cell.headlineLabel.text = setting.name
            cell.descriptionLabel.text = setting.description
            cell.isCheckmark = selected ? true : false
            return cell
        case .textSizes:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextSizeCell.identifier) as! TextSizeCell
            let textSize = textSettings[indexPath.row]
            cell.headlineLabel.font = .fontOfHeadline()
            cell.headlineLabel.text = textSize.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(red: 0.754, green: 0.786, blue: 1.000, alpha: 0.2)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .displaySettings:
            print("No handle")
        case .textSizes:
            let vcTextSize = FontSizeViewController()
            navigationController?.pushViewController(vcTextSize, animated: true)
        }
    }
}

// MARK: - DisplaySettingsCell Delegate

extension DisplaySettingsViewController: DisplaySettingsCellDelegate {
    func checkmarkImageDidTap(_ cell: DisplaySettingsCell) {
        guard let index = cell.index else { return }
        let setting = displaySettings[index]
        let section = Section.displaySettings.rawValue
        UserDefaults.setCurrentDisplaySetting(setting)
        tableView.performBatchUpdates {
            self.tableView.reloadSections(IndexSet(integer: section), with: .none)
        }
        UIView.animate(withDuration: 0.25) {
            self.view.window?.overrideUserInterfaceStyle = setting.userInterface
        }
    }
}
