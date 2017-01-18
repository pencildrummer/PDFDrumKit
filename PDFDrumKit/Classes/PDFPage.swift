//
//  PDFPage.swift
//  Pods
//
//  Created by Fabio Borella on 18/01/17.
//
//

import Foundation
import UIKit

public class PDFPage {
    
    public var pageSize: PDFPageSize?
    public var margins: UIEdgeInsets?
    
    internal var _pageHeader: PDFHeader?
    internal var _pageFooter: PDFFooter?
    
    public private(set) var items: [PDFDrawableItem] = []
    
    public init() {
        
    }
    
    public func addItem(pdfItem: PDFDrawableItem) {
        items.append(pdfItem)
    }
    
    // MARK: Private
    
    internal var pageDrawableRect: CGRect {
        if let pageSize = pageSize {
            let pageRect = CGRect(origin: CGPointZero, size: pageSize.size)
            return UIEdgeInsetsInsetRect(pageRect, margins ?? UIEdgeInsetsZero)
        }
        return CGRectZero
    }
    
    internal var pageContentDrawableRect: CGRect {
        var pageContentDrawableRect = pageDrawableRect
        if let pageHeader = _pageHeader {
            pageContentDrawableRect.origin.y += CGRectGetHeight(pageHeader.drawBounds)
            pageContentDrawableRect.size.height -= CGRectGetHeight(pageHeader.drawBounds)
        }
        if let pageFooter = _pageFooter {
            pageContentDrawableRect.size.height -= CGRectGetHeight(pageFooter.drawBounds)
        }
        return pageContentDrawableRect
    }
    
//    private func drawRectForItem(item: PDFItem, inPage pageSize: PDFPageSize) -> CGRect {
//        
//        let contentRect = pageRectForPageSize(pageSize)
//        
//        let itemBounds = normalizeBoundsForItem(item, inPage: pageSize)
//        
//        if item == pageHeader {
//            return CGRect(origin: contentRect.origin,
//                          size: itemBounds.size)
//        } else if item == pageFooter {
//            return CGRect(origin: CGPoint(x: CGRectGetMinX(contentRect), y: CGRectGetMaxY(contentRect) - CGRectGetHeight(itemBounds)),
//                          size: itemBounds.size)
//        } else if let itemIndex = drawableItems.indexOf({ $0 as? PDFItem == item }) {
//            return item.frame
//        }
//        
//        return CGRectZero
//    }
    
    private func calculateFrameForItems() {
        let contentRect = pageContentDrawableRect
        var lastOrigin = contentRect.origin
        items = items.map { item in
            
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
    
    private func normalizedBoundsForItem(item: PDFItem) -> CGRect {
        let pageRect = pageDrawableRect
        var bounds = item.drawBounds
        if bounds.size.width == 0 {
            bounds.size.width = pageRect.size.width
        } else if bounds.size.height == 0 {
            bounds.size.height = pageRect.size.height
        }
        return bounds
    }
    
    // MARK: Draw
    
    internal func draw() {
        
        guard let pageSize = pageSize else {
            // TODO - Throw exception to set defaultPageSize on document or pageSize on page
            return
        }
        
        UIGraphicsBeginPDFPageWithInfo(pageSize.bounds, nil)
        
        // If there is a page header draw it
        if let pageHeader = _pageHeader {
            // Set the drawRect on the item
            let itemBounds = normalizedBoundsForItem(pageHeader)
            pageHeader.frame = CGRect(origin: pageDrawableRect.origin,
                                      size: itemBounds.size)
            // Performs the drawing
            pageHeader.draw()
        }
        
        calculateFrameForItems()
        
        for item in items {
            // Performs the drawing
            item.draw()
        }
        
        // If there is a page footer draw it
        if let pageFooter = _pageFooter {
            // Set the drawRect on the item
            let itemBounds = normalizedBoundsForItem(pageFooter)
            let pageContentDrawableRect = self.pageContentDrawableRect
            pageFooter.frame = CGRect(origin: CGPoint(x: pageContentDrawableRect.origin.x, y: CGRectGetMaxY(pageContentDrawableRect))
                , size: itemBounds.size)
            // Performs the drawing
            pageFooter.draw()
        }
        
    }
    
}
