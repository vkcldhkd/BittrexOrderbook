//
//  ItemTableViewCell.swift
//  RequestManager
//
//  Created by BV on 2018. 6. 4..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import UIKit
import RxSwift

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
    }
}

extension ItemTableViewCell {
    func setView(isSell: Bool, backgroundColor: UIColor, rate: Double?, quantity: Double?){
        
        self.backgroundColor = backgroundColor
        
        self.priceTextField.rx.text.asObservable()
            .distinctUntilChanged()
            .share()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                if text != "\(rate ?? 0.0)"{
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 1.0, animations: {
                            self.backgroundColor = isSell ? .red : .blue
                            self.backgroundColor = backgroundColor
                        })
                    }
                }
            })
            .disposed(by: self.disposeBag)
        
        
        self.priceTextField.text = "\(rate ?? 0.0)"
        self.amountTextField.text = "\(quantity ?? 0.0)"
    }
}
