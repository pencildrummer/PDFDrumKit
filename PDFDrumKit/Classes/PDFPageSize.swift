//
//  PDFPageSize.swift
//  Pods
//
//  Created by Fabio Borella on 18/01/17.
//
//

import Foundation

/**
 Sources:
 - https://www.cl.cam.ac.uk/~mgk25/iso-paper-ps.txt
 */
public enum PDFPageSize {
    case a0
    case a1
    case a2
    case a3
    case a4
    case a5
    case a6
    
    var size: CGSize {
        switch self {
        case .a0:
            return CGSize(width: 2384, height: 3370)
        case .a1:
            return CGSize(width: 1684, height: 2384)
        case .a2:
            return CGSize(width: 1191, height: 1684)
        case .a3:
            return CGSize(width: 842, height: 1191)
        case .a4:
            return CGSize(width: 595, height: 842)
        case .a5:
            return CGSize(width: 420, height: 595)
        case .a6:
            return CGSize(width: 298, height: 420)
        }
        return CGSize.zero
    }
    
    var bounds: CGRect {
        return CGRect(origin: CGPoint.zero, size: size)
    }
}
