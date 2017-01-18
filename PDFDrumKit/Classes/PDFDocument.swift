//
//  PDFDocument.swift
//  Pods
//
//  Created by Fabio Borella on 18/01/17.
//
//

import Foundation
import UIKit

public class PDFDocument {
    
    public var title: String?
    private var _filename: String!
    public var filename: String?
    public var author: String?
    
    public var pagesHeader: PDFHeader?
    public var pagesFooter: PDFFooter?
    
    public var defaultPageSize: PDFPageSize?
    public var defaultPageMargins: UIEdgeInsets?
    
    public private(set) var pdfPath: String?
    public private(set) var pages: [PDFPage] = []
    
    public init() {
        
    }
    
    public var pdfMetadata: [String: AnyObject] {
        var metadata: [String: AnyObject] = [
            kCGPDFContextCreator as String : "\(kPDFDrumKitDisplayName) v.\(kPDFDrumKitVersion) - \(kPDFDrumKitInfo)"
        ]
        if let title = title {
            metadata[kCGPDFContextTitle as String] = title
        } else if let _filename = _filename {
            metadata[kCGPDFContextTitle as String] = NSString(string: _filename).stringByDeletingPathExtension
        }
        if let author = author {
            metadata[kCGPDFContextAuthor as String] = author
        }
        return metadata
    }
    
    public func addPage(page: PDFPage) {
        if page.pageSize == nil {
            page.pageSize = defaultPageSize
        }
        if page.margins == nil {
            page.margins = defaultPageMargins
        }
        pages.append(page)
    }
    
    public func generate() {
        
        if let filename = filename {
            _filename = filename
        } else {
            _filename = String("PDFBuilder_\(NSProcessInfo.processInfo().globallyUniqueString).pdf")
        }
        
        // Sanitize the pdf filename
        
        _filename = _filename.sanitizedPDFFilenameString
        
        let tmpPath = NSString(string: NSTemporaryDirectory()).stringByAppendingPathComponent(_filename) as! String
        
        pdfPath = tmpPath
        
        // Define PDF context
        
        var pagesSize = CGRectZero
        if let defaultPageSize = defaultPageSize {
            pagesSize = CGRect(origin: CGPointZero,
                               size: defaultPageSize.size)
        }
        
        UIGraphicsBeginPDFContextToFile(tmpPath, pagesSize, pdfMetadata)
        
        // Perform draw pages
        
        for page in pages {
            page._pageHeader = pagesHeader
            page._pageFooter = pagesFooter
            page.draw()
        }
        
        UIGraphicsEndPDFContext()
        
    }
    
}
