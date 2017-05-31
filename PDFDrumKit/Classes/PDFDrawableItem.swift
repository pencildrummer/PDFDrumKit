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
    
    var frame: CGRect { get set }
    var bounds: CGRect { get set }
    var layer: CALayer { get }
    var layoutMargins: UIEdgeInsets { get set }
    
    var drawBounds: CGRect { get }
    
    var clipsToBounds: Bool { get set }
    
    @available(iOS 8.0, *)
    func systemLayoutSizeFittingSize(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize
}

extension PDFDrawableItem {
    
    public func addLinkInRect(_ URL: Foundation.URL, linkRect: CGRect, context: CGContext) {
        let ctm = context.ctm
        let normalizedRect = linkRect.applying(ctm)
        UIGraphicsSetPDFContextURLForRect(URL, normalizedRect)
        
        // DEBUG
        /*CGContextSaveGState(context)
         UIColor.purpleColor().colorWithAlphaComponent(0.5).setFill()
         CGContextFillRect(context, linkRect)
         CGContextRestoreGState(context)*/
    }
    
    public func setDestinationAtPoint(_ destination: String, point: CGPoint, context: CGContext) {
        UIGraphicsAddPDFContextDestinationAtPoint(destination, point)
    }
    
    public func addDestinationLinkInRect(_ destination: String, linkRect: CGRect, context: CGContext) {
        //let ctm = context.ctm
        //let normalizedRect = linkRect.applying(ctm)
        UIGraphicsSetPDFContextDestinationForRect(destination, linkRect)
    }
    
    // MARK: Draw
    
    internal func draw() {
        
        if let context = UIGraphicsGetCurrentContext() {
            
            context.saveGState()
            
            context.translateBy(x: frame.origin.x, y: frame.origin.y)
            if clipsToBounds {
                context.clip(to: bounds)
            }
            
            layer.draw(in: context)
            
            context.restoreGState()
            
        }
        
    }
    
}
