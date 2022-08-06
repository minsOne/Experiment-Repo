//
//  FeaturesTests.swift
//  FeaturesTests
//
//  Created by minsOne on 2022/08/06.
//  Copyright © 2022 minsone. All rights reserved.
//

@testable import DIContainer
import XCTest
import FeatureAuthInterface

final class FeaturesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_Container에_객체가_등록되어있는지_확인() {
        XCTAssertNotNil(AuthServiceKey.module?.resolve() as? AuthServiceKey.Value)
    }
}

extension InjectionKey {
    static var module: Component? {
        return Container.root.modules[String(describing: Self.self)]
    }
}
