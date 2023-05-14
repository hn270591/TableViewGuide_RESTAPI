import UIKit

class SettingsViewController: UIViewController {

    private let reuseIdentifier = "SettingsTableViewCell"
    private var settings: [String] = []
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(origin: .zero, size: view.bounds.size), style: .insetGrouped)
        tableView.rowHeight = 50
        view.addSubview(tableView)
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView.dataSource = self
        tableView.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        initSettings()
        
        // Notification when changed font size
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(updateUI), name: FontUpdateNotification, object: nil)
    }
    
    @objc func updateUI() {
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func initSettings() {
        let settings: [String] = ["History", "Display Settings"]
        self.settings = settings
    }
}

// MARK: - TableViewDataSource and Delegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsTableViewCell
        cell.headlineLabel.text = settings[indexPath.row]
        
        // Notification when changed font size
        let notification = NotificationCenter.default
        notification.addObserver(forName: FontUpdateNotification, object: nil, queue: .main) { _ in
            cell.headlineLabel.font = .fontOfHeadline()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcHistory = HistoryViewController()
        let vcDisplay = DisplaySettingsViewController()
        let vc: [UIViewController] = [vcHistory, vcDisplay]
        let vcPresent = vc[indexPath.row]
        navigationController?.pushViewController(vcPresent, animated: true)
    }
}
