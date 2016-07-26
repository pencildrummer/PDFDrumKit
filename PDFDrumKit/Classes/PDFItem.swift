
//
//  PDFItem.swift
//  Pods
//
//  Created by Fabio Borella on 25/07/16.
//
//

import Foundation

public protocol PDFDrawableItem: NSObjectProtocol {
    
    var drawBounds: CGRect { get }
    
}

internal protocol PDFDrawableItemInternal: class, NSObjectProtocol {
    
    var _drawRect: CGRect { get }
    
}

public class PDFItem: UIView, PDFDrawableItem, PDFDrawableItemInternal {
    
    internal var _drawRect: CGRect = CGRectZero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layoutMargins = UIEdgeInsetsZero
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutMargins = UIEdgeInsetsZero
    }
    
    public var drawBounds: CGRect {
        setNeedsLayout()
        layoutIfNeeded()
        return bounds
    }
    
    public override func drawLayer(layer: CALayer, inContext ctx: CGContext) {
        super.drawLayer(layer, inContext: ctx)
        drawLayerHierarchy(layer, ctx: ctx)
    }
    
    private func drawLayerHierarchy(layer: CALayer, ctx: CGContextRef) {
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                CGContextSaveGState(ctx)

                CGContextTranslateCTM(ctx, sublayer.frame.origin.x, sublayer.frame.origin.y)
                CGContextClipToRect(ctx, sublayer.bounds)
                
                sublayer.allowsEdgeAntialiasing = false

                sublayer.drawInContext(ctx)
                
                var shouldRender = sublayer.sublayers?.count ?? 0 == 0
                if let _ = sublayer.delegate as? UILabel {
                    shouldRender = false
                }
                if shouldRender {
                    sublayer.renderInContext(ctx)
                }
                
                drawLayerHierarchy(sublayer, ctx: ctx)
                
                CGContextRestoreGState(ctx)
            }
        }
    }
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
    public func drawVectorImage(path: String, inBundle bundle: NSBundle? = nil, atPoint point: CGPoint, context: CGContextRef) {
        var loadBundle = bundle
        if loadBundle == nil {
            loadBundle = NSBundle.mainBundle()
        }
        if let feedbackLogoPath = loadBundle!.pathForResource(path, ofType: "pdf") {
            let feedbackLogoURL = NSURL(fileURLWithPath: feedbackLogoPath)
            let pdfLogo = CGPDFDocumentCreateWithURL(feedbackLogoURL)
            let pdfLogoPage = CGPDFDocumentGetPage(pdfLogo!, 1)
            let imageRect = CGPDFPageGetBoxRect(pdfLogoPage, .MediaBox)
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, 0, imageRect.size.height)
            CGContextTranslateCTM(context, point.x, point.y)
            CGContextScaleCTM(context, 1, -1)
            CGContextDrawPDFPage(context, pdfLogoPage)
            CGContextRestoreGState(context)
        }
    }
}

extension CALayer {
    
    private func debugLog() -> Self {
        print("---")
        print("Layer draw info")
        debugPrint(self.dynamicType, "delegate:", delegate)
        let ctx = UIGraphicsGetCurrentContext()
        print("frame:", frame, "bounds: ", bounds, "clip box:", CGContextGetClipBoundingBox(ctx))
        print("background color:", backgroundColor)
        return self
    }
}