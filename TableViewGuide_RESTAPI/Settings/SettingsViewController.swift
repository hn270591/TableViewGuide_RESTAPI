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
        setTitles()
    }
    
    func setTitles() {
        let settings: [String] = ["History"]
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcHistory = HistoryViewController()
        navigationController?.pushViewController(vcHistory, animated: true)
    }
}
