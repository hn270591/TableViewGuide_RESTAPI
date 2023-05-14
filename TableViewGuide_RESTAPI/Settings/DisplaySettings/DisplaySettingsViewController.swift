import UIKit

struct structTableSection {
    var header: String!
    var cells: [Any]!
    var showHeader: Bool!
}

class DisplaySettingsViewController: UIViewController {
    
    private var tableData: [structTableSection] = []
    private let userDefaults = UserDefaults.standard
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DisplaySettingsCell.self, forCellReuseIdentifier: DisplaySettingsCell.identifier)
        tableView.register(TextSizeCell.self, forCellReuseIdentifier: TextSizeCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.sectionHeaderTopPadding = 0
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
        tableView.delegate = self
        setTableDate()
        
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
    
    func setTableDate() {
        let displaySettingsSection = structTableSection(header: DisplaySettings.header ,
                                                 cells: DisplaySettings.getDisplaySettingsArray(),
                                                 showHeader: true)
        let textSizeSection = structTableSection(header: TextSize.header,
                                          cells: TextSize.getTextSizeArray(),
                                          showHeader: false)
        tableData.append(displaySettingsSection)
        tableData.append(textSizeSection)
    }
}

// MARK: - TableView Datasource and Delegate

extension DisplaySettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !tableData[section].showHeader {
            return " "
        }
        return tableData[section].header
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: DisplaySettingsCell.identifier) as! DisplaySettingsCell
            let displaySettingsArray = tableData[indexPath.section].cells as! [DisplaySettings]
            
            cell.index = indexPath.row
            cell.delegate = self
            cell.displaySettings = displaySettingsArray[indexPath.row]
            
            if indexPath.section == 0 {
                let headline = displaySettingsArray[indexPath.row].headline!
                let userInterfaceStyle = userDefaults.getUserInterfaceStyle().rawValue
                cell.isCheckmark = headline == userInterfaceStyle ? true : false
            }
            
            // Notification when changed font size
            let notification = NotificationCenter.default
            notification.addObserver(forName: FontUpdateNotification, object: nil, queue: .main) { _ in
                cell.configureUI()
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextSizeCell.identifier) as! TextSizeCell
            let textSizeArray = tableData[indexPath.section].cells as! [TextSize]
            cell.textSize = textSizeArray[indexPath.row]
            
            // Notification when changed font size
            let notification = NotificationCenter.default
            notification.addObserver(forName: FontUpdateNotification, object: nil, queue: .main) { _ in
                cell.configureUI()
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(cgColor: CGColor(red: 0.754, green: 0.786, blue: 1.000, alpha: 0.2))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            return
        }
        
        let vcTextSize = FontSizeViewController()
        navigationController?.pushViewController(vcTextSize, animated: true)
    }
}

// MARK: - DisplaySettingsCell Delegate

extension DisplaySettingsViewController: DisplaySettingsCellDelegate {
    func checkmarkImageDidTap(_ cell: DisplaySettingsCell) {
        UserInterfaceStyle.changeStyle(style: .setIndex(index: cell.index!))
        tableView.reloadData()
    }
}
