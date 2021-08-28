//
//  main.swift
//  Func
//
//  Created by 綦 on 2021/8/4.
//

import Foundation


indirect enum BinarySearchTree<Element: Comparable>  {
    case leaf
    case node(BinarySearchTree<Element>, Element, BinarySearchTree<Element>)
}

let leaf = BinarySearchTree<Int>.leaf
let five: BinarySearchTree<Int> = .node(.leaf, 5, .leaf)

extension BinarySearchTree {
    init() {
        self = .leaf
    }
    init(value: Element) {
        self = .node(.leaf, value, .leaf)
    }
    
    var count: Int {
        switch self {
        case .leaf:
            return 0
        case let .node(left, _, right):
            return left.count + 1 + right.count
        }
    }
    
    var elements: Array<Element> {
        switch self {
        case .leaf:
            return []
        case let .node(left, value, right):
            return left.elements + [value] + right.elements
        }
    }
    
    func recuce<A>(initialResult: A, nextNodeResult: (A, Element, A) -> A) -> A {
        switch self {
        case .leaf:
            return initialResult
        case let .node(left, value, right):
            return nextNodeResult(left.recuce(initialResult: initialResult, nextNodeResult: nextNodeResult), value, right.recuce(initialResult: initialResult, nextNodeResult: nextNodeResult))
        }
    }
    
    func count1() -> Int {
        self.recuce(initialResult: 0) { $0 + 1 + $2 }
    }
    func elements1() -> Array<Element> {
        self.recuce(initialResult: []) { $0 + [$1] + $2 }
    }
    
    var isEmpty: Bool {
        if case .leaf = self {
            return true
        }
        return false
    }
    
    var isBST: Bool {
        switch self {
        case .leaf:
            return true
        case let .node(left, value, right):
            return left.isBST && right.isBST && left.elements.reduce(false, { $0 && $1 < value }) && right.elements.reduce(false, { $0 && $1 > value })
        }
    }
    
    func contains(value: Element) -> Bool {
        switch self {
        case .leaf:
            return false
        case let .node(_, myValue, _) where value == myValue:
            return true
        case let .node(left, myValue, _) where value > myValue:
            return left.contains(value: value)
        case let .node(_, myValue, right) where value < myValue:
            return right.contains(value: value)
        default:
            return false
        }
    }
    func contains1(value: Element) -> Bool {
        switch self {
        case .leaf:
            return false
        case let .node(left, myValue, right):
            if value == myValue {
                return true
            } else if value > myValue {
                return left.contains1(value: value)
            } else {
                return right.contains1(value: value)
            }
        }
    }
    
    mutating func insert(value: Element) {
        switch self {
        case .leaf:
            self = BinarySearchTree(value: value)
        case .node(var left, let myValue, var right):
            if value > myValue {
                left.insert(value: value)
            } else if value < myValue {
                right.insert(value: value)
            }
            self = .node(left, myValue, right)
        }
    }
}

var tree = BinarySearchTree(value: 10)
var tree1 = tree
tree1.insert(value: 8)
print(tree.elements) // [10]
print(tree1.elements) // [10, 8]

