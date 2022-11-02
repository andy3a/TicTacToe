//
//  CollectionViewCell.swift
//  TicTacToe
//
//  Created by Andrew_Alekseyuk on 15.04.22.
//

import UIKit
import TinyConstraints

class CollectionViewCell: UICollectionViewCell {
    
    var isPressed = false
    var userType: Int?
    var row: Int?
    var column: Int?
    var imageView = UIImageView()
    
    func configure(object: TicTacToeModel) {
        userType = object.userType
        row = object.row
        column = object.column
        self.backgroundColor = .systemGray6
        imageView.removeFromSuperview()
        
        if userType == 0 {
            imageView.contentMode = .scaleAspectFill
            self.addSubview(imageView)
            imageView.edgesToSuperview()
            imageView.image = UIImage(named: "cross")
        }
        if userType == 1 {
            self.addSubview(imageView)
            imageView.edgesToSuperview()
            imageView.image = UIImage(named: "circle")
        }
        
        
    }
    
}
