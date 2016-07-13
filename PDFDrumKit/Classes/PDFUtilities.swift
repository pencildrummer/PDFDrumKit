//
//  PDFUtilities.swift
//  Pods
//
//  Created by Fabio Borella on 13/07/16.
//
//

import CoreGraphics

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x+right.x, y: left.y+right.y)
}

private func CGPointOffset(point: CGPoint, offset: CGPoint) -> CGPoint {
    return point + offset
}