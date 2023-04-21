import UIKit

class SettingsViewController: UIViewController {

    private var tableView: UITableView!
    private let reuseIdentifier = "SettingsTableViewCell"
    private var settings: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Settings"
        setTitles()
    }
    
    private func setTitles() {
        let settings: [String] = ["History"]
        self.settings = settings
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect(origin: .zero, size: view.bounds.size), style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        view.addSubview(tableView)
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
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
