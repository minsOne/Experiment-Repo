//
//  SampleServiceViewController.swift
//  SampleFramework
//
//  Created by minsOne on 2022/01/30.
//

import RIBs
import RxSwift
import UIKit

protocol SampleServicePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class SampleServiceViewController: UIViewController, SampleServicePresentable, SampleServiceViewControllable {

    weak var listener: SampleServicePresentableListener?
}
