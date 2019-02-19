//
//  LogHelper.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import Foundation

/**
 * log를 찍어주는 함수. 앱 업데이트 시 print만 주석처리 하게되면 loghelper를 호출한 곳에서 로그가 출력되지않음.
 * @param err,str,any,num
 * @Usage LogHelper.printLog(str: msg)
 */
class LogHelper {
    class func printLog(_ err: Error) {
        #if DEBUG
            print(err)
        #else
            
        #endif
    }
    
    class func printLog(_ str : String) {
        #if DEBUG
            print(str)
        #else
            
        #endif
    }
    
    class func printLog(_ any: AnyObject) {
        #if DEBUG
            print(any)
        #else
            
        #endif
    }
    class func printLog(_ num: Int) {
        #if DEBUG
            print(num)
        #else
            
        #endif
    }
}
