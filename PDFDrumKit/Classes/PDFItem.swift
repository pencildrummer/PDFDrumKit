
//
//  PDFItem.swift
//  Pods
//
//  Created by Fabio Borella on 25/07/16.
//
//

import Foundation

open class PDFItem: UIView, PDFDrawableItem {
    
    internal var _page: PDFPage?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layoutMargins = UIEdgeInsets.zero
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutMargins = UIEdgeInsets.zero
    }
    
    open var drawBounds: CGRect {
        setNeedsLayout()
        layoutIfNeeded()
        return bounds
    }
    
    open override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        drawLayerHierarchy(layer, ctx: ctx)
    }
    
    fileprivate func drawLayerHierarchy(_ layer: CALayer, ctx: CGContext) {
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                ctx.saveGState()

                ctx.translateBy(x: sublayer.frame.origin.x, y: sublayer.frame.origin.y)
                ctx.clip(to: sublayer.bounds)
                
                sublayer.allowsEdgeAntialiasing = false

                sublayer.draw(in: ctx)
                
                var shouldRender = sublayer.sublayers?.count ?? 0 == 0
                if let _ = sublayer.delegate as? UILabel {
                    shouldRender = false
                }
                if shouldRender {
                    sublayer.render(in: ctx)
                }
                
                drawLayerHierarchy(sublayer, ctx: ctx)
                
                ctx.restoreGState()
            }
        }
    }
    
    // -drawRect has been marked final to avoid override
    // The draw code must be perfomed inside the -drawLayer(layer:, inContext:)
    
    final public override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    open func drawVectorImage(_ path: String, inBundle bundle: Bundle? = nil, atPoint point: CGPoint, context: CGContext) {
        let loadBundle = bundle ?? Bundle.main
        if let pdfImagePath = loadBundle.path(forResource: path, ofType: "pdf") {
            let pdfImageURL = URL(fileURLWithPath: pdfImagePath)
            if let pdfImageDocument = CGPDFDocument(pdfImageURL as CFURL),
                let pdfImagePage = pdfImageDocument.page(at: 1) {
                
                let imageRect = pdfImagePage.getBoxRect(.mediaBox)
                
                context.saveGState()
                context.translateBy(x: 0, y: imageRect.size.height)
                context.translateBy(x: point.x, y: point.y)
                context.scaleBy(x: 1, y: -1)
                context.drawPDFPage(pdfImagePage)
                context.restoreGState()
                
            }
        }
    }
    
}

extension CALayer {
    
    fileprivate func debugLog() -> Self {
        print("---")
        print("Layer draw info")
        debugPrint(type(of: self), "delegate:", delegate as Any)
        if let ctx = UIGraphicsGetCurrentContext() {
            print("frame:", frame, "bounds: ", bounds, "clip box:", ctx.boundingBoxOfClipPath)
            print("background color:", backgroundColor as Any)
        }
        return self
    }
}
