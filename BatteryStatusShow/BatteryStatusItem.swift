//
//  BatteryStatusItem.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/6/3.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa

class BatteryStatusItem {
    
    
    var image : NSImage!
    private var changestatus :ChangeStatus!
    private var batterylevel :Int!
    
    public enum ChangeStatus {
        case nochange
        case change_fast
        case change_slow
        case dischange_fast
        case dischange_slow
        case dischange_verylight
        case nobattery
    }
    
    func updatelogo(chargestatus:ChangeStatus,batterylevel:Int)->Bool{
        
        if (self.changestatus != nil && self.batterylevel != nil){
            if (self.changestatus == chargestatus && self.batterylevel == batterylevel){
                if (image != nil){
                    return false
                }
            }
            
            
            
        }
        
        self.changestatus = chargestatus
        self.batterylevel = batterylevel
        
        let size = 36
        
      
       let bitmapdata  = calloc(size*4*size,MemoryLayout<uint8>.size)
        
    
        
        
        let context = CGContext(data: bitmapdata, width: size, height: size, bitsPerComponent: 8, bytesPerRow: size*4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        

  
        
       context?.setShouldAntialias(true)
        
        
        context?.setStrokeColor(CGColor.black)
        context?.setFillColor(CGColor.black)
     
        context?.beginPath()
        var x = 0;
        
        context?.addPath(CGPath(roundedRect: CGRect(x: x, y: 6, width: 2, height: 24), cornerWidth: 1, cornerHeight: 1, transform: nil))
        
        x += 4
        
        if (batterylevel>0){
        
        for _ in 1...batterylevel {
            context?.addPath(CGPath(roundedRect: CGRect(x: x, y: 6, width: 6, height: 24), cornerWidth: 2, cornerHeight: 2, transform: nil))
            x += 6
        }
        }
        
        context?.addPath(CGPath(roundedRect: CGRect(x: x, y: 14, width: 4, height: 8), cornerWidth: 1, cornerHeight: 1, transform: nil))
        
        
        context?.clip()
        
        
        
        var gradient_color : [CGFloat]
        switch chargestatus {
        case .nochange:
            gradient_color = [0.3,0.3,0.3,1.0,0.1,0.1,0.1,0.0]
        case .change_fast:
            gradient_color = [0.5,0.1,0.9,1.0,0.3,0.1,0.6,0.5]
        case .change_slow:
            gradient_color = [0.4,0.3,0.7,0.5,0.2,0.3,0.5,0.2]
        case .dischange_fast:
            if (batterylevel>=2){
            gradient_color = [0.1,0.9,0.1,1.0,0.1,0.75,0.1,0.7]
            }else if (batterylevel==1){
             gradient_color = [0.9,0.9,0.1,1.0,0.75,0.75,0.1,0.7]
            }else{
             gradient_color = [0.9,0.1,0.1,1.0,0.75,0,0.1,0.7]
            }
        case .dischange_slow:
             if (batterylevel>=2){
                gradient_color = [0.2,0.8,0.2,0.9,0.2,0.6,0.2,0.5]}
            else if (batterylevel==1){
                gradient_color = [0.8,0.8,0.2,0.9,0.6,0.6,0.2,0.5]
            }else{
                gradient_color = [0.9,0.1,0.1,1.0,0.75,0,0.1,0.7]
            }
        case .dischange_verylight:
            if (batterylevel>=2){
                gradient_color = [0.3,0.7,0.3,0.8,0.3,0.5,0.3,0.4]}
            else if (batterylevel==1){
                gradient_color = [0.7,0.7,0.3,0.8,0.5,0.5,0.3,0.4]
            }else{
                gradient_color = [0.9,0.1,0.1,1.0,0.75,0,0.1,0.7]
            }
        default:
            gradient_color = [0.9,0.9,0.9,1.0,0.5,0.5,0.5,0.0]
            
        }
        
        
        let gradient_location :[CGFloat] = [0.0,1.0]
        
      
        let gradient  = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: gradient_color, locations: gradient_location, count: gradient_location.count)
        
        
        context?.drawRadialGradient(gradient!, startCenter: CGPoint(x:CGFloat(16),y:CGFloat(16)), startRadius: 0, endCenter: CGPoint(x:CGFloat(16),y:CGFloat(16)), endRadius: 28, options: CGGradientDrawingOptions.drawsBeforeStartLocation)

        
      
        
    //    context?.fillPath()
        
    

        
 

        
        
        
        
       // CGImage(maskWidth: size, height: size, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: size/8, provider: CGDataProvider(dataInfo:nil,data:bitmapdata!,size:size*4*36*8,releaseData: CGDataProviderReleaseDataCallback()), decode: nil, shouldInterpolate: false)
        
      image =  NSImage(cgImage: context!.makeImage()!, size: NSSize(width: size/2, height: size/2))
    
       free (bitmapdata)
        
        
        
        return true
        
        
        
    }
    
}
