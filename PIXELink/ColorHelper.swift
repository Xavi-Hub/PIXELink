//
//  ColorHelper.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 7/5/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//

import Foundation

class ColorHelper {
    
    // Coverts the given sRGB values (0-255) to D65/2 XYZ values
    public static func sRGBToXYZ(red: Int, green: Int, blue: Int) -> (X: Double, Y: Double, Z: Double) {
        
        var varR = Double(red) / 255
        var varG = Double(green) / 255
        var varB = Double(blue) / 255
        
        if varR > 0.04045 {
            varR = pow(( varR + 0.055 ) / 1.055, 2.4)
        } else {
            varR = varR / 12.92
        }
        if varG > 0.04045 {
            varG = pow(( varG + 0.055 ) / 1.055 ,2.4)
        } else {
            varG = varG / 12.92
        }
        if varB > 0.04045 {
            varB = pow(( varB + 0.055 ) / 1.055, 2.4)
        } else {
            varB = varB / 12.92
        }
        
        varR = varR * 100
        varG = varG * 100
        varB = varB * 100
        
        let X = varR * 0.4124 + varG * 0.3576 + varB * 0.1805
        let Y = varR * 0.2126 + varG * 0.7152 + varB * 0.0722
        let Z = varR * 0.0193 + varG * 0.1192 + varB * 0.9505
        
        
        return (X,Y,Z)
    }
    
    //Converts the given D65/2 XYZ values to CIE L*ab values
    public static func XYZToLab(X: Double, Y: Double, Z: Double) -> (L: Double, a: Double, b: Double) {
        
        let referenceX = 95.047
        let referenceY = 100.000
        let referenceZ = 108.883
        
        var varX = X / referenceX
        var varY = Y / referenceY
        var varZ = Z / referenceZ
        
        if varX > 0.008856 {
            varX = pow(varX, 1/3)
        } else {
            varX = (7.787 * varX) + (16 / 116)
        }
        if varY > 0.008856 {
            varY = pow(varY, 1/3)
        } else {
            varY = ( 7.787 * varY ) + ( 16 / 116 )
        }
        if varZ > 0.008856 {
            varZ = pow(varZ, 1/3)
        } else {
            varZ = ( 7.787 * varZ ) + ( 16 / 116 )
        }
        
        let L = ( 116 * varY ) - 16
        let a = 500 * ( varX - varY )
        let b = 200 * ( varY - varZ )
        
        
        return (L,a,b)
    }
    
    // Converts the given sRGB values (0-255) to CIE L*ab values
    public static func sRGBToLab(red: Int, green: Int, blue: Int) -> (L: Double, a: Double, b: Double) {
        
        let XYZ = sRGBToXYZ(red: red, green: green, blue: blue)
        let Lab = XYZToLab(X: XYZ.X, Y: XYZ.Y, Z: XYZ.Z)
        
        return (Lab.L, Lab.a, Lab.b)
    }
    
