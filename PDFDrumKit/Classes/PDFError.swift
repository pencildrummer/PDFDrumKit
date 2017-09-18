//
//  PDFError.swift
//  Pods
//
//  Created by Fabio Borella on 21/07/17.
//
//

import Foundation

enum PDFError: Error {
    
    case invalidPageSize
    
    var localizedDescription: String {
        switch self {
        case .invalidPageSize:
            return "Invalid page size. Set a defaultPageSize on document or a pageSize on page."
        }
    }
    
}
