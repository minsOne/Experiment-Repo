//
//  SampleAppTests.swift
//  SampleAppTests
//
//  Created by minsOne on 4/13/25.
//

import Testing

struct ClassScan {
  @Test func searchDuplicateClasses() {
    let scanner = ClassScanner()
    let allClasses = scanner.searchClassList()
    let duplicatedClasses = allClasses
      .filter { $0.value > 1 }

    #expect(duplicatedClasses.isEmpty)

    print("print Duplicated classes")
    for (k, v) in duplicatedClasses {
      print("\(k): \(v)")
    }
  }
}
