
//
//  Dictionary.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import Foundation

extension Dictionary {
    func jsonToString() -> String{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            return convertedString ?? "defaultvalue"
        } catch let myJSONError {
            return myJSONError.localizedDescription
        }
        
    }

}
