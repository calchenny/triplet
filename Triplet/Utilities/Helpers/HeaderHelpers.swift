//
//  HeaderHelpers.swift
//  Triplet
//
//  Created by Derek Ma on 3/15/24.
//

import Foundation

func getHeaderWidthScale(collapseProgress: CGFloat, screenWidth: CGFloat) -> CGFloat {
    let maxWidth = screenWidth * 0.9
    let minWidth = screenWidth * 0.5
    return max((1 - collapseProgress + 0.5 * collapseProgress) * maxWidth, minWidth) / maxWidth
}

func getHeaderHeightScale(collapseProgress: CGFloat) -> CGFloat {
    let maxHeight = CGFloat(100)
    let minHeight = CGFloat(60)
    return max((1 - collapseProgress + 0.5 * collapseProgress) * maxHeight, minHeight) / maxHeight
}
