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
        let vc = RootViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: vc)
        self.window = window
        
        return true
    }
}
