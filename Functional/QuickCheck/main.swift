//
//  main.swift
//  QuickCheck
//
//  Created by 綦 on 2021/7/12.
//

import Foundation


// QuickCheck
protocol Arbitrary {
    static func arbitrary() -> Self
}

extension Int: Arbitrary {
    static func arbitrary() -> Int {
        Int(arc4random())
    }
    static func random(from: Int, to: Int) -> Int {
        from + arbitrary()%(to - from)
    }
}

extension Character: Arbitrary {
    static func arbitrary() -> Character {
        Character(Unicode.Scalar(Int.random(from: 65, to: 90))!)
    }
}

extension String: Arbitrary {
    static func arbitrary() -> String {
        let randomLength = Int.random(from: 0, to: 40)
        let randomCharacters = (0..<randomLength).map { _ in Character.arbitrary() }
        
        return String(randomCharacters)
    }
}


func check1<A: Arbitrary>(message: String, property: (A) -> Bool) {
    let numberOfIterations = 100
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        guard property(value) else {
            print("\(message) 没有通过测试：\(value)")
            return
        }
    }
    print("\(message) 通过了\(numberOfIterations)次测试")
}


extension CGSize: Arbitrary {
    var area: CGFloat { width*height }
    static func arbitrary() -> CGSize {
        CGSize(width: Int.arbitrary(), height: Int.arbitrary())
    }
}
check1(message: "CGSize的面积最小是0") { (size: CGSize) in size.area >= 0 }


protocol Smaller {
    func smaller() -> Self?
}

extension Int: Smaller {
    func smaller() -> Int? {
        self == 0 ? nil : self/2
    }
}
extension String: Smaller {
    func smaller() -> String? {
        isEmpty ? nil : String(dropFirst())
    }
}

/*
 protocol Arbitrary: Smaller {
     static func arbitrary() -> Self
 }
 */


func iterateWhile<A>(condition: (A) -> Bool, inital: A, next: (A) -> A?) -> A {
    guard let vaule = next(inital), condition(vaule) else {
        return inital
    }
    
    return iterateWhile(condition: condition, inital: vaule, next: next)
}


func check2<A: Arbitrary & Smaller>(message: String, property: (A) -> Bool) {
    let numberOfIterations = 100
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        guard property(value) else {
            let smaller = iterateWhile(condition: { !property($0) }, inital: value, next: { $0.smaller() })
            print("\(message) 没有通过测试：\(smaller)")
            return
        }
    }
    print("\(message) 通过了\(numberOfIterations)次测试")
}


func qsort(array: [Int]) -> [Int] {
    var data = array
    if data.isEmpty {
        return []
    }
    let pivot = data.removeFirst()
    let lesser = data.filter { $0 < pivot }
    let gretter = data.filter { $0 >= pivot }
    
    return qsort(array: lesser) + [pivot] + qsort(array: gretter)
}

extension Array: Arbitrary, Smaller where Element: Arbitrary {
    static func arbitrary() -> Array<Element> {
        let randomLength = Int.random(from: 0, to: 50)
        return (0..<randomLength).map { _ in Element.arbitrary() }
    }
    
    func smaller() -> Array<Element>? {
        if self.isEmpty { return nil }
        return Array(self.dropFirst())
    }
}

check2(message: "qsort函数和Array内置sort函数效果一致") { (array: [Int]) in qsort(array: array) == array.sorted(by: <) }


struct ArbitraryInstance<T> {
    let arbitrary: () -> T
    let smaller: (T) -> T?
}

func checkHelper<A>(arbitraryInstance: ArbitraryInstance<A>, message: String, property: (A) -> Bool) {
    let numberOfIterations = 100
    for _ in 0..<numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        guard property(value) else {
            let smallerValue = iterateWhile(condition: property, inital: value, next: arbitraryInstance.smaller)
            print("\(message) 没有通过测试：\(smallerValue)")
            return
        }
    }
    print("\(message) 通过了\(numberOfIterations)次测试")
}


func check3<X: Arbitrary>(message: String, property: ([X]) -> Bool) {
    let instance = ArbitraryInstance(arbitrary: Array<X>.arbitrary) { $0.smaller() }
    checkHelper(arbitraryInstance: instance, message: message, property: property)
}

check3(message: "qsort函数和Array内置sort函数效果一致") { (x: [Int]) -> Bool in qsort(array: x) == x.sorted(by: <) }


