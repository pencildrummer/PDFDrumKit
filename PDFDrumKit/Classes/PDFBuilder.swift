//
//  PDFBuilder.swift
//  Pods
//
//  Created by Fabio Borella on 07/07/16.
//
//

import Foundation
//import FeedbackUI
import UIKit

public protocol PDFDrawableItem: NSObjectProtocol {
    
    var drawBounds: CGRect { get }
    func drawItem(rect: CGRect)
    
}

internal protocol PDFDrawableItemInternal: class, NSObjectProtocol {
    
    var _drawRect: CGRect { get }
    
}

public class PDFItem: UIView, PDFDrawableItem, PDFDrawableItemInternal {
    
    internal var _drawRect: CGRect = CGRectZero
    
    public var drawBounds: CGRect {
        setNeedsLayout()
        layoutIfNeeded()
        return bounds
    }
    
    public func drawItem(rect: CGRect) {
        frame = rect
        drawViewHierarchyInRect(rect, afterScreenUpdates: true)
    }
    
}

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
}

public class PDFBuilder {
    
    public var defaultPageSize: PDFPageSize = .A4
    public var pageMargin: UIEdgeInsets = UIEdgeInsetsZero
    
    public var pageHeader: PDFItem?
    public var pageFooter: PDFItem?
    
    public private(set) var pdfPath: String!
    
    private var drawableItems: [PDFItem] = []
    private var drawableItemsRects: [CGRect] = []

    public init() {}
    
    public func appendItem(item: PDFItem) {
        drawableItems.append(item)
        //drawableItems.indexOf({ $0 as? PDFItem == item })drawableItems.append(item as! protocol<PDFDrawableItem, PDFDrawableItemInternal>)
    }
    
    private func sizeForPageSize(pageSize: PDFPageSize) -> CGSize {
        switch pageSize {
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
    
    private func pageRectForPageSize(pageSize: PDFPageSize) -> CGRect {
        let sheetRect = CGRect(origin: CGPointZero, size: sizeForPageSize(pageSize))
        return UIEdgeInsetsInsetRect(sheetRect, pageMargin)
    }
    
    private func contentRectForPageSize(pageSize: PDFPageSize) -> CGRect {
        var contentRect = pageRectForPageSize(pageSize)
        if let pageHeader = pageHeader {
            contentRect.origin.y += CGRectGetHeight(pageHeader.drawBounds)
            contentRect.size.height -= CGRectGetHeight(pageHeader.drawBounds)
        }
        if let pageFooter = pageFooter {
            contentRect.size.height -= CGRectGetHeight(pageFooter.drawBounds)
        }
        return contentRect
    }
    
    private func drawRectForItem(item: PDFItem, inPage pageSize: PDFPageSize) -> CGRect {
        
        let contentRect = pageRectForPageSize(pageSize)
        
        let itemBounds = normalizeBoundsForItem(item, inPage: pageSize)
        
        if item == pageHeader {
            return CGRect(origin: contentRect.origin,
                          size: itemBounds.size)
        } else if item == pageFooter {
            return CGRect(origin: CGPoint(x: CGRectGetMinX(contentRect), y: CGRectGetMaxY(contentRect) - CGRectGetHeight(itemBounds)),
                          size: itemBounds.size)
        } else if let itemIndex = drawableItems.indexOf({ $0 as? PDFItem == item }) {
            return drawableItemsRects[itemIndex]
        }
        
        return CGRectZero
    }
    
    private func calculateRectForItems(inPage pageSize: PDFPageSize) {
        var contentRect = contentRectForPageSize(pageSize)
        var lastOrigin = contentRect.origin
        for (index, item) in drawableItems.enumerate() {
            
            var availableSize = UILayoutFittingCompressedSize
            availableSize.width = CGRectGetWidth(contentRect)
            
            let size = item.systemLayoutSizeFittingSize(availableSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
            let drawableItemRect = CGRect(origin: lastOrigin, size: size)
            
            drawableItemsRects.append(drawableItemRect)
            
            lastOrigin.y = lastOrigin.y + CGRectGetHeight(item.drawBounds)
        }
    }
    
    private func normalizeBoundsForItem(item: PDFDrawableItem, inPage pageSize: PDFPageSize) -> CGRect {
        let pageRect = pageRectForPageSize(pageSize)
        var bounds = item.drawBounds
        if bounds.size.width == 0 {
            bounds.size.width = pageRect.size.width
        } else if bounds.size.height == 0 {
            bounds.size.height = pageRect.size.height
        }
        return bounds
    }
    
    public func drawPDF() {
        
        let pdfFileName = String("PDFBuilder_\(NSProcessInfo.processInfo().globallyUniqueString).pdf")
        let tmpPath = NSTemporaryDirectory() + "/" + pdfFileName
        
        pdfPath = tmpPath
        
        let pageSize = defaultPageSize
        
        calculateRectForItems(inPage: pageSize)
        
        UIGraphicsBeginPDFContextToFile(tmpPath, CGRectZero, nil)
        
        let sheetRect = CGRect(origin: CGPointZero, size: sizeForPageSize(pageSize))
        UIGraphicsBeginPDFPageWithInfo(sheetRect, nil)
        
        // If there is a page header draw it
        if let pageHeader = pageHeader {
            // Set the drawRect on the item
            pageHeader._drawRect = drawRectForItem(pageHeader, inPage: pageSize)
            // Performs the drawing
            performDrawItem(pageHeader)
        }
        
        for item in drawableItems {
            
            // Set the drawRect on the item
            item._drawRect = drawRectForItem(item, inPage: pageSize)
            // Performs the drawing
            performDrawItem(item)
        }
        
        // If there is a page footer draw it
        if let pageFooter = pageFooter {
            // Set the drawRect on the item
            pageFooter._drawRect = drawRectForItem(pageFooter, inPage: pageSize)
            // Performs the drawing
            performDrawItem(pageFooter)
        }
        
        UIGraphicsEndPDFContext()
        
    }
    
    private func performDrawItem(item: PDFItem) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(context)
        
        var drawBounds: CGRect = CGRectZero
        
        CGContextTranslateCTM(context, item._drawRect.origin.x, item._drawRect.origin.y)
        drawBounds = item._drawRect
        drawBounds.origin = CGPointZero
        
        item.drawItem(drawBounds)
        
        CGContextRestoreGState(context)
        
    }
    
}