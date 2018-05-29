//
//  ViewController.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var orderBookTableView: UITableView!
    @IBOutlet weak var valueLabel: UILabel!
    
    var orderBookModel : OrderBookModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        TimerHelper.shared.stopTimer()
    }
}
extension ViewController {
    /**
     * orderbook model 받아오는 함수
     */
    func getOrderBook(){
        DataResponser.getOrderBook { (model) in
            guard let model = model else { return }
            self.orderBookModel = model
            
            DispatchQueue.main.async {
                self.orderBookTableView.reloadData()
            }
        }
    }
    /**
     * orderbook을 1초마다 받아오기 위한 타이머 생성 함수.
     * 타이머는 싱글톤
     */
    func createTimer(){
        self.getOrderBook()
        
        TimerHelper.shared.setTimer(interval: 1.0) {
            self.getOrderBook()
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.orderBookTableView.frame.height / 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.numberOfLines = 0
        
        guard let model = self.orderBookModel ,
        let result = model.result,
        let buyArray = result.buy,
        let sellArray = result.sell else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            cell.backgroundColor = UIColor.blue
            cell.textLabel?.text = buyArray.count > 0 ? "quantity : \(buyArray[indexPath.row].quantity)\nrate:\(buyArray[indexPath.row].rate)" : "nil"
        }else{
            cell.backgroundColor = UIColor.red
            cell.textLabel?.text = sellArray.count > 0 ? "quantity : \(sellArray[indexPath.row].quantity)\nrate:\(sellArray[indexPath.row].rate)" : "nil"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.orderBookTableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let model = self.orderBookModel ,
            let result = model.result,
            let buyArray = result.buy,
            let sellArray = result.sell else { return }
        
        let selectModel = indexPath.section == 0 ? buyArray[indexPath.row] : sellArray[indexPath.row]
        self.valueLabel.text = "quantity : \(selectModel.quantity)\nrate:\(selectModel.rate)"
    }
}

