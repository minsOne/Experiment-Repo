import Foundation
import UIKit
import DIContainer
import FeatureDemandDepositInterface
import SharedThirdPartyLibraryManager

final class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RootDependency, RootListener {
    func requestListener() {
        
    }
    
    var router: RootRouting?
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Row(rawValue: indexPath.row) {
        case .row1:
            aaa()
        case .row2: break
        default: break
        }
    }
    
    func aaa() {
        @Inject(RootComponentFactoryKey.self)
        var factory: RootComponentFactoryKey.Value
        let router = factory.makeBuilder(dependency: self).build(withListener: self)
        router.interactable.activate()
        router.load()
        self.router = router
        present(router.viewControllable.uiviewController, animated: true)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { Row.allCases.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = Row(rawValue: indexPath.row)?.title
        return cell
    }
}
