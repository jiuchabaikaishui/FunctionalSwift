//
//  main.swift
//  Func
//
//  Created by 綦 on 2021/8/4.
//

import Foundation


indirect enum BinarySearchTree<Element: Equatable>  {
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
}

extension BinarySearchTree {
    var count: Int {
        switch self {
        case .leaf:
            return 0
        case let .node(left, _, right):
            return left.count + 1 + right.count
        }
    }
}

extension BinarySearchTree {
    var elements: Array<Element> {
        switch self {
        case .leaf:
            return []
        case let .node(left, value, right):
            return left.elements + [value] + right.elements
        }
    }
}

extension BinarySearchTree {
    func recuce<A>(initialResult: A, nextNodeResult: (A, Element, A) -> A, nextLeafResult: (A, BinarySearchTree) -> A) -> A {
        switch self {
        case .leaf:
            return nextLeafResult(initialResult, self)
        case let .node(left, value, right):
            return nextNodeResult(left.recuce(initialResult: initialResult, nextNodeResult: nextNodeResult, nextLeafResult: nextLeafResult), value, right.recuce(initialResult: initialResult, nextNodeResult: nextNodeResult, nextLeafResult: nextLeafResult))
//            return nextNodeResult(left.recuce(initialResult: initialResult, nextPartialResult: nextNodeResult), value, right.recuce(initialResult: initialResult, nextPartialResult: nextNodeResult), nextLeafResult: nextLeafResult)
        }
    }
    func reduce1<A>(initalResult: A, nextPartialResult: (A, BinarySearchTree) -> A) -> A {
        return nextPartialResult(initalResult, self)
    }
}
