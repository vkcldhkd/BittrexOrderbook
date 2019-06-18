//
//  ItemTableViewCell.swift
//  RequestManager
//
//  Created by BV on 2018. 6. 4..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import UIKit
import RxSwift
import RxOptional

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
        
        Observable.just(backgroundColor)
        .bind(to: self.rx.backgroundColor)
        .disposed(by: disposeBag)
        
        
        self.priceTextField.rx.text.asObservable()
            .distinctUntilChanged()
            .filter{ "\(rate ?? 0.0)" != $0 }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: 1.0, animations: {
                    self.backgroundColor = isSell ? .red : .blue
                    self.backgroundColor = backgroundColor
                })
            })
            .disposed(by: self.disposeBag)
        
        Observable.just(rate)
            .filterNil()
            .map{ "\($0)" }
            .bind(to: priceTextField.rx.text)
            .disposed(by: disposeBag)
        
        
        Observable.just(quantity)
            .filterNil()
            .map{ "\($0)" }
            .bind(to: amountTextField.rx.text)
            .disposed(by: disposeBag)
        
        

    }
}