    // Calculates the color difference of the 2 given L*ab colors
    public static func deltaE(color1: (L: Double, a: Double, b: Double), color2: (L: Double, a: Double, b: Double)) -> Double {
        
        let CIE_L1 = color1.L
        let CIE_a1 = color1.a
        let CIE_b1 = color1.b          // Color #1 CIE-L*ab values
        let CIE_L2 = color2.L
        let CIE_a2 = color2.a
        let CIE_b2  = color2.b         // Color #2 CIE-L*ab values
        let whtL: Double = 1
        let whtC: Double = 1
        let whtH: Double = 1             // Weight factors
        
        var xC1 = sqrt(CIE_a1 * CIE_a1 + CIE_b1 * CIE_b1)
        var xC2 = sqrt(CIE_a2 * CIE_a2 + CIE_b2 * CIE_b2)
        let xCX = (xC1 + xC2) / 2
        let xGX: Double = {
            let first =  pow(xCX, 7) / (pow(xCX, 7) + pow(25, 7))
            let root = 1 - sqrt(first)
            let last = 0.5 * root
            return last
        }()
        var xNN = (1 + xGX) * CIE_a1
        xC1 = sqrt(xNN * xNN + CIE_b1 * CIE_b1)
        let xH1 = CieLab2Hue(var_a: xNN, var_b: CIE_b1)
        xNN = (1 + xGX) * CIE_a2
        xC2 = sqrt(xNN * xNN + CIE_b2 * CIE_b2)
        let xH2 = CieLab2Hue(var_a: xNN, var_b: CIE_b2)
        var xDL = CIE_L2 - CIE_L1
        var xDC = xC2 - xC1
        var xDH: Double = 0
        if (xC1 * xC2) == 0 {
            xDH = 0
        } else {
            xNN = xH2 - xH1
            if abs(xNN) <= 180 {
                xDH = xH2 - xH1
            }
            else {
                if xNN > 180 {
                    xDH = xH2 - xH1 - 360
                } else {
                    xDH = xH2 - xH1 + 360
                }
            }
        }
        
        xDH = 2 * sqrt(xC1 * xC2) * sin(dtor(xDH / 2))
        let xLX = (CIE_L1 + CIE_L2) / 2
        let xCY = (xC1 + xC2) / 2
        var xHX: Double = 0
        if ((xC1 *  xC2) == 0) {
            xHX = xH1 + xH2
        }
        else {
            xNN = abs(xH1 - xH2)
            if ( xNN >  180 ) {
                if ( xH2 + xH1 ) <  360 {
                    xHX = xH1 + xH2 + 360
                } else {
                    xHX = xH1 + xH2 - 360
                }
            }
            else {
                xHX = xH1 + xH2
            }
            xHX /= 2
        }
        let xTX = 1 - 0.17 * cos(dtor(xHX - 30 ) ) + 0.24
            * cos(dtor(2 * xHX)) + 0.32
            * cos(dtor(3 * xHX + 6)) - 0.20
            * cos(dtor(4 * xHX - 63))
        let xPH = 30 * exp(-((xHX - 275) / 25) * ((xHX - 275) / 25))
        let xRC = 2 * sqrt(pow(xCY, 7 ) / (pow(xCY, 7) + pow(25, 7)))
        let xSL = 1 + ((0.015 * ((xLX - 50) * (xLX - 50)))
            / sqrt(20 + ((xLX - 50) * (xLX - 50))))
        
        let xSC = 1 + 0.045 * xCY
        let xSH = 1 + 0.015 * xCY * xTX
        let xRT = -sin(dtor(2 * xPH)) * xRC
        xDL = xDL / (whtL * xSL)
        xDC = xDC / (whtC * xSC)
        xDH = xDH / (whtH * xSH)
        
        let deltaE00 = sqrt(pow(xDL, 2) + pow(xDC, 2) + pow(xDH, 2) + xRT * xDC * xDH)
        
        return deltaE00
    }
    
    // Returns CIE-H° value
    public static func CieLab2Hue(var_a: Double, var_b: Double) -> Double {
        var var_bias: Double = 0
        if var_a >= 0 && var_b == 0 {return 0}
        if var_a <  0 && var_b == 0 {return 180}
        if var_a == 0 && var_b >  0 {return 90}
        if var_a == 0 && var_b <  0 {return 270}
        if var_a >  0 && var_b >  0 {var_bias = 0}
        if var_a <  0 {var_bias = 180}
        if var_a >  0 && var_b <  0 {var_bias = 360}
        return self.rad2deg(atan(var_b / var_a)) + var_bias
    }
    
    // Finds the color difference of the 2 give sRGB colors
    public static func deltaE(color1: (red: Int, green: Int, blue: Int), color2: (red: Int, green: Int, blue: Int)) -> Double {
        
        let lab1 = sRGBToLab(red: color1.red, green: color1.green, blue: color1.blue)
        let lab2 = sRGBToLab(red: color2.red, green: color2.green, blue: color2.blue)
        
        let deltaE = self.deltaE(color1: lab1, color2: lab2)
        
        return deltaE
    }

    public static func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    
    public static func dtor(_ number: Double) -> Double {
        return number * (.pi / 180);
    }


    
}
