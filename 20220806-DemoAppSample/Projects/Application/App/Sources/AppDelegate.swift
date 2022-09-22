import UIKit
import Features
import FeatureAuth
import FeatureDeposit
import UIThirdPartyLibraryManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        ContainerRegisterService()
            .register()
        
        let vc = RootViewController()
        vc.view.backgroundColor = .systemRed
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: vc)
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}
