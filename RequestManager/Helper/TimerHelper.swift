//
//  TimerHelper.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import UIKit

typealias MethodHandler = () -> Void

class TimerHelper{
    static let shared = TimerHelper()
    private var timer : Timer?
    private var method : MethodHandler!
    
    @objc private func selector(){
        self.method()
    }
    
    func setTimer(interval : Double, methodHandler : @escaping MethodHandler){
        self.method = methodHandler
        if self.timer == nil{
            self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.selector), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer(){
        if self.timer != nil{
            self.timer!.invalidate()
            self.timer = nil
        }
    }
}
