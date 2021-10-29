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
            return left.isBST && right.isBST && left.elements.all{ $0 < value } && right.elements.all{ $0 > value }
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

extension Sequence {
    func all(predicate: (Element) -> Bool) -> Bool {
        for item in self where !predicate(item) {
            return false
        }
        return true
    }
}

var tree = BinarySearchTree(value: 10)
var tree1 = tree
tree1.insert(value: 8)
print(tree.elements) // [10]
print(tree1.elements) // [10, 8]


extension String {
    func complete(history: [String]) -> [String] {
        history.filter { $0.hasPrefix(self) }
    }
}

struct Trie<Element: Hashable> {
    var isElement: Bool
    var children: [Element: Trie<Element>]
}

extension Trie {
    init() {
        isElement = false
        children = [:]
    }
}

extension Trie {
    var elements: [[Element]] {
        var result: [[Element]] = isElement ? [[]] : []
        for (key, value) in children {
            result += value.elements.map { [key] + $0 }
        }
        
        return result
    }
    
    var elements1: [[Element]] {
        var result: [[Element]] = isElement ? [[]] : []
        result += children.flatMap { (item) in
            return item.value.elements.map { [item.key] + $0 }
        }
        
        return result
    }
}

let rTrie = Trie(isElement: false, children: ["e": Trie(isElement: true, children: [:])])
var trie = Trie(isElement: false, children: ["a": Trie(isElement: true, children: ["m": Trie(isElement: true, children: [:]), "r": rTrie]), "b": Trie(), "c": Trie()])
print("----\(trie.elements)----")
print("----\(trie.elements1)----")
/*输出：
 ----[["a"], ["a", "m"], ["a", "r", "e"]]----
 ----[["a"], ["a", "m"], ["a", "r", "e"]]----
 */

extension Array {
    var slice: ArraySlice<Element> {
        ArraySlice(self)
    }
}

extension ArraySlice {
    var decomposed: (Element, ArraySlice<Element>)? {
        isEmpty ? nil : (first!, dropFirst())
    }
}

func sum(integers: ArraySlice<Int>) -> Int {
    guard let (head, tail) = integers.decomposed else {
        return 0
    }
    return head + sum(integers: tail)
}

print(sum(integers: Array(1...100).slice))
/*输出：5050*/

extension Trie {
    func lookup(key: ArraySlice<Element>) -> Bool {
        guard let (head, tail) = key.decomposed else { return isElement }
        guard let sub = children[head] else { return false }
        
        return sub.lookup(key: tail)
    }
}

print("----\(trie.lookup(key: ["a", "r", "e"].slice))----")
/*输出：----true----*/

extension Trie {
    func lookup1(key: ArraySlice<Element>) -> Trie<Element>? {
        guard let (head, tail) = key.decomposed else { return self }
        guard let sub = children[head] else { return nil }
        
        return sub.lookup1(key: tail)
    }
}

extension Trie {
    func complete(key: ArraySlice<Element>) -> [[Element]] { lookup1(key: key)?.elements ?? [] }
}

extension Trie {
    init(_ key: ArraySlice<Element>) {
        if let (head, tail) = key.decomposed {
            self = Trie(isElement: false, children: [head: Trie(tail)])
        } else {
            self = Trie(isElement: true, children: [:])
        }
    }
}

extension Trie {
    func inserting(_ key: ArraySlice<Element>) -> Trie<Element> {
        guard let (head, tail) = key.decomposed else {
            return Trie(isElement: true, children: children)
        }
        
        var newChildren = children
        if let trie = children[head] {
            newChildren[head] = trie.inserting(tail)
        } else {
            newChildren[head] = Trie(tail)
        }
        
        return Trie(isElement: isElement, children: newChildren)
    }
    mutating func inserting1(_ key: ArraySlice<Element>) {
        guard let (head, tail) = key.decomposed else {
            isElement = true
            return
        }
        
        if var trie = children[head] {
            trie.inserting1(tail)
        } else {
            children[head] = Trie(tail)
        }
    }
}

var iTrie = trie.inserting(["a", "r", "g", "u", "m", "e", "n", "t"].slice)
iTrie.inserting1(["a", "p", "p", "l", "e"].slice)
print("----\(iTrie.elements)----")
/*输出：----[["a"], ["a", "r", "g", "u", "m", "e", "n", "t"], ["a", "r", "e"], ["a", "m"]]----*/

extension Trie where Element == Character {
    static func build(words: [String]) -> Trie {
        return words.reduce(Trie()) { (result, word) in
            return result.inserting(Array(word).slice)
        }
    }
}

extension String {
    func compelte(knownword: Trie<Character>) -> [String] {
        knownword.complete(key: Array(self).slice).map { self + String($0) }
    }
}

let content =  ["cat", "car", "cart", "dog", "你", "你好", "你好吗"]
let wordsT = Trie.build(words: content)
print("----\("c".compelte(knownword: wordsT))----")
/*输出：----["cat", "car", "cart"]----*/
print("----\("你好".compelte(knownword: wordsT))----")
/*输出：----["你好", "你好吗"]----*/


