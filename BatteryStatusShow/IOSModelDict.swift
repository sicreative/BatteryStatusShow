//
//  IOSModelDict.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/6/3.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Foundation

class IOSModelDict{
    
    static func ProductTypeToName(producttype:String)->String{
    
        let dict:[String:String] = [
        "iPhone1,1":"iPhone",
        "iPhone2,1":"iPhone 3GS",
        "iPhone3,1":"iPhone 4 (GSM)",
        "iPhone3,3":"iPhone 4 (CDMA)",
        "iPhone4,1":"iPhone 4S",
        "iPhone5,1":"iPhone 5 (A1428)",
        "iPhone5,2":"iPhone 5 (A1429)",
        "iPhone5,3":"iPhone 5c (A1456/A1532)",
        "iPhone5,4":"iPhone 5c (A1507/A1516/A1529)",
        "iPhone6,1":"iPhone 5s (A1433/A1453)",
        "iPhone6,2":"iPhone 5s (A1457/A1518/A1530)",
        "iPhone7,1":"iPhone 6 Plus",
        "iPhone7,2":"iPhone 6",
        "iPhone8,1":"iPhone 6s",
        "iPhone8,2":"iPhone 6s Plus",
        "iPhone8,4":"iPhone SE",
        "iPhone9,1":"iPhone 7 (A1660/A1779/A1780)",
        "iPhone9,2":"iPhone 7 Plus (A1661/A1785/A1786)",
        "iPhone9,3":"iPhone 7 (A1778)",
        "iPhone9,4":"iPhone 7 Plus (A1784)",
        "iPhone10,1":"iPhone 8 (CDMA+GSM/LTE)",
        "iPhone10,2":"iPhone 8 Plus (CDMA+GSM/LTE)",
        "iPhone10,3":"iPhone X (CDMA+GSM/LTE)",
        "iPhone10,4":"iPhone 8 (GSM/LTE)",
        "iPhone10,5":"iPhone 8 Plus (GSM/LTE)",
        "iPhone10,6":"iPhone X (GSM/LTE)",
        "iPhone11,2" : "iPhone XS",
        "iPhone11,4" : "iPhone XS Max",
        "iPhone11,6" : "iPhone XS Max Global",
        "iPhone11,8" : "iPhone XR",
        "iPhone12,1" : "iPhone 11",
        "iPhone12,3" : "iPhone 11 Pro",
        "iPhone12,5" : "iPhone 11 Pro Max",
        "iPhone12,8" : "iPhone SE 2nd Gen",
        "iPad1,1":"iPad",
        "iPad2,1":"iPad 2 (Wi-Fi)",
        "iPad2,2":"iPad 2 (GSM)",
        "iPad2,3":"iPad 2 (CDMA)",
        "iPad2,4":"iPad 2 (Wi-Fi, revised)",
        "iPad2,5":"iPad mini (Wi-Fi)",
        "iPad2,6":"iPad mini (A1454)",
        "iPad2,7":"iPad mini (A1455)",
        "iPad3,1":"iPad (3rd gen, Wi-Fi)",
        "iPad3,2":"iPad (3rd gen, Wi-Fi+LTE Verizon)",
        "iPad3,3":"iPad (3rd gen, Wi-Fi+LTE AT&T)",
        "iPad3,4":"iPad (4th gen, Wi-Fi)",
        "iPad3,5":"iPad (4th gen, A1459)",
        "iPad3,6":"iPad (4th gen, A1460)",
        "iPad4,1":"iPad Air (Wi-Fi)",
        "iPad4,2":"iPad Air (Wi-Fi+LTE)",
        "iPad4,3":"iPad Air (Rev)",
        "iPad4,4":"iPad mini 2 (Wi-Fi)",
        "iPad4,5":"iPad mini 2 (Wi-Fi+LTE)",
        "iPad4,6":"iPad mini 2 (Rev)",
        "iPad4,7":"iPad mini 3 (Wi-Fi)",
        "iPad4,8":"iPad mini 3 (A1600)",
        "iPad4,9":"iPad mini 3 (A1601)",
        "iPad5,1":"iPad mini 4 (Wi-Fi)",
        "iPad5,2":"iPad mini 4 (Wi-Fi+LTE)",
        "iPad5,3":"iPad Air 2 (Wi-Fi)",
        "iPad5,4":"iPad Air 2 (Wi-Fi+LTE)",
        "iPad6,3":"iPad Pro (9.7 inch) (Wi-Fi)",
        "iPad6,4":"iPad Pro (9.7 inch) (Wi-Fi+LTE)",
        "iPad6,7":"iPad Pro (12.9 inch, Wi-Fi)",
        "iPad6,8":"iPad Pro (12.9 inch, Wi-Fi+LTE)",
        "iPad6,11":"iPad 9.7-Inch 5th Gen (Wi-Fi Only)",
        "iPad6,12":"iPad 9.7-Inch 5th Gen (Wi-Fi/Cellular)",
        "iPad7,1":"iPad Pro 12.9-inch 2nd Gen (Wi-Fi Only)",
        "iPad7,2":"iPad Pro 12.9-inch 2nd Gen (Wi-Fi/Cellular)",
        "iPad7,3":"Apple iPad Pro 10.5-Inch (Wi-Fi Only)",
        "iPad7,4":"Apple iPad Pro 10.5-Inch (Wi-Fi/Cellular)",
        "iPad7,5" : "iPad 6th Gen (WiFi)",
        "iPad7,6" : "iPad 6th Gen (WiFi+Cellular)",
        "iPad7,11" : "iPad 7th Gen 10.2-inch (WiFi)",
        "iPad7,12" : "iPad 7th Gen 10.2-inch (WiFi+Cellular)",
        "iPad8,1" : "iPad Pro 11 inch (WiFi)",
        "iPad8,2" : "iPad Pro 11 inch (1TB, WiFi)",
        "iPad8,3" : "iPad Pro 11 inch (WiFi+Cellular)",
        "iPad8,4" : "iPad Pro 11 inch (1TB, WiFi+Cellular)",
        "iPad8,5" : "iPad Pro 12.9 inch 3rd Gen (WiFi)",
        "iPad8,6" : "iPad Pro 12.9 inch 3rd Gen (1TB, WiFi)",
        "iPad8,7" : "iPad Pro 12.9 inch 3rd Gen (WiFi+Cellular)",
        "iPad8,8" : "iPad Pro 12.9 inch 3rd Gen (1TB, WiFi+Cellular)",
        "iPad8,9" : "iPad Pro 11 inch 2nd Gen (WiFi)",
        "iPad8,10" : "iPad Pro 11 inch 2nd Gen (WiFi+Cellular)",
        "iPad8,11" : "iPad Pro 12.9 inch 4th Gen (WiFi)",
        "iPad8,12" : "iPad Pro 12.9 inch 4th Gen (WiFi+Cellular)",
        "iPad11,1" : "iPad mini 5th Gen (WiFi)",
        "iPad11,2" : "iPad mini 5th Gen",
        "iPad11,3" : "iPad Air 3rd Gen (WiFi)",
        "iPad11,4" : "iPad Air 3rd Gen",
        
        "iPod1,1":"iPod touch",
        "iPod2,1":"iPod touch (2nd gen)",
        "iPod3,1":"iPod touch (3rd gen)",
        "iPod4,1":"iPod touch (4th gen)",
        "iPod5,1":"iPod touch (5th gen)",
        "iPod7,1":"iPod touch (6th gen)"]
        
        if let name = dict[producttype]{
            return name
        }else{
            return ""
        }

    
    
    
    }
    
}
