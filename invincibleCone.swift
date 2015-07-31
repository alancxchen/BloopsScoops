//
//  invincibleCone.swift
//  Drops
//
//  Created by Alan on 7/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class invincibleCone: Cone {
    var coneClippingNode : CCClippingNode!
    var coneSilhouette : CCSprite!
    var rainbowColor : CCSprite!
    
    override func didLoadFromCCB() {
        coneClippingNode.stencil = coneSilhouette
        coneClippingNode.alphaThreshold = 0.0
    }
}
