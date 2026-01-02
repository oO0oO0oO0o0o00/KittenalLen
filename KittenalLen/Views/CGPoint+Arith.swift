//
//  CGPoint+Arith.swift
//  KittenalLen
//
//  Created by MeowCat on 2025/12/21.
//

func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
}

func + (lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

func - (lhs: CGPoint, rhs: CGSize) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
}

func - (lhs: CGPoint, rhs: CGPoint) -> CGSize {
    return CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
}

prefix func - (point: CGPoint) -> CGPoint {
    return CGPoint(x: -point.x, y: -point.y)
}

prefix func - (size: CGSize) -> CGSize {
    return CGSize(width: -size.width, height: -size.height)
}

func * (point: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: point.width * scalar, height: point.height * scalar)
}

func / (point: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: point.width / scalar, height: point.height / scalar)
}
