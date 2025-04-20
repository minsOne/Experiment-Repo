//
//  ClassScanner.swift
//  SampleApp
//
//  Created by minsOne on 4/13/25.
//

import Foundation
import ObjectiveC.runtime

struct ClassScanner {
  private var classPtrInfo: (classesPtr: UnsafeMutablePointer<AnyClass>,
                             numberOfClasses: Int)?
  {
    let numberOfClasses = Int(objc_getClassList(nil, 0))
    guard numberOfClasses > 0 else { return nil }

    let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
    let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
    let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
    assert(numberOfClasses == count)

    return (classesPtr, numberOfClasses)
  }

  func searchClassList() -> [String: UInt] {
    guard
      let (classesPtr, numberOfClasses) = classPtrInfo
    else { return [:] }

    defer { classesPtr.deallocate() }

    var list = [String: UInt]()

    for i in 0 ..< numberOfClasses {
      let cls: AnyClass = classesPtr[i]
      let clsName = NSStringFromClass(cls)
      if let count = list[clsName] {
        list[clsName] = count + 1
      } else {
        list[clsName] = 1
      }
    }

    return list
  }
}
