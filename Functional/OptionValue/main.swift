//
//  main.swift
//  OptionValue
//
//  Created by 綦 on 2021/6/29.
//

import Foundation


let citys = ["Paris": 2241, "Madrid": 3165, "Amsterdam": 827, "Berlin": 3562]
let madridPopulation: Int? = citys["Madrid"]

// 可选绑定
if let v = citys["xxx"] {
    print(v)
} else {
    print("没有值")
}

// 强制解包
print(madridPopulation!)

// 隐式解包
let v: Int! = madridPopulation
print(v*10)

// ?? 运算符提供默认值
let v1 = madridPopulation ?? 100
print(v1)


// 定义运算符
infix operator ???
func ???<T>(optional: T?, defaultValue: T) -> T {
    if let result = optional {
        return result
    } else {
        return defaultValue
    }
}

let v2 = madridPopulation ??? 100
print(v2)

infix operator ????
func ????<T>(optional: T?, defaultValue: () -> T) -> T {
    if let result = optional {
        return result
    } else {
        return defaultValue()
    }
}

let v3 = madridPopulation ???? { 100 }
print(v3)

infix operator ?????: AdditionPrecedence
func ?????<T>(optional: T?, defaultValue: @autoclosure () -> T) -> T {
    if let result = optional {
        return result
    } else {
        return defaultValue()
    }
}

let v4 = madridPopulation ????? 100
print(v4)

struct Address {
    let city: String
    let state: String?
}
struct Person {
    let name: String
    let address: Address?
}
struct Order {
    let orderNumber: String
    let person: Person?
}
let order = Order(orderNumber: "123456789", person: Person(name: "张三", address: Address(city: "北京", state: "长安街")))

// 强制解包
print(order.person!.address!.state!)

// 可选绑定
if let person = order.person {
    if let address = person.address {
        if let state = address.state {
            print(state)
        }
    }
}

// 可选连解包
if let state = order.person?.address?.state {
    print(state)
}

// switch语句匹配可选值
let options = [0, 1, 10, 100, nil]
for i in options {
    switch i {
    case 0?:
        print("我是零")
    case (1..<100)?:
        print("一百以内的数")
    case .some(let x):
        print(x)
    case .none:
        print("没有值呀")
    }
}

// guard 语句
func populationDescriptionForCity(city: String) -> String? {
    guard let population = citys[city] else {
        return nil
    }
    
    return "\(city)的人口是\(population)万"
}
print(populationDescriptionForCity(city: "Paris") ?? "")


func incrementOptional(optional: Int?) -> Int? {
    guard let result = optional else {
        return nil
    }
    
    return result + 1
}

extension Optional {
    func map<U>(transform: (Wrapped) -> U) -> U? {
        guard let result = self else {
            return nil
        }
        return transform(result)
    }
}

let x: Int? = 3
let y: Int? = nil

func addOptionals(optionalX: Int?, optionalY: Int?) -> Int? {
    if let xV = optionalX {
        if let yV = optionalY {
            return xV + yV
        }
    }
    
    return nil
}

func addOptionals1(optionalX: Int?, optionalY: Int?) -> Int? {
    guard let xV = optionalX, let yV = optionalY else {
        return nil
    }
    
    return xV + yV
}


extension Optional {
    func flatMap<U>(transform: (Wrapped) -> U?) -> U? {
        guard let v = self else {
            return nil
        }
        
        return transform(v)
    }
}


func addOptionals2(optionalX: Int?, optionalY: Int?) -> Int? {
    optionalX.flatMap { (xV) -> Int? in
        optionalY.flatMap { (yV) -> Int? in
            xV + yV
        }
    }
}

var value = 1.0
for _ in 0..<200 {
    value = value*1.02
}
print(value)



