//
//  CircleView.swift
//  Pay4All
//
//  Created by Carlos Doki on 27/07/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }
    
}
