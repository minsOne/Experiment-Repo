// MARK: - Generated File From Scripts

import DIContainer
import FeatureAuth
import FeatureAuthInterface
import FeatureDemandDepositInterface
import FeatureDemandDepositPackage

struct ContainerRegisterService {
    func register() {
        Container {
            Component(FeatureAuthInterface.AuthServiceKey.self){ FeatureAuth.AuthService() }
            Component(FeatureDemandDepositInterface.RootComponentFactoryKey.self) { FeatureDemandDepositPackage.RootComponentFactoryImpl() }
        }.build()
    }
}
