//
//  PDFDocument.swift
//  Pods
//
//  Created by Fabio Borella on 18/01/17.
//
//

import Foundation
import UIKit

open class PDFDocument {
    
    open var title: String?
    fileprivate var _filename: String!
    open var filename: String?
    open var author: String?
    
    open var pagesHeader: PDFHeader?
    open var pagesFooter: PDFFooter?
    
    open var defaultPageSize: PDFPageSize?
    open var defaultPageMargins: UIEdgeInsets?
    
    open fileprivate(set) var pdfPath: String?
    open fileprivate(set) var pages: [PDFPage] = []
    
    public init() {
        
    }
    
    open var pdfMetadata: [String: AnyObject] {
        var metadata: [String: AnyObject] = [
            kCGPDFContextCreator as String : "\(kPDFDrumKitDisplayName) v.\(kPDFDrumKitVersion) - \(kPDFDrumKitInfo)"
        ]
        if let title = title {
            metadata[kCGPDFContextTitle as String] = title
        } else if let _filename = _filename {
            metadata[kCGPDFContextTitle as String] = NSString(string: _filename).deletingPathExtension
        }
        if let author = author {
            metadata[kCGPDFContextAuthor as String] = author
        }
        return metadata
    }
    
    open func addPage(_ page: PDFPage) {
        if page.pageSize == nil {
            page.pageSize = defaultPageSize
        }
        if page.margins == nil {
            page.margins = defaultPageMargins
        }
        pages.append(page)
    }
    
    open func generate() {
        
        if let filename = filename {
            _filename = filename
        } else {
            _filename = String("PDFBuilder_\(ProcessInfo.processInfo().globallyUniqueString).pdf")
        }
        
        // Sanitize the pdf filename
        
        _filename = _filename.sanitizedPDFFilenameString
        
        let tmpPath = NSString(string: NSTemporaryDirectory()).appendingPathComponent(_filename) as! String
        
        pdfPath = tmpPath
        
        // Define PDF context
        
        var pagesSize = CGRect.zero
        if let defaultPageSize = defaultPageSize {
            pagesSize = CGRect(origin: CGPoint.zero,
                               size: defaultPageSize.size)
        }
        
        UIGraphicsBeginPDFContextToFile(tmpPath, pagesSize, pdfMetadata)
        
        // Perform draw pages
        
        for page in pages {
            if page.pageHeader == nil {
                page.pageHeader = pagesHeader
            }
            if page.pageFooter == nil {
                page.pageFooter = pagesFooter
            }
            page.draw()
        }
        
        UIGraphicsEndPDFContext()
        
    }
    
}
