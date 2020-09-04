//
//  Color.swift
//  accolade
//
//  Created by Matěj Novák on 06.04.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation

extension UIColor {
    convenience init(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
          let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
          let scanner = Scanner(string: hexString)
          if (hexString.hasPrefix("#")) {
              scanner.scanLocation = 1
          }
          var color: UInt32 = 0
          scanner.scanHexInt32(&color)
          let mask = 0x000000FF
          let r = Int(color >> 16) & mask
          let g = Int(color >> 8) & mask
          let b = Int(color) & mask
          let red   = CGFloat(r) / 255.0
          let green = CGFloat(g) / 255.0
          let blue  = CGFloat(b) / 255.0
          self.init(red:red, green:green, blue:blue, alpha:alpha)
      }
      func toHexString() -> String {
          var r:CGFloat = 0
          var g:CGFloat = 0
          var b:CGFloat = 0
          var a:CGFloat = 0
          getRed(&r, green: &g, blue: &b, alpha: &a)
          let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
          return String(format:"#%06x", rgb)
      }
      
      func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
          return self.adjust(by: abs(percentage) )
      }
      
      func darker(by percentage: CGFloat = 30.0) -> UIColor? {
          return self.adjust(by: -1 * abs(percentage) )
      }
      
      func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
          var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
          if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
              return UIColor(red: min(red + percentage/100, 1.0),
                             green: min(green + percentage/100, 1.0),
                             blue: min(blue + percentage/100, 1.0),
                             alpha: alpha)
          } else {
              return nil
          }
      }
      
      func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
          var r: CGFloat = 0
          var g: CGFloat = 0
          var b: CGFloat = 0
          var a: CGFloat = 0
          
          getRed(&r, green: &g, blue: &b, alpha: &a)
          
          return (r, g, b, a)
      }
      
      func combine(with color: UIColor, amount: CGFloat) -> UIColor {
          let fromComponents = components()
          
          let toComponents = color.components()
          
          let redAmount = lerp(from: fromComponents.red,
                               to: toComponents.red,
                               alpha: amount)
          let greenAmount = lerp(from: fromComponents.green,
                                 to: toComponents.green,
                                 alpha: amount)
          let blueAmount = lerp(from: fromComponents.blue,
                                to: toComponents.blue,
                                alpha: amount)
          
          
          let color = UIColor(red: redAmount,
                              green: greenAmount,
                              blue: blueAmount,
                              alpha: 1)
          
          return color
      }
      func lerp(from a: CGFloat, to b: CGFloat, alpha: CGFloat) -> CGFloat {
          return (1 - alpha) * a + alpha * b
      }

}

func rgba(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat) -> UIColor {
    return UIColor(r, g, b, a)
}
