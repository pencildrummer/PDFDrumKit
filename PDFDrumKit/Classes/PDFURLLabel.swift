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
    
    @IBInspectable open var urlStringOrDestinationName: String?
    
    open var drawBounds: CGRect {
        setNeedsLayout()
        layoutIfNeeded()
        return bounds
    }
    
    final override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        
        let rect = layer.frame
        
        if let urlStringOrDestinationName = urlStringOrDestinationName {
            if let url = URL(string: urlStringOrDestinationName) {
                addLinkInRect(url, linkRect: layer.bounds, context: ctx)
            } else {
                addDestinationLinkInRect(urlStringOrDestinationName, linkRect: layer.bounds, context: ctx)
            }
        }
    }
}
