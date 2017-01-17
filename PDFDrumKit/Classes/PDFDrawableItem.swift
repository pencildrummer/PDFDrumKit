//
//  PDFDrawableItem.swift
//  Pods
//
//  Created by Fabio Borella on 17/01/17.
//
//

import Foundation
import UIKit

public protocol PDFDrawableItem: NSObjectProtocol {
    
    var drawBounds: CGRect { get }
    
}

extension PDFDrawableItem {
    
    public func addLinkInRect(URL: NSURL, linkRect: CGRect, context: CGContextRef) {
        let ctm = CGContextGetCTM(context)
        let normalizedRect = CGRectApplyAffineTransform(linkRect, ctm)
        UIGraphicsSetPDFContextURLForRect(URL, normalizedRect)
        
        // DEBUG
        /*CGContextSaveGState(context)
         UIColor.purpleColor().colorWithAlphaComponent(0.5).setFill()
         CGContextFillRect(context, linkRect)
         CGContextRestoreGState(context)*/
    }
    
    public func setDestinationAtPoint(destination: String, point: CGPoint, context: CGContextRef) {
        UIGraphicsAddPDFContextDestinationAtPoint(destination, point)
    }
    
    public func addDestinationLinkInRect(destination: String, linkRect: CGRect, context: CGContextRef) {
        let ctm = CGContextGetCTM(context)
        let normalizedRect = CGRectApplyAffineTransform(linkRect, ctm)
        UIGraphicsSetPDFContextDestinationForRect(destination, linkRect)
    }
    
}
