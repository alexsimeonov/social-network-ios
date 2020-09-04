//
//  DateManager.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 21.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation

final class DateManager {
    static var shared = DateManager()
    
    private init() { }
    
    func formatDate(_ timestamp: AnyObject) -> String {
        let date = timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        
        return formatter.string(from: date as! Date)
    }
    
    func formatDateExtended(from string: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let newDate = dateFormatter.date(from: string)
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let result = dateFormatter.string(from: newDate!)
        
        return result
    }
}
