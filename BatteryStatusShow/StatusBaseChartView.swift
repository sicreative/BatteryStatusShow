//
//  StatusBaseBatteryView.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/31.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa

class StatusBaseChartView : BaseChartView {
    
    
    
   
    
   var statuslinecolortable:[Int:CGColor] = [0:CGColor(red:0.2,green:0.2,blue:0.2,alpha:0.9)
                                         ,1:CGColor(red:0.1,green:0.8,blue:0.1,alpha:0.9)
                                         ,2:CGColor(red:0.8,green:0.1,blue:0.1,alpha:0.9)]
    
  var statusbelowcolortable:[Int:CGColor] = [0:CGColor(red:0.1,green:0.1,blue:0.1,alpha:0.1)
                                        ,1:CGColor(red:0.2,green:0.8,blue:0.2,alpha:0.2)
                                        ,2:CGColor(red:0.8,green:0.2,blue:0.2,alpha:0.2)]
    
    var linechartstatus:[Int] = []
    
    var labeltext:[String:NSPoint] = [:]
    var showlabel:Bool = true
    private var labelTextFields:[NSTextField] = [NSTextField]()
    
    
    
    override func buildchat(_ context:CGContext,_ dirtyRect: NSRect){
        
        if (linechartstatus.count != linechart.count){
            return
        }
        
        
        context.clear(dirtyRect)
        
        context.setFillColor(chartfillcolor);
        context.setStrokeColor(chartaxiscolor);
        
        
        
        
        var linewidth:CGFloat = dirtyRect.height/200
        if (linewidth < 2){
            linewidth = 2
        }
        
        let xoffset : CGFloat = lineoffset.x / 100 * dirtyRect.width;
        let yoffset : CGFloat = lineoffset.y / 100 * dirtyRect.height;
        
        
        for i in 0...3 {
            
            rowlabel[i].stringValue = String(rowinit + i  * rowstep)
            rowlabel[i].sizeToFit()
           // columnlabel[i].stringValue = String(columninit + i  * columnstep)
          //  columnlabel[i].sizeToFit()
            
            let rowinterval  = NSPoint(x:xoffset/2 - rowlabel[i].fittingSize.width / 2 ,
                                       y:(dirtyRect.height-yoffset*2)/4 * CGFloat(i+1)+yoffset - rowlabel[i].fittingSize.height / 2 )
            let columninterval  = NSPoint(x:(dirtyRect.width-xoffset*2)/4 * CGFloat(i+1) + xoffset -
                columnlabel[i].fittingSize.width / 2,
                                          y:yoffset - xtitle.fittingSize.height)
            
            rowlabel[i].setFrameOrigin(rowinterval)
            
            
            
            columnlabel[i].setFrameOrigin(columninterval)
            
            
            
        }
        
        
        context.setLineWidth(linewidth)
        context.move(to:CGPoint(x: xoffset, y: linewidth/2 + yoffset ))
        context.addLine(to:CGPoint(x :dirtyRect.width-xoffset, y: linewidth/2 + yoffset ))
        
        context.move(to:CGPoint(x: linewidth/2 + xoffset, y: yoffset))
        context.addLine(to: CGPoint(x :linewidth/2 + xoffset, y: dirtyRect.height - linewidth/2 - yoffset))
        
        
        context.strokePath()
        
        title.setFrameOrigin(NSPoint(x:dirtyRect.width/2-title.fittingSize.width/2, y: dirtyRect.height - linewidth/2 - yoffset/2 - title.fittingSize.height/2 ))
        
        ytitle.setFrameOrigin(NSPoint(x:xoffset/10, y: dirtyRect.height-yoffset * 0.75 ))
        
        xtitle.setFrameOrigin(NSPoint(x:dirtyRect.width - xoffset/8 - xtitle.fittingSize.width, y:  yoffset - xtitle.fittingSize.height))
        
        
        
        if (linechart.count > 0){
            
            if (  linechart.count==1){
                linechart.append(CGPoint(x:1.0,y: linechart[linechart.count-1].y))
                
            }
            
            var processedlinecount = 0
            repeat{
                
                let first =  processedlinecount == 0 ? 0 : processedlinecount-1
                
              
                
                while(processedlinecount<linechart.count-1 && linechartstatus[processedlinecount] == linechartstatus[processedlinecount+1]){
                    processedlinecount+=1
                }
                
            
                let linegroup = Array(linechart[first..<processedlinecount+1])
                let lines = lineChartToPoints(dirtyRect, linewidth, linegroup)
            
            
            
            if (showbelowcolor){
                context.setStrokeColor(CGColor.clear)
                context.setFillColor(statusbelowcolortable[linechartstatus[processedlinecount]]!)
                context.addLines(between: lines)
                context.addLine(to: CGPoint(x:context.currentPointOfPath.x ,y:yoffset+linewidth))
                context.addLine(to: CGPoint(x:lines[0].x,y:context.currentPointOfPath.y))
                context.closePath()
                context.fillPath()
                
            }
            context.setStrokeColor(statuslinecolortable[linechartstatus[processedlinecount]]!)
            
            //context.setLineWidth(2)
            
            
            
            if (showline){
                
                context.addLines(between: lines)
                
                
                context.strokePath()
                }
                processedlinecount+=1
            }while(processedlinecount<linechart.count)
            
            
            
            
            if ( maxminlabelinit()){
                 let lines = lineChartToPoints(dirtyRect, linewidth, linechart)
                
                
                context.setLineWidth(2)
                context.setLineDash(phase: 0, lengths: [2,3])
                var max = lines.max(by: { a,b in
                    a.y < b.y
                })
                
                var min = lines.min (by: { a,b in
                    a.y < b.y
                })
                
                maxnum.textColor = NSColor(cgColor:maxdashlinecolor)
                
                
                if (custommax == nil){
                    let maxrelative = linechart.max(by: { a,b in
                        a.y < b.y
                    })
                    
                    maxnum.stringValue = numtolabelstring(maxrelative!.y * CGFloat( 4  * rowstep ) + CGFloat(rowinit - rowstep))
                }else{
                    maxnum.stringValue = numtolabelstring(custommax)
                    max?.y = (chartpointTopoint(dirtyRect, linewidth, CGPoint(x:0, y:custommax /
                        (CGFloat( 4  * rowstep ) )))).y
                }
                
                
                minnum.textColor = NSColor(cgColor:mindashlinecolor)
                
                if (custommin == nil){
                    
                    let minrelative = linechart.min (by: { a,b in
                        a.y < b.y
                    })
                    
                    minnum.stringValue = numtolabelstring(minrelative!.y * CGFloat( 4  * rowstep ) + CGFloat(rowinit - rowstep))
                    
                    
                    
                }else{
                    minnum.stringValue = numtolabelstring(custommin)
                

                    min?.y = (chartpointTopoint(dirtyRect, linewidth, CGPoint(x:0, y:custommin /
                        (CGFloat( 4  * rowstep ) )))).y
                        
                    

                    
                }
                
                minnum.sizeToFit()
                maxnum.sizeToFit()
                
                minnum.setFrameOrigin(CGPoint(x:xoffset+linewidth,y:min!.y-minnum.fittingSize.height*0.8))
                
                maxnum.setFrameOrigin(CGPoint(x:xoffset+linewidth,y:max!.y))
                
                context.setStrokeColor(maxdashlinecolor)
                context.move (to: CGPoint(x:xoffset+linewidth,y:max!.y))
                
                
                context.addLine(to: CGPoint(x:dirtyRect.width-xoffset-linewidth, y:max!.y))
                context.strokePath()
                
                
                
                
                
                
                
                context.setStrokeColor(mindashlinecolor)
                context.move (to: CGPoint(x:xoffset+linewidth,y:min!.y))
                
                context.addLine(to: CGPoint(x:dirtyRect.width-xoffset-linewidth, y:min!.y))
                context.strokePath()
                
                
                
                
                
                
                
                
                
                
            }
            
          
            
            clearLabelText()
            if (showlabel){
                
                
                /*
                if (labeltext.count > labelTextFields.count){
                    for _ in 1...labeltext.count-labelTextFields.count{
                        let label = NSTextField(string: "")
                        label.backgroundColor = NSColor.controlColor
                        label.textColor = NSColor.labelColor
                        label.isBordered = false
                        label.isEditable = false
                        label.isBezeled = false
                        label.alignment = NSTextAlignment.right
                        label.font = NSFont(name:"Gill Sans Light", size:8)
                    
                         label.frameRotation = CGFloat(90)
                        self.addSubview(label)

                        labelTextFields.append(label)
                    }
                }else if ( labelTextFields.count < labeltext.count){
               
                    for i in labeltext.count-1...labelTextFields.count-1{
                        labelTextFields[i].removeFromSuperview()
                    }
                    labelTextFields.removeLast( labeltext.count - labelTextFields.count )

                }*/
                
           
                
                for (string,pos) in labeltext{
                                      // label.rotate(byDegrees: -90)
                  //     label.rotate(byDegrees: 90)
                    
                    let label = NSTextField(string: string)
                    label.backgroundColor = NSColor.controlColor
                    label.textColor = NSColor.labelColor
                    label.isBordered = false
                    label.isEditable = false
                    label.isBezeled = false
                    label.alignment = NSTextAlignment.right
                    label.font = NSFont(name:"Gill Sans Light", size:8)
                    
                    label.frameRotation = CGFloat(90)
                  
                    
                    labelTextFields.append(label)
           
                    let point = chartpointTopoint(dirtyRect,linewidth,pos);
                      label.sizeToFit()
                   // label.frame = CGRect(x:point.x,y:point.y-label.fittingSize.height,width:300,height:300)
                    label.setFrameOrigin(CGPoint(x:point.x,y:yoffset+label.fittingSize.width/2))
                    
                      self.addSubview(label)
                  
                   
                  
                   
                    //label.setFrameSize(NSSize(width:300,height:300))
       
                    
                }
            }
            
            
            
            
            
            
            
            
            
            
        }else{
            clearLabelText()
        }
        
        
        
        
        //  title.draw(NSRect(x:dirtyRect.width/2, y: dirtyRect.height - linewidth/2 - lineoffset.y, width:title.fittingSize.width, height:title.fittingSize.height))
        
        
        
        
        
    }
    
    private func clearLabelText(){
        for item in labelTextFields {
            item.removeFromSuperview()
        }
        labelTextFields.removeAll()
    }

}
