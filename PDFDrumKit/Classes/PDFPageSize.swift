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
    case A0
    case A1
    case A2
    case A3
    case A4
    case A5
    case A6
    
    var size: CGSize {
        switch self {
        case .A0:
            return CGSize(width: 2384, height: 3370)
        case .A1:
            return CGSize(width: 1684, height: 2384)
        case .A2:
            return CGSize(width: 1191, height: 1684)
        case .A3:
            return CGSize(width: 842, height: 1191)
        case .A4:
            return CGSize(width: 595, height: 842)
        case .A5:
            return CGSize(width: 420, height: 595)
        case .A6:
            return CGSize(width: 298, height: 420)
        }
        return CGSizeZero
    }
    
    var bounds: CGRect {
        return CGRect(origin: CGPointZero, size: size)
    }
}
