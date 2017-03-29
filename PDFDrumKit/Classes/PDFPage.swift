//
//  PDFPage.swift
//  Pods
//
//  Created by Fabio Borella on 18/01/17.
//
//

import Foundation
import UIKit

open class PDFPage {
    
    open var pageSize: PDFPageSize?
    open var margins: UIEdgeInsets?
    
    open var pageHeader: PDFHeader?
    open var pageFooter: PDFFooter?
    
    open fileprivate(set) var items: [PDFDrawableItem] = []
    
    public init() {
        
    }
    
    open func addItem(_ pdfItem: PDFDrawableItem) {
        items.append(pdfItem)
    }
    
    // MARK: Private
    
    internal var pageDrawableRect: CGRect {
        if let pageSize = pageSize {
            let pageRect = CGRect(origin: CGPoint.zero, size: pageSize.size)
            return UIEdgeInsetsInsetRect(pageRect, margins ?? UIEdgeInsets.zero)
        }
        return CGRect.zero
    }
    
    internal var pageContentDrawableRect: CGRect {
        var pageContentDrawableRect = pageDrawableRect
        if let pageHeader = pageHeader {
            pageContentDrawableRect.origin.y += pageHeader.drawBounds.height
            pageContentDrawableRect.size.height -= pageHeader.drawBounds.height
        }
        if let pageFooter = pageFooter {
            pageContentDrawableRect.size.height -= pageFooter.drawBounds.height
        }
        return pageContentDrawableRect
    }
    
    fileprivate func calculateFrameForItems() {
        let contentRect = pageContentDrawableRect
        var lastOrigin = contentRect.origin
        items = items.map { item in
            
            var availableSize = UILayoutFittingCompressedSize
            availableSize.width = contentRect.width - item.layoutMargins.left - item.layoutMargins.right
            
            let size = item.systemLayoutSizeFittingSize(availableSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityDefaultLow)
            
            var drawableItemRect = CGRect(origin: lastOrigin, size: size)
            
            drawableItemRect.origin.y = drawableItemRect.origin.y + item.layoutMargins.top
            
            item.frame = drawableItemRect
            
            lastOrigin.y = lastOrigin.y + item.drawBounds.height + item.layoutMargins.top + item.layoutMargins.bottom
            
            return item
        }
    }
    
    fileprivate func normalizedBoundsForItem(_ item: PDFItem) -> CGRect {
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
        if let pageHeader = pageHeader {
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
        if let pageFooter = pageFooter {
            // Set the drawRect on the item
            let itemBounds = normalizedBoundsForItem(pageFooter)
            let pageContentDrawableRect = self.pageContentDrawableRect
            pageFooter.frame = CGRect(origin: CGPoint(x: pageContentDrawableRect.origin.x, y: pageContentDrawableRect.maxY)
                , size: itemBounds.size)
            // Performs the drawing
            pageFooter.draw()
        }
        
    }
    
}
