import UIKit
import Features
import FeatureAuth
import FeatureAuthInterface
import FeatureDeposit
import DIContainer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        let container = Container {
            Component(AuthServiceKey.self) { AuthService() }
        }
        container.build()
        
        let service = DepositBuilder().build()
        service.run()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = RootViewController()
        window.rootViewController = UINavigationController(rootViewController: vc)
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
