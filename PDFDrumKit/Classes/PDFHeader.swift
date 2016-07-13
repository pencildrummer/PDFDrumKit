//
//  PDFHeader.swift
//  Pods
//
//  Created by Fabio Borella on 13/07/16.
//
//

import Foundation

public class PDFHeader: PDFItem {
    
    public override var drawBounds: CGRect {
        return CGRect(x: 0, y: 0, width: 0, height: 30)
    }
    
    public override func drawItem(rect: CGRect) {
        
    }
    
}