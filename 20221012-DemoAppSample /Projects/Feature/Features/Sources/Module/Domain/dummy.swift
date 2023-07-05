import FeaturesInterface
import FeatureAuthInterface
import FeatureDeposit

struct SampleService: FeatureDeposit.SampleInterface, FeatureAuthInterface.SampleInterface {
    func sample() {
        
    }
}
