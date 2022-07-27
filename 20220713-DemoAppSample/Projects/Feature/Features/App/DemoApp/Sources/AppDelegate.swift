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
        
        let dependencies = Dependencies()
        dependencies.add(module: .init(AuthServiceInterface.self) { AuthService() })
        dependencies.build()
        
        let container = Container()
        container.add(module: .init(AuthServiceKey.self) { AuthService() })
        container.build()
        
        let service1 = DepositBuilder().build1()
        service1.run()
        
        let service3 = DepositBuilder().build3()
        service3.run()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = RootViewController()
        window.rootViewController = UINavigationController(rootViewController: vc)
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
