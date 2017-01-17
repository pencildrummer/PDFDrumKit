//
//  PDFURLLabel.swift
//  Pods
//
//  Created by Fabio Borella on 17/01/17.
//
//

import Foundation
import UIKit

class PDFURLLabel: UILabel, PDFDrawableItem {
    
    @IBInspectable public var urlStringOrDestinationName: String?
    
    public var drawBounds: CGRect {
        setNeedsLayout()
        layoutIfNeeded()
        return bounds
    }
    
    final override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
    override func drawLayer(layer: CALayer, inContext ctx: CGContext) {
        super.drawLayer(layer, inContext: ctx)
        
        let rect = layer.frame
        
        if let urlStringOrDestinationName = urlStringOrDestinationName {
            if let url = NSURL(string: urlStringOrDestinationName) {
                addLinkInRect(url, linkRect: layer.bounds, context: ctx)
            } else {
                addDestinationLinkInRect(urlStringOrDestinationName, linkRect: layer.bounds, context: ctx)
            }
        }
    }
}
