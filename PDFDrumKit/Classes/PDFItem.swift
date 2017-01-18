
//
//  PDFItem.swift
//  Pods
//
//  Created by Fabio Borella on 25/07/16.
//
//

import Foundation

public class PDFItem: UIView, PDFDrawableItem {
    
    internal var _page: PDFPage?
    
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
    
    // -drawRect has been marked final to avoid override
    // The draw code must be perfomed inside the -drawLayer(layer:, inContext:)
    
    final public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
    public func drawVectorImage(path: String, inBundle bundle: NSBundle? = nil, atPoint point: CGPoint, context: CGContextRef) {
        let loadBundle = bundle ?? NSBundle.mainBundle()
        if let pdfImagePath = loadBundle.pathForResource(path, ofType: "pdf") {
            let pdfImageURL = NSURL(fileURLWithPath: pdfImagePath)
            if let pdfImageDocument = CGPDFDocumentCreateWithURL(pdfImageURL),
                let pdfImagePage = CGPDFDocumentGetPage(pdfImageDocument, 1) {
                
                let imageRect = CGPDFPageGetBoxRect(pdfImagePage, .MediaBox)
                
                CGContextSaveGState(context)
                CGContextTranslateCTM(context, 0, imageRect.size.height)
                CGContextTranslateCTM(context, point.x, point.y)
                CGContextScaleCTM(context, 1, -1)
                CGContextDrawPDFPage(context, pdfImagePage)
                CGContextRestoreGState(context)
                
            }
        }
    }
    
}

extension CALayer {
    
    private func debugLog() -> Self {
        print("---")
        print("Layer draw info")
        debugPrint(self.dynamicType, "delegate:", delegate)
        if let ctx = UIGraphicsGetCurrentContext() {
            print("frame:", frame, "bounds: ", bounds, "clip box:", CGContextGetClipBoundingBox(ctx))
            print("background color:", backgroundColor)
        }
        return self
    }
}
