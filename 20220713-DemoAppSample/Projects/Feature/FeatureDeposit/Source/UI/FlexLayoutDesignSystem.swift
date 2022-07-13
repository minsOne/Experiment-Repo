//
//  FlexLayoutDesignSystem.swift
//  FeatureDepositUI
//
//  Created by minsOne on 2022/05/02.
//  Copyright © 2022 minsone. All rights reserved.
//

import Foundation
import FlexLayout
import UIKit

extension UIView {
    public struct FlexLayoutDesignSystem {}
}

public extension UIView.FlexLayoutDesignSystem {
    static var line: UIView {
        let view = UIView()
        view.flex.addItem()
            .height(1)
            .backgroundColor(.systemGray)
        return view
    }

    static func bothSideLabel(title: String, info: String) -> BothSideLabelView {
        return BothSideLabelView(title: title, info: info)
    }
}

public class BothSideLabelView {
    private let leftLabel = UILabel()
    private let rightLabel = UILabel()

    public var container = UIView()

    init(title: String, info: String) {
        leftLabel.text = title
        rightLabel.text = info
        rightLabel.textAlignment = .right
        container.flex.direction(.row).alignContent(.spaceBetween)
        container.flex.addItem(leftLabel)
        container.flex.addItem(rightLabel).grow(1)
    }

    public func update(info: String) {
        rightLabel.text = info
    }
}

public var hasSafeArea: Bool {
    let window: UIWindow?
    if #available(iOS 13.0, *) {
        window = UIApplication.shared.windows.first
    } else {
        window = UIApplication.shared.keyWindow
    }
    return Int(window?.safeAreaInsets.bottom ?? 0) != 0
}
