//
//  PDFBuilder.swift
//  Pods
//
//  Created by Fabio Borella on 07/07/16.
//
//

import Foundation
import UIKit

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
    
    public var filename: String?
    
    public var defaultPageSize: PDFPageSize = .A4
    public var pageMargin: UIEdgeInsets = UIEdgeInsets(top: 40, left: 50, bottom: 40, right: 50)
    
    public var pageHeader: PDFItem?
    public var pageFooter: PDFItem?
    
    public private(set) var pdfPath: String!
    
    private var drawableItems: [PDFItem] = []

    public init() {}
    
    public func appendItem(item: PDFItem) {
        drawableItems.append(item)
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
            return item.frame
        }
        
        return CGRectZero
    }
    
    private func calculateFrameForItems(inPage pageSize: PDFPageSize) {
        let contentRect = contentRectForPageSize(pageSize)
        var lastOrigin = contentRect.origin
        drawableItems = drawableItems.map { item in
            var availableSize = UILayoutFittingCompressedSize
            availableSize.width = CGRectGetWidth(contentRect) - item.layoutMargins.left - item.layoutMargins.right
            
            let size = item.systemLayoutSizeFittingSize(availableSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
            var drawableItemRect = CGRect(origin: lastOrigin, size: size)
            
            drawableItemRect.origin.y = drawableItemRect.origin.y + item.layoutMargins.top
            
            item.frame = drawableItemRect
            
            lastOrigin.y = lastOrigin.y + CGRectGetHeight(item.drawBounds) + item.layoutMargins.top + item.layoutMargins.bottom
            
            return item
        }
    }
    
    private func normalizeBoundsForItem(item: PDFItem, inPage pageSize: PDFPageSize) -> CGRect {
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
        
        var pdfFileName: String
        if filename?.isEmpty ?? true {
            pdfFileName = String("PDFBuilder_\(NSProcessInfo.processInfo().globallyUniqueString).pdf")
        } else {
            pdfFileName = filename!
        }
        
        // Sanitize the pdf filename
        
        pdfFileName = pdfFileName.sanitizedPDFFilenameString
        
        let tmpPath = NSString(string: NSTemporaryDirectory()).stringByAppendingPathComponent(pdfFileName) as! String
        
        pdfPath = tmpPath
        
        let pageSize = defaultPageSize
        
        calculateFrameForItems(inPage: pageSize)
        
        UIGraphicsBeginPDFContextToFile(tmpPath, CGRectZero, nil)
        
        let sheetRect = CGRect(origin: CGPointZero, size: sizeForPageSize(pageSize))
        UIGraphicsBeginPDFPageWithInfo(sheetRect, nil)
        
        // If there is a page header draw it
        if let pageHeader = pageHeader {
            // Set the drawRect on the item
            pageHeader.frame = drawRectForItem(pageHeader, inPage: pageSize)
            // Performs the drawing
            performDrawItem(pageHeader)
        }
        
        for item in drawableItems {
            // Set the drawRect on the item
            item.frame = drawRectForItem(item, inPage: pageSize)
            // Performs the drawing
            performDrawItem(item)
        }
        
        // If there is a page footer draw it
        if let pageFooter = pageFooter {
            // Set the drawRect on the item
            pageFooter.frame = drawRectForItem(pageFooter, inPage: pageSize)
            // Performs the drawing
            performDrawItem(pageFooter)
        }
        
        UIGraphicsEndPDFContext()
        
    }
    
    private func performDrawItem(item: PDFItem) {
        
        if let context = UIGraphicsGetCurrentContext() {
         
            CGContextSaveGState(context)
            
            CGContextTranslateCTM(context, item.frame.origin.x, item.frame.origin.y)
            CGContextClipToRect(context, item.bounds)
            
            item.layer.drawInContext(context)
            
            CGContextRestoreGState(context)
            
        }
        
    }
    
}

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
