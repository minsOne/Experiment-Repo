// MARK: - Generated File From Scripts

import DIContainer
import FeatureAuth
import FeatureAuthInterface

struct ContainerRegisterService {
    func register() {
        Container {
            Component(FeatureAuthInterface.AuthServiceKey.self){ FeatureAuth.AuthService() }
        }.build()
    }
}
