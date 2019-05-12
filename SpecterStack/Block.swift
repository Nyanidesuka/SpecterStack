//
//  Block.swift
//  SpecterStack
//
//  Created by Haley Jones on 5/11/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import SpriteKit
class Block{
    var color: String
    var imageName: String
    init(color: String){
        self.color = color
        switch color{
        case "red":
            imageName = "redBlock3x"
        case "blue":
            imageName = "blueBlock3x"
        case "green":
            imageName = "greenBlock3x"
        case "yellow":
            imageName = "yellowBlock3x"
        default:
            imageName = ""
        }
    }
}
