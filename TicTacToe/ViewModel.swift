//
//  ViewModel.swift
//  TicTacToe
//
//  Created by Andrew_Alekseyuk on 20.04.22.
//

import Foundation
import UIKit
import RxSwift

class ViewModel {
    
    let vc: ViewController
    let winnerMessage = PublishSubject<String>()
    var subscription: Disposable?
    
    init(viewController: UIViewController) {
        self.vc = viewController as! ViewController
        subscription =  vc.checkMessage
            .subscribe( onNext: { _ in
                self.checkWinner()
            })
    }
    
    var model: [TicTacToeModel] = []
    
    func setUpModel(completion: @escaping ()->()) {
        model = []
        for i in 0 ..< vc.dimension {
            for j in 0 ..< vc.dimension {
                    let obj:TicTacToeModel = TicTacToeModel()
                    obj.isPressed = false
                    obj.row = i
                    obj.column = j
                    model.append(obj)
                }
            }
        completion()
    }
    
    func checkWinner() {
        let player0 = model.filter({$0.userType == 0})
        let player1 = model.filter({$0.userType == 1})
        
        for i in 0 ..< vc.dimension {
            if player0.filter({$0.column != nil && $0.row == i}).count == vc.dimension ||
                player0.filter({$0.row != nil && $0.column == i}).count == vc.dimension {
                self.winnerMessage.onNext("Crosses win")
            }
        }
        
        for i in 0 ..< vc.dimension {
            if player1.filter({$0.column != nil && $0.row == i}).count == vc.dimension ||
                player1.filter({$0.row != nil && $0.column == i}).count == vc.dimension {
                self.winnerMessage.onNext("Circles win")
            }
        }
        
        if player0.filter({$0.row == $0.column}).count == vc.dimension {
            self.winnerMessage.onNext("Crosses win")
        }
        if player1.filter({$0.row == $0.column}).count == vc.dimension {
            self.winnerMessage.onNext("Circles win")
        }
        
        if player0.filter({$0.row == vc.dimension - 1 - $0.column!}).count == vc.dimension {
            self.winnerMessage.onNext("Crosses win")
        }
        if player1.filter({$0.row == vc.dimension - 1 - $0.column!}).count == vc.dimension {
            self.winnerMessage.onNext("Circles win")
        }
    }
}
