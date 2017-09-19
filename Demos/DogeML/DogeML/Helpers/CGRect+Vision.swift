//
//  CGRect+Vision.swift
//  DogeML
//
//  Created by Michael Thomas on 8/23/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//

import UIKit

extension CGRect {
    
    func convertFromVision(newRect: CGRect) -> CGRect {
        let viewWidth = newRect.size.width
        let viewHeight = newRect.size.height
        let standardRect = self.standardized
        let width = standardRect.size.width * viewWidth
        let height = standardRect.size.height * viewHeight
        let x = standardRect.origin.x * viewWidth
        let y = viewHeight - (standardRect.origin.y * viewHeight) - height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func convertFromVision(withScale scale: CGFloat, newRect: CGRect) -> CGRect {
        let viewWidth = newRect.size.width
        let viewHeight = newRect.size.height
        let standardRect = self.standardized
        let width = standardRect.size.width * viewWidth * scale
        let height = standardRect.size.height * viewHeight * scale
        let x = standardRect.origin.x * viewWidth * scale
        let y = (viewHeight + (standardRect.origin.y * viewHeight) - height) * scale
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
