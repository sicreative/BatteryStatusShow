//
//  TwoEdgeBaseChartView.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/21.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa


class TwoAxisBaseChartView:BaseChartView{
    

    var rightaxiscolor:CGColor!
    
    var rightrowlabel:[NSTextField]!
    var righttitle:NSTextField!
 


    var rightminnum:NSTextField!
    var rightmaxnum:NSTextField!
    
    
    var rightrowstep:Int!
   
    var rightrowinit:Int!

    var rightlinechart:[CGPoint]!
    
      var rightlinechartcolor:CGColor!
    var rightmaxdashlinecolor:CGColor!
    var rightmindashlinecolor:CGColor!
    
    

    var rightmaxmindecimal:Int!
    var customrightmax:CGFloat!
    var customrightmin:CGFloat!
    
    
    

    

    
   func rightmaxminlabelinit()->Bool{
    
    
        if (showmaxmin){
            
            
            if (rightminnum == nil || rightmaxnum == nil){
                rightminnum = NSTextField(string: "test")
                rightmaxnum = NSTextField(string: "test")
                rightminnum.backgroundColor = NSColor.controlColor
                rightminnum.textColor = NSColor.labelColor
                rightminnum.isBordered = false
                rightminnum.isEditable = false
                rightminnum.isBezeled = false
                rightminnum.alignment = NSTextAlignment.center
                rightminnum.font = NSFont(name:"Helvetica Neue Medium", size:8)
                
                rightmaxnum.backgroundColor = NSColor.controlColor
                rightmaxnum.textColor = NSColor.labelColor
                rightmaxnum.isBordered = false
                rightmaxnum.isEditable = false
                rightmaxnum.isBezeled = false
                rightmaxnum.alignment = NSTextAlignment.center
                rightmaxnum.font = NSFont(name:"Helvetica Neue Medium", size:8)
                
                self.addSubview(rightminnum)
                self.addSubview(rightmaxnum)
            }
            
            return true
            
        }
        if (rightminnum != nil){
            rightminnum.removeFromSuperview()
            rightminnum = nil
        }
        
        if (rightmaxnum != nil){
            rightmaxnum.removeFromSuperview()
            rightmaxnum = nil
        }
        
        
        return false
    }
    
