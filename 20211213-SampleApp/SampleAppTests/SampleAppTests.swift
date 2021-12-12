//
//  SampleAppTests.swift
//  SampleAppTests
//
//  Created by minsOne on 2021/12/11.
//

import Nimble
import Quick
import RxSwift
import RxTestPackage
import ThirdPartyLibraryManager
import XCTest
@testable import SampleApp

class SampleAppTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        print(try? Observable.just(10).toBlocking(timeout: 3).first())
        expect(Observable.just(42)).first(timeout: 3) == 42
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
