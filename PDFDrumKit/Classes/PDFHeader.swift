//
//  PDFHeader.swift
//  Pods
//
//  Created by Fabio Borella on 13/07/16.
//
//

import Foundation

open class PDFHeader: PDFItem {
    
    open override var drawBounds: CGRect {
        return CGRect(x: 0, y: 0, width: 0, height: 30)
    }
    
}
