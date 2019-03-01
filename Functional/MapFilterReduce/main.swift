//
//  main.swift
//  MapFilterReduce
//
//  Created by 綦帅鹏 on 2019/3/1.
//

import Foundation

let array = [1, 2, 3, 4, 5]
print("原始数据：\(array)")

func incrementArray(array: [Int]) -> [Int] {
    var result: Array<Int> = []
    for i in array {
        result.append(i + 1)
    }
    
    return result
}
print("incrementArray：\(incrementArray(array: array))")

func doubleArray(array: [Int]) -> [Int] {
    var result: [Int] = []
    for i in array {
        result.append(i*2)
    }
    
    return result;
}
print("doubleArray：\(doubleArray(array: array))")

func computeIntArray(array: [Int], transform: (Int) -> Int) -> [Int] {
    var result: [Int] = []
    for i in array {
        result.append(transform(i))
    }
    
    return result
}

func incrementArray1(array: [Int]) -> [Int] {
    return computeIntArray(array: array, transform: { x in x + 1 })
}
func doubleArray1(array: [Int]) -> [Int] {
    return computeIntArray(array: array, transform: { x in x*2 })
}
print("incrementArray1：\(incrementArray1(array: array))")
print("doubleArray1：\(doubleArray1(array: array))")
//func isEvenArray(array: [Int] -> [Bool]) {
//    return computeIntArray(array: array, transform: { x in x%2 == 0 })
//}
func genericComputeArray<T>(array: [Int], transform: (Int) -> T) -> [T] {
    var result: [T] = []
    for i in array {
        result.append(transform(i))
    }
    
    return result
}
func map<Element, T>(array: [Element], transform: (Element) -> T) -> [T] {
    var result: [T] = []
    for i in array {
        result.append(transform(i))
    }
    
    return result
}
extension Array {
    func map<T>(transform: (Element) -> T) -> [T] {
        var result: [T] = []
        for i in self {
            result.append(transform(i))
        }
        
        return result
    }
    func filter(includeElement: (Element) -> BooleanLiteralType) -> [Element] {
        var result: [Element] = []
        for i in self {
            if (includeElement(i)) { result.append(i) }
        }
        
        return result
    }
    func reduce<T>(initial: T, combine: (T, Element) -> T) -> T {
        var result: T = initial
        for i in self {
            result = combine(result, i)
        }
        
        return result
    }
}

func sumUsingReduce(xs: [Int]) -> Int {
    return xs.reduce(initial: 0, combine: { result, i in result + i })
}
func productUsingReduce(xs: [Int]) -> Int {
    return xs.reduce(initial: 1, combine: *)
}
func concatUsingReduce(xs: [String]) -> String {
    return xs.reduce(initial: "", combine: +)
}
print("sumUsingReduce：\(sumUsingReduce(xs: array))")
print("productUsingReduce：\(productUsingReduce(xs: array))")
print("concatUsingReduce：\(concatUsingReduce(xs: array.map(transform: { i in "\(i)" })))")

extension Array {
    func mapUsingReduce<T>(transform: (Element) -> T) -> [T] {
        return self.reduce(initial: [T](), combine: { result, i in result + [transform(i)] })
    }
    func filterUsingReduce(includeElement: (Element) -> Bool) -> [Element] {
        return self.reduce(initial: [Element](), combine: { result, i in includeElement(i) ? result + [i] : result })
    }
}

struct City {
    let name: String
    let population: Int
}
let beijing = City(name: "北京", population: 4000)
let shanghai = City(name: "上海", population: 3500)
let guangzhou = City(name: "广州", population: 3000)
let shenzhen = City(name: "深圳", population: 2500)

let citys = [beijing, shanghai, guangzhou, shenzhen]

extension City {
    func cityByScalingPopulation() -> City { return City(name: self.name, population: self.population*10000) }
}

let table = citys.filter(includeElement: { city in city.population >= 3000 }).map(transform: { city in city.cityByScalingPopulation() }).reduce(initial: "\n城市：人口\n", combine: { result, city in result + "\(city.name)：\(city.population)\n"})
print(table)

func noOp<T>(x: T) -> T { return x }
func noOpAny(x: Any) -> Any { return x }
//func noOpWrong<T>(x: T) -> T { return 0 }
//func noOpAnyWrong(x: Any) -> Any { return 0 }

precedencegroup ComposeFunctionPrecedence {
    associativity: left
}
infix operator >>>: ComposeFunctionPrecedence
func >>><A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { x in g(f(x)) }
}

func curry<A, B, C>(f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { x in return { y in f(x, y) } }
}
