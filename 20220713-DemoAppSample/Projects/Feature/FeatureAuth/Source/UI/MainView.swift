//
//  MainView.swift
//  FeatureDepositUI
//
//  Created by minsOne on 2022/05/02.
//  Copyright © 2022 minsone. All rights reserved.
//

import UIKit
import PinLayout
import FlexLayout

class MainView: UIView {
    let rootFlexContainer = UIView()
    let footerFlexButtonContainer = UIView()
    let titleLabel = UILabel()
    let msgLabel = UILabel()
    var 계좌종류View: BothSideLabelView?
    let confirmButton = UIButton()
    let menuBtn1 = UIButton()
    let menuBtn2 = UIButton()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white

        rootFlexContainer.flex.direction(.column)

        confirmButton.setTitle("체크카드 신청하러 가기", for: .normal)
        footerFlexButtonContainer.clipsToBounds = true

        if hasSafeArea {
            footerFlexButtonContainer.flex.margin(0, 16, 0, 16)
                .view?.layer.cornerRadius = 10
        }
        footerFlexButtonContainer.flex.define { flex in
            flex.addItem(confirmButton)
                .width(100%)
                .height(100%)
                .backgroundColor(.systemBlue)
        }

        addSubview(rootFlexContainer)
        addSubview(footerFlexButtonContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Layout the flexbox container using PinLayout
        // NOTE: Could be also layouted by setting directly rootFlexContainer.frame
        rootFlexContainer.pin.top(pin.safeArea).horizontally(pin.safeArea)
        rootFlexContainer.flex.layout(mode: .adjustHeight)

        footerFlexButtonContainer.pin.bottom(pin.safeArea).horizontally(pin.safeArea).height(60)

        // Then let the flexbox container layout itself
        rootFlexContainer.flex.layout()
        footerFlexButtonContainer.flex.layout()
    }

    func update(message: String) {
        msgLabel.text = message
        msgLabel.flex.markDirty()
        rootFlexContainer.flex.layout()
    }

    func update(계좌종류: String) {
        self.계좌종류View?.update(info: 계좌종류)
        self.계좌종류View?.container.flex.markDirty()
        rootFlexContainer.flex.layout()
    }

    func update(title: String,
                message: String,
                계좌종류: String,
                일일_이체한도: String,
                일회_이체한도: String) {
        titleLabel.textAlignment = .center
        msgLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        msgLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 30)
        msgLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.text = title
        msgLabel.text = message

        let 계좌종류View = FlexLayoutDesignSystem.bothSideLabel(title: "계좌종류", info: 계좌종류)
        self.계좌종류View = 계좌종류View

        let 일일이체한도View = FlexLayoutDesignSystem.bothSideLabel(title: "1일 이체한도", info: 일일_이체한도)
        let 일회이체한도View = FlexLayoutDesignSystem.bothSideLabel(title: "1회 이체한도", info: 일회_이체한도)
        menuBtn1.setTitle("메인으로 이동", for: .normal)
        menuBtn2.setTitle("닫기", for: .normal)

        rootFlexContainer.flex.define { flex in
            flex.addItem().define { flex in
                flex.addItem(titleLabel)
                flex.addItem()
                    .height(16)
                flex.addItem(msgLabel)
                flex.addItem()
                    .height(30)
            }

            flex.addItem().define { flex in
                flex.addItem(FlexLayoutDesignSystem.line)
                flex.addItem(계좌종류View.container)
                    .margin(8, 0, 8, 0)
                flex.addItem(FlexLayoutDesignSystem.line)
                flex.addItem(일일이체한도View.container)
                    .margin(8, 0, 8, 0)
                flex.addItem(FlexLayoutDesignSystem.line)
                flex.addItem(일회이체한도View.container)
                    .margin(8, 0, 8, 0)
                flex.addItem(FlexLayoutDesignSystem.line)
            }

            flex.addItem().height(24)

            flex.addItem().define { flex in
                flex.direction(.row)
                flex.addItem(menuBtn1)
                    .grow(1)
                    .backgroundColor(.systemGray)
                flex.addItem()
                    .width(16)
                flex.addItem(menuBtn2)
                    .grow(1)
                    .backgroundColor(.systemGreen)
            }
            .height(60)
        }.margin(0, 24, 0, 24)
    }
}

