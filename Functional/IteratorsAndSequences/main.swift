//
//  main.swift
//  IteratorsAndSequences
//
//  Created by 綦 on 2021/11/11.
//

import Foundation

struct ReverseIndexIterator: IteratorProtocol {
    var index: Int
    init<T>(array: [T]) {
        index = array.endIndex - 1
    }
    
    mutating func next() -> Int? {
        guard index >= 0 else { return nil }
        
        defer { index -= 1 }
        
        return index
    }
}

let letters = ["A", "B", "C"]
var iterator = ReverseIndexIterator(array: letters)
while let i = iterator.next() {
    print("数组的第\(i)个元素是\(letters[i])")
}
/* 输出：
 数组的第2个元素是C
 数组的第1个元素是B
 数组的第0个元素是A
 */


struct PowerIterator: IteratorProtocol {
    var power: NSDecimalNumber = 1
    mutating func next() -> NSDecimalNumber? {
        power = power.multiplying(by: 2)
        
        return power
    }
}

extension PowerIterator {
    mutating func find(where predicate: (NSDecimalNumber) -> Bool) -> NSDecimalNumber? {
        while let x = next() {
            if predicate(x) {
                return x
            }
        }
        
        return nil
    }
}

var powerIterator = PowerIterator()
let num = powerIterator.find { $0.intValue > 1000 }
if let value = num {
    print(value)
}
/// 输出：1024


struct FileLinesIterator: IteratorProtocol {
    let lines: [String]
    var currentLine: Int = 0
    
    init(filename: String) throws {
        let contents: String = try String(contentsOfFile: filename)
        lines = contents.components(separatedBy: .newlines)
    }
    
    mutating func next() -> String? {
        guard currentLine < lines.endIndex else { return nil }
        
        defer { currentLine += 1 }
        
        return lines[currentLine]
    }
}


extension IteratorProtocol {
    mutating func find(predicate:(Element) -> Bool) -> Element? {
        while let x = next() {
            if predicate(x) {
                return x
            }
        }
        
        return nil
    }
}


struct LimitIterator<I: IteratorProtocol>: IteratorProtocol {
    var limit = 0
    var iterator: I
    init(limit: Int, iterator: I) {
        self.limit = limit
        self.iterator = iterator
    }
    
    mutating func next() -> I.Element? {
        guard limit > 0 else {
            return nil
        }
        
        return iterator.next()
    }
}


extension Int {
    func countDown() -> AnyIterator<Int> {
        return AnyIterator {
            var i = self - 1
            guard i >= 0 else {
                return nil
            }
            
            defer { i -= 1 }
            
            return i
        }
    }
}

func +<I: IteratorProtocol, J: IteratorProtocol>(first: I, second: J) -> AnyIterator<I.Element> where I.Element == J.Element {
    var i = first
    var j = second
    return AnyIterator { i.next() ?? j.next() }
}

func +<I: IteratorProtocol, J: IteratorProtocol>(first: I, second: @escaping @autoclosure () -> J) -> AnyIterator<I.Element> where I.Element == J.Element {
    var one = first;
    var other: J? = nil
    return AnyIterator {
        if other != nil {
            return other?.next()
        } else if let result = one.next() {
            return result
        } else {
            other = second()
            return other?.next()
        }
    }
}


struct ReverseArrayIndices<T>: Sequence {
    let array: [T]
    init(array: [T]) {
        self.array = array
    }
    func makeIterator() -> ReverseIndexIterator {
        return ReverseIndexIterator(array: array)
    }
}


var array = ["one", "two", "three"]
let reverseSequence = ReverseArrayIndices(array: array)
var reverseIterator = reverseSequence.makeIterator()
while let i = reverseIterator.next() {
    print("第\(i)个元素是\(array[i])")
}
/*
 输出：
 第2个元素是three
 第1个元素是two
 第0个元素是one
 */
