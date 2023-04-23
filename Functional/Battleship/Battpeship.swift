//
//  Battpeship.swift
//  Battleship
//
//  Created by 綦帅鹏 on 2018/11/14.
//
/*
 战舰类游戏核心类
 
 主要解决判断给定的点是否在射程范围内的问题。
 */
import Foundation

/// 首先定义两种类型，Distance（表示距离）、Position（表示位置）
typealias Distance = Double
struct Position {
    var x: Distance
    var y: Distance
}

/// 引入Ship结构体，用来表示战船
struct Ship {
    /// 位置
    var position: Position
    
    /// 射程范围
    var firingRange: Distance
    
    /// 不安全范围
    var unsafeRange: Distance
}

extension Position {
    func plus(tagert: Position) -> Position {
        return Position(x: x + tagert.x, y: y + tagert.y);
    }
    func minus(tagert: Position) -> Position {
        return Position(x: x - tagert.x, y: y - tagert.y)
    }
    func length() -> Distance {
        return sqrt(x*x + y*y)
    }
}

// MARK: - 扩展Ship类型
extension Ship {
    /// 添加一个canEnageShip函数用于检查是否另一艘船在射程范围内
    ///
    /// - Parameter target: 目标船
    /// - Returns: 是否在射程范围内
    func canEnageShip(target: Ship) -> Bool {
//        let dX: Distance = target.position.x - position.x
//        let dY: Distance = target.position.y - position.y
//        return sqrt(dX*dX + dY*dY) <= firingRange
        
//        return position.minus(tagert: target.position).length() <= firingRange
        
        return shift(region: circle(radius: firingRange), offset: position)(target.position)
    }
    
    /// 判断是否另一艘船在不安全范围内
    ///
    /// - Parameter target: 目标船
    /// - Returns: 否另一艘船在不安全范围内
    func inUnsafeRange(target: Ship) -> Bool {
//        let dX: Distance = target.position.x - position.x
//        let dY: Distance = target.position.y - position.y
//        return sqrt(dX*dX + dY*dY) <= unsafeRange
        
//        return position.minus(tagert: target.position).length() <= unsafeRange
        
        return shift(region: circle(radius: unsafeRange), offset: position)(target.position)
    }
    
    /// 判断是否另一艘船在射程范围内并且在不安全范围外
    ///
    /// - Parameter target: 目标船
    /// - Returns: 否另一艘船在射程范围内并且在不安全范围外
    func canSafelyEngageShip(target: Ship) -> Bool {
//        return canEnageShip(target: target) && (!inUnsafeRange(target: target))
        
        return difference(region: shift(region: circle(radius: firingRange), offset: position), mimus: shift(region: circle(radius: unsafeRange), offset: position))(target.position)
    }
    
    /// 射程区域
    ///
    /// - Returns: 区域
    func enageRegion() -> Region { return shift(region: circle(radius: firingRange), offset: position) }
    
    /// 不安全区域
    ///
    /// - Returns: 区域
    func unsafeRegion() -> Region { return shift(region: circle(radius: unsafeRange), offset: position) }
    
    /// 安全输出区域
    ///
    /// - Returns: 区域
    func safelyEngageReion() -> Region { return difference(region: enageRegion(), mimus: unsafeRegion()) }
}

/// 问题归根结底是要定义是要定义一个函数判定一个点是否在特定范围内
typealias Region = (Position) -> Bool

/// 圆心为原点半径为radius的圆
///
/// - Parameter radius: 半径
/// - Returns: 圆形区域
func circle(radius:Distance) -> Region {
    return { point in point.length() <= radius }
}
/// 圆心为center半径为radius的圆
///
/// - Parameters:
///   - center: 圆心
///   - radius: 半径
/// - Returns: 圆形区域
func circle1(center: Position, radius: Distance) -> Region {
    return { point in center.minus(tagert: point).length() <= radius }
}

/// 移动区域
///
/// - Parameters:
///   - region: 区域
///   - offset: 偏移量
/// - Returns: 移动后的区域
func shift(region: @escaping Region, offset: Position) -> Region {
    return { point in region(point.minus(tagert: offset)) }
}

/// 反转区域
///
/// - Parameter region: 区域
/// - Returns: 反转后的区域
func invert(region: @escaping Region) -> Region {
    return { point in !region(point) }
}

/// 区域交集
///
/// - Parameters:
///   - region1: 区域1
///   - region2: 区域2
/// - Returns: 交集区域
func intersection(region1: @escaping Region, region2: @escaping Region) -> Region {
    return { point in region1(point) && region2(point) }
}

/// 区域并集
///
/// - Parameters:
///   - region1: 区域1
///   - region2: 区域2
/// - Returns: 并集区域
func union(region1: @escaping Region, region2: @escaping Region) -> Region {
    return { point in region1(point) || region2(point) }
}

/// 区域差（在第一个区域中但不在第二个区域中）
///
/// - Parameters:
///   - region: 原区域
///   - mimus: 做差区域
/// - Returns: 差区域
func difference(region: @escaping Region, mimus: @escaping Region) -> Region {
    return intersection(region1: region, region2: invert(region: mimus))
}

let circle2 = shift(region: circle(radius: 5), offset: Position(x: 5, y: 5))


struct Region1 {
    let lookup: (Position) -> Bool
}
extension Region1 {
    init(_ radius: Distance) { self.init { $0.length() <= radius } }
    func shift(offset: Position) -> Region1 { return Region1(lookup: { point in self.lookup(point.minus(tagert: offset)) }) }
    
    func invert() -> Region1 { return Region1(lookup: { point in !self.lookup(point) }) }
    
    func intersection(other: Region1) -> Region1 { return Region1(lookup: { point in self.lookup(point) && other.lookup(point) }) }
    
    func union(other: Region1) -> Region1 { return Region1(lookup: { point in self.lookup(point) || other.lookup(point) }) }
    
    func difference(other: Region1) -> Region1 { return Region1(lookup: { point in self.lookup(point) && (!other.lookup(point)) }) }
}

func circle3(radius: Distance) -> Region1 { return Region1(lookup: { point in point.length() <= radius }) }

extension Ship {
    func enageRegion1() -> Region1 { return Region1(firingRange).shift(offset: position) }
    func unsafeRegion1() -> Region1 { return Region1(unsafeRange).shift(offset: position) }
    func safelyEnageReion1() -> Region1 { return enageRegion1().difference(other: unsafeRegion1()) }
    
    func allEnageRegion1(friends: Ship ...) -> Region1 { return friends.reduce(enageRegion1(), { (region, friend) in region.union(other: friend.enageRegion1()) }) }
    func allUnsafeRegion1(friends: Ship ...) -> Region1 { return friends.reduce(unsafeRegion1(), { (region, friend) in region.union(other: friend.unsafeRegion1()) }) }
    func allSafelyEnageRegion1(friends: Ship ...) -> Region1 { return friends.reduce(safelyEnageReion1(), { (region, friend) in region.union(other: friend.safelyEnageReion1()) }) }
}

