//
//  NetworkActivityIndicatorVisible.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import UIKit

/**
 서버 통신을 할 동안 터치 활성화, 비활성화 하는 클래스
 */
class NetworkActivityIndicatorVisible{
    
    /**
     서버 통신을 할 동안 터치 비활성화하고 상단에 indicator 돌게하는 함수.
     */
    class func disable(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        UIApplication.shared.beginIgnoringInteractionEvents()// 터치 비활성화
    }
    
    /**
     서버 통신을 할 동안 터치 활성화하고 상단에 indicator 안돌게하는 함수.
     */
    class func enable(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        UIApplication.shared.endIgnoringInteractionEvents() // 터치 활성화
    }
}

