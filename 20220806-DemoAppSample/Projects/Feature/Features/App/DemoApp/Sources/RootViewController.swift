import Foundation
import UIKit

public class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    enum Row: Int, CaseIterable {
        case row1, row2
        var title: String {
            switch self {
                case .row1: return "Row1"
                case .row2: return "Row2"
            }
        }
    }

    let tableView = UITableView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Row(rawValue: indexPath.row) {
            case .row1: break
            case .row2: break
            default: break
        }
    }
}

extension RootViewController {
    func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { Row.allCases.count }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = Row(rawValue: indexPath.row)?.title
        return cell
    }
}
