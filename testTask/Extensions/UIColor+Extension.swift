//
//  UIColor+Extension.swift
//  testTask
//
//  Created by tixomark on 4/29/23.
//

import Foundation
import UIKit

extension UIColor {
    static var TTsystemColor: UIColor {
        guard let color = UIColor(named: "TTSystemColor") else {
            print("Can not find 'TTSystemColor' in assets folder")
            return UIColor()
        }
        return color
    }
    
    static var TTContrastColor: UIColor {
        guard let color = UIColor(named: "TTContrastColor") else {
            print("Can not find 'TTSecondarySystemColor' in assets folder")
            return UIColor()
        }
        return color
    }
}