    override func setdefault(){
        
        super.setdefault()
  
        rightaxiscolor = CGColor(red:0.8,green:0.8,blue:0.1,alpha:0.8)
    
        rightlinechartcolor = CGColor(red:0.8,green:0.8,blue:0.1,alpha:0.8)
        
        rightmaxdashlinecolor = CGColor(red:0.1,green:0.8,blue:0.1,alpha:0.8)
        rightmindashlinecolor = CGColor(red:0.8,green:0.1,blue:0.1,alpha:0.8)
 


        righttitle = NSTextField(string:"righttitle")
        

        righttitle.backgroundColor = NSColor.controlColor
        righttitle.textColor = NSColor.labelColor
        righttitle.isBordered = false
        righttitle.isEditable = false
        righttitle.isBezeled = false
        righttitle.alignment = NSTextAlignment.center
        righttitle.font = NSFont(name:"Helvetica Neue Medium", size:10)
        self.addSubview(righttitle)
        
        
        
        

        
        rightrowlabel = [NSTextField]()
       
        for i in 0...3 {
         
            let row  = NSTextField(string: String(i))
            row.backgroundColor = NSColor.controlColor
            row.textColor = NSColor.labelColor
            row.isBordered = false
            row.isEditable = false
            row.isBezeled = false
            row.autoresizesSubviews = true
            row.autoresizingMask = NSView.AutoresizingMask.width
            
            self.addSubview(row)
            
            rightrowlabel.append(row)
            
            rightrowstep = 0
        
            rightrowinit = 0
       
            
            rightmaxmindecimal = 0
            
            
            
        }
        
        
        rightlinechart = [CGPoint]()

        
        
        
        
        
    }
    
    

    
    override func buildchat(_ context:CGContext,_ dirtyRect: NSRect){
        
        super.buildchat(context, dirtyRect)
        
        
        
        context.setStrokeColor(rightaxiscolor);
        // Reset to solid line
        context.setLineDash(phase: 0, lengths: [])
        
        
        var linewidth:CGFloat = dirtyRect.width/100
        if (linewidth < 3){
            linewidth = 3
        }
        
        let xoffset : CGFloat = lineoffset.x / 100 * dirtyRect.width;
        let yoffset : CGFloat = lineoffset.y / 100 * dirtyRect.height;
        
        
        for i in 0...3 {
            
            rightrowlabel[i].stringValue = String(rightrowinit + i  * rightrowstep)
            rightrowlabel[i].sizeToFit()
     
            
            let rightrowinterval  = NSPoint(x: dirtyRect.width - xoffset + rightrowlabel[i].fittingSize.width/2,
                                       y:(dirtyRect.height-yoffset*2)/4 * CGFloat(i+1)+yoffset - rightrowlabel[i].fittingSize.height / 2 )
         
            
            rightrowlabel[i].setFrameOrigin(rightrowinterval)
            
            
        
            
            
            
        }
        
        
        context.setLineWidth(linewidth)
      
        
        context.move(to:CGPoint(x:dirtyRect.width - linewidth/2 - xoffset, y: yoffset))
        context.addLine(to: CGPoint(x :dirtyRect.width - linewidth/2 - xoffset, y: dirtyRect.height - linewidth/2 - yoffset))
        
        
        context.strokePath()
        
    
        
        righttitle.setFrameOrigin(NSPoint(x:dirtyRect.width - xoffset/8 - righttitle.fittingSize.width, y: dirtyRect.height-yoffset * 0.75 ))
        
        
        
        if (rightlinechart.count > 0){
            
            if (  rightlinechart.count==1){
                rightlinechart.append(CGPoint(x:1.0,y: rightlinechart[rightlinechart.count-1].y))
            }
            
            let lines = lineChartToPoints(dirtyRect, linewidth, rightlinechart)
            
            
            
            if (showbelowcolor){
                context.setStrokeColor(CGColor.clear)
                context.setFillColor(chartfillcolor)
                context.addLines(between: lines)
                context.addLine(to: CGPoint(x:context.currentPointOfPath.x ,y:yoffset+linewidth))
                context.addLine(to: CGPoint(x:lines[0].x,y:context.currentPointOfPath.y))
                context.closePath()
                context.fillPath()
                
            }
        
            context.setStrokeColor(rightlinechartcolor)
            
            //context.setLineWidth(2)
            
            
            
            
            
            context.addLines(between: lines)
            
            
            context.strokePath()
            
            
            
            
            if ( rightmaxminlabelinit()){
                
                
                
                context.setLineWidth(2)
                context.setLineDash(phase: 0, lengths: [2,3])
                let max = lines.max(by: { a,b in
                    a.y < b.y
                })
                
                let min = lines.min (by: { a,b in
                    a.y < b.y
                })
                
                rightmaxnum.textColor = NSColor(cgColor:rightmaxdashlinecolor)
                
                
                if (customrightmax == nil){
                    let maxrelative = rightlinechart.max(by: { a,b in
                        a.y < b.y
                    })
                    
                    rightmaxnum.stringValue = numtolabelstring(maxrelative!.y * CGFloat( 4  * rightrowstep ) + CGFloat(rightrowinit - rightrowstep))
                }else{
                    rightmaxnum.stringValue = numtolabelstring(customrightmax)
                }
                
                
                rightminnum.textColor = NSColor(cgColor:rightmindashlinecolor)
                
                if (customrightmin == nil){
                    
                    let minrelative = rightlinechart.min (by: { a,b in
                        a.y < b.y
                    })
                    
                    rightminnum.stringValue = numtolabelstring(minrelative!.y * CGFloat( 4  * rightrowstep ) + CGFloat(rightrowinit - rightrowstep))
                    
                }else{
                    rightminnum.stringValue = numtolabelstring(customrightmin)
                    
                }
                
                rightminnum.sizeToFit()
                rightmaxnum.sizeToFit()
                
                rightminnum.setFrameOrigin(CGPoint(x:dirtyRect.width - xoffset - linewidth - rightminnum.fittingSize.width,y:min!.y-minnum.fittingSize.height*0.8))
                
                rightmaxnum.setFrameOrigin(CGPoint(x:dirtyRect.width - xoffset - linewidth - rightmaxnum.fittingSize.width, y:max!.y))
                
                context.setStrokeColor(rightmaxdashlinecolor)
                context.move (to: CGPoint(x:xoffset+linewidth,y:max!.y))
                
                
                context.addLine(to: CGPoint(x:dirtyRect.width-xoffset-linewidth, y:max!.y))
                context.strokePath()
                
                
                
                
                
                
                
                context.setStrokeColor(rightmindashlinecolor)
                context.move (to: CGPoint(x:xoffset+linewidth,y:min!.y))
                
                context.addLine(to: CGPoint(x:dirtyRect.width-xoffset-linewidth, y:min!.y))
                context.strokePath()
                
                
                
                
                
                
                
                
                
                
            }
            
            
            
            
            
            
            
            
            
            
        }
        
        
        
        
        //  title.draw(NSRect(x:dirtyRect.width/2, y: dirtyRect.height - linewidth/2 - lineoffset.y, width:title.fittingSize.width, height:title.fittingSize.height))
        
        
        
        
        
    }

    
    

    
    
    
    
    
    
    
}
