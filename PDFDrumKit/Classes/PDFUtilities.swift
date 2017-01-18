//
//  PDFUtilities.swift
//  Pods
//
//  Created by Fabio Borella on 13/07/16.
//
//

import CoreGraphics

//func +(left: CGPoint, right: CGPoint) -> CGPoint {
//    return CGPoint(x: left.x+right.x, y: left.y+right.y)
//}

//private func CGPointOffset(point: CGPoint, offset: CGPoint) -> CGPoint {
//    return point + offset
//}

internal let kPDFDrumKitDisplayName = "PDFDrumKit"
internal let kPDFDrumKitVersion = "0.2.0"
internal let kPDFDrumKitInfo = "Fabio Borella - github.com/pencildrummer"

extension String {
    
    internal var sanitizedPDFFilenameString: String {
        var sanitized = self
        // Check for illegal characters
        sanitized = sanitized.stringByReplacingOccurrencesOfString("/", withString: "-")
        // Escape spaces in filename
        //sanitized = sanitized.stringByReplacingOccurrencesOfString(" ", withString: "_")
        // Check if has pdf extension
        if NSString(string: sanitized).pathExtension != "pdf" {
            sanitized += ".pdf"
        }
        return sanitized
    }
    
}
