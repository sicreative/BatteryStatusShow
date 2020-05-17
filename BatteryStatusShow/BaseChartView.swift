//
//  BaseChatView.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/16.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//


import Cocoa



class BaseChartView:NSView{
    
    var chartlinecolor:CGColor!
    var maxdashlinecolor:CGColor!
    var mindashlinecolor:CGColor!
    var chartaxiscolor:CGColor!
     var chartfillcolor:CGColor!
     var reglinecolor:CGColor!
    
    var lineoffset:CGPoint!
    
    var title:NSTextField!
    var xtitle:NSTextField!
    var ytitle:NSTextField!
    var rowlabel:[NSTextField]!
    var columnlabel:[NSTextField]!
  
    var minnum:NSTextField!
    var maxnum:NSTextField!
    
    
    var rowstep:Int!
    var columnstep:Int!
    var rowinit:Int!
    var columninit:Int!
    var linechart:[CGPoint]!


    var showbelowcolor:Bool!
    var showmaxmin:Bool!
    var maxmindecimal:Int!
    var custommax:CGFloat!
    var custommin:CGFloat!
    var showline:Bool!
    var offsetx:CGFloat = 0
    var offsety:CGFloat = 0
    
    var reglineBegin:CGPoint = CGPoint (x:0,y:0);
    var reglineEnd:CGPoint = CGPoint (x:0,y:0);
    
    
    

    

    override func viewWillDraw() {
        super.viewWillDraw()
       
    }
    
    public override init(frame frameRect: NSRect){
        super.init(frame: frameRect)
        setdefault()
    }
    
    public required init?(coder: NSCoder){
        super.init(coder: coder)
        setdefault()
    }
    
    func maxminlabelinit()->Bool{
        if (showmaxmin){
            
      
            if (minnum == nil || maxnum == nil){
                minnum = NSTextField(string: "test")
                maxnum = NSTextField(string: "test")
                minnum.backgroundColor = NSColor.clear
                minnum.textColor = NSColor.labelColor
                minnum.isBordered = false
                minnum.isEditable = false
                minnum.isBezeled = false
                minnum.alignment = NSTextAlignment.center
                minnum.font = NSFont(name:"Helvetica Neue Medium", size:8)
                
                maxnum.backgroundColor = NSColor.clear
                maxnum.textColor = NSColor.labelColor
                maxnum.isBordered = false
                maxnum.isEditable = false
                maxnum.isBezeled = false
                maxnum.alignment = NSTextAlignment.center
                maxnum.font = NSFont(name:"Helvetica Neue Medium", size:8)
                
                self.addSubview(minnum)
                self.addSubview(maxnum)
            }
            
            return true
          
        }
        if (minnum != nil){
                minnum.removeFromSuperview()
                minnum = nil
        }
        
        if (maxnum != nil){
            maxnum.removeFromSuperview()
            maxnum = nil
        }
        
        
          return false
    }

    func setdefault(){
         chartlinecolor = CGColor(red:0.1,green:0.1,blue:0.8,alpha:0.95)
        chartaxiscolor = CGColor(red:0.8,green:0.5,blue:0.6,alpha:0.8)
        chartfillcolor = CGColor(red:0.3,green:0.8,blue:0.3,alpha:0.2)
        maxdashlinecolor = CGColor(red:0.8,green:0.2,blue:0.2,alpha:0.5)
        mindashlinecolor = CGColor(red:0,green:0.2,blue:0.5,alpha:0.5)
        reglinecolor = CGColor(red:0.2,green:0.2,blue:0.2,alpha:0.5)

        lineoffset = CGPoint(x: 10, y: 10)
        
        title  = NSTextField(string: "Title")
        ytitle = NSTextField(string: "y")
        xtitle = NSTextField(string: "x")
    
        
        
        title.backgroundColor = NSColor.clear
        title.textColor = NSColor.labelColor
        title.isBordered = false
        title.isEditable = false
        title.isBezeled = false
        title.font = NSFont(name:"Cochin Regular", size:10)
        title.alignment = NSTextAlignment.center
        
        xtitle.backgroundColor = NSColor.clear
        xtitle.textColor = NSColor.labelColor
        xtitle.isBordered = false
        xtitle.isEditable = false
        xtitle.isBezeled = false
        xtitle.font = NSFont(name:"Helvetica Neue Medium", size:10)
        xtitle.alignment = NSTextAlignment.center
        
        ytitle.backgroundColor = NSColor.clear
        ytitle.textColor = NSColor.labelColor
        ytitle.isBordered = false
        ytitle.isEditable = false
        ytitle.isBezeled = false
        ytitle.alignment = NSTextAlignment.center
        ytitle.font = NSFont(name:"Helvetica Neue Medium", size:10)
        
    
        
     
        
        self.addSubview(title)
        self.addSubview(xtitle)
        self.addSubview(ytitle)
        
        rowlabel = [NSTextField]()
        columnlabel = [NSTextField]()
        for i in 0...3 {
            let column  = NSTextField(string: String(i))
            column.backgroundColor = NSColor.clear
            column.textColor = NSColor.labelColor
            column.isBordered = false
            column.isEditable = false
            column.isBezeled = false
            
            self.addSubview(column)
            columnlabel.append(column)
            let row  = NSTextField(string: String(i))
            row.backgroundColor = NSColor.clear
            row.textColor = NSColor.labelColor
            row.isBordered = false
            row.isEditable = false
            row.isBezeled = false
           row.autoresizesSubviews = true
            row.autoresizingMask = NSView.AutoresizingMask.width
            
            self.addSubview(row)
            
            rowlabel.append(row)
            
            rowstep = 0
            columnstep = 0
            rowinit = 0
            columninit = 0
            
            maxmindecimal = 0
        
            
            
            
        }
        
        
        linechart = [CGPoint]()
        
        showmaxmin = false
        showbelowcolor = false
        showline = true
        
     
 
        
        
 

    }
   
    
    override func draw(_ dirtyRect: NSRect) {
           super.draw(dirtyRect)
        let context =  NSGraphicsContext.current?.cgContext
        buildchat(context!,dirtyRect)

        
        
    }
    
    
    
    func lineChartToPoints(_ dirtyRect:NSRect,_ linewidth:CGFloat,_ chart:[CGPoint])->[CGPoint]{
        
        var points = [CGPoint]()
        for point in chart {
            
            
            
            
            points.append(chartpointTopoint(dirtyRect,linewidth,point))
        }
        
        return points
    }
    
    func chartpointTopoint(_ dirtyRect:NSRect,_ linewidth:CGFloat,_ point:CGPoint)->CGPoint{
        
        
        
        let xoffset =  lineoffset.x / 100 * dirtyRect.width ;
        let yoffset = lineoffset.y / 100 * dirtyRect.height ;
        
        
        let xleft = linewidth + xoffset
        let xtotal = dirtyRect.width - xoffset * 2 - linewidth
        
        let ybelow = linewidth + yoffset
        let ytotal = dirtyRect.height - yoffset * 2 - linewidth
        
        return CGPoint(x:xleft + point.x * xtotal + offsetx,y:ybelow + point.y * ytotal + offsety)
    }
    
    
    
    func numtolabelstring(_ num:CGFloat)->String{
        
        
        // return Double(num).roundTo(places:maxmindecimal).description
        
        return String(format:String(format:"%%.%df",maxmindecimal),Float(num))
        
    }
    
    func buildchat(_ context:CGContext,_ dirtyRect: NSRect){
        
        
        context.clear(dirtyRect)
        
        context.setFillColor(chartfillcolor);
        context.setStrokeColor(chartaxiscolor);
        
        
    

        var linewidth:CGFloat = dirtyRect.height/150
        if (linewidth < 3){
        linewidth = 3
        }
        
        
        
        
        let xoffset : CGFloat = lineoffset.x / 100 * dirtyRect.width ;
        let yoffset : CGFloat = lineoffset.y / 100 * dirtyRect.height ;
        
   
        
    
        
        title.setFrameOrigin(NSPoint(x:dirtyRect.width/2-title.fittingSize.width/2 + offsetx, y: dirtyRect.height - linewidth/2 - title.fittingSize.height + offsety))
        
        ytitle.setFrameOrigin(NSPoint(x:xoffset/10+offsetx, y: dirtyRect.height-yoffset * 0.75 + offsety))
        
        xtitle.setFrameOrigin(NSPoint(x:dirtyRect.width - xoffset/8 - xtitle.fittingSize.width + offsetx, y:  yoffset - xtitle.fittingSize.height + offsety))
        
    
        
        for i in 0...3 {
            
            let rownum = rowinit + i  * rowstep ;
            rowlabel[i].stringValue = String(rownum)
           
            
            rowlabel[i].sizeToFit()
          
            columnlabel[i].stringValue = String(columninit + i  * columnstep)
            columnlabel[i].sizeToFit()
            
            
            let rowinterval  = NSPoint(x:xoffset/2 - ytitle.fittingSize.width / 2 + offsetx,
                                       y:(dirtyRect.height-yoffset*2)/4 * CGFloat(i+1)+yoffset - rowlabel[i].fittingSize.height / 2 + offsety)
            
                rowlabel[i].setFrameOrigin(rowinterval)
            
            
            let columninterval  = NSPoint(x:(dirtyRect.width-xoffset*2)/4 * CGFloat(i+1) + xoffset -
                columnlabel[i].fittingSize.width  + offsetx,
                                          y:yoffset - xtitle.fittingSize.height + offsety)
            
            
            columnlabel[i].setFrameOrigin(columninterval)
           
           
            
         
        
            
            
        }
        
        context.setLineWidth(linewidth)
        context.move(to:CGPoint(x: xoffset+offsetx, y: linewidth/2 + yoffset+offsety ))
        context.addLine(to:CGPoint(x :dirtyRect.width-xoffset+offsetx, y: linewidth/2 + yoffset + offsety ))
        
        context.move(to:CGPoint(x: linewidth/2 + xoffset+offsetx, y: yoffset+offsety))
        context.addLine(to: CGPoint(x :linewidth/2 + xoffset+offsetx, y: dirtyRect.height - linewidth/2 - yoffset+offsety))
        
        
        context.strokePath()
        
       
        
   
        
  
        
        if (linechart.count > 0){
            
            if (  linechart.count==1){
                linechart.append(CGPoint(x:1.0,y: linechart[linechart.count-1].y))
            }
            
            let lines = lineChartToPoints(dirtyRect, linewidth, linechart)
            
       
    
            if (showbelowcolor){
            context.setStrokeColor(CGColor.clear)
            context.setFillColor(chartfillcolor)
            context.addLines(between: lines)
            context.addLine(to: CGPoint(x:context.currentPointOfPath.x+offsetx ,y:yoffset+linewidth+offsety))
            context.addLine(to: CGPoint(x:lines[0].x+offsetx,y:context.currentPointOfPath.y))
            context.closePath()
            context.fillPath()
            
            }
            context.setStrokeColor(chartlinecolor)
            
            //context.setLineWidth(2)
            
            
            
            if (showline){
            
            context.addLines(between: lines)
            
            
            context.strokePath()
            }
            
           
            
            
            if ( maxminlabelinit()){
                
                
                
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
                
                
                minnum.sizeToFit();
                maxnum.sizeToFit();
                
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
                
             
            
            if reglineBegin != CGPoint (x:0,y:0){
               
                
                context.move (to:chartpointTopoint(dirtyRect,linewidth,reglineBegin))
                context.setStrokeColor(reglinecolor)
                context.setLineDash(phase: 0.5, lengths: [5,2,1,2])
                context.addLine(to: chartpointTopoint(dirtyRect,linewidth,reglineEnd))
                context.strokePath()
                
            }
            
            
         
            
            
            
            
            
        
            
        }

        
       
        
      //  title.draw(NSRect(x:dirtyRect.width/2, y: dirtyRect.height - linewidth/2 - lineoffset.y, width:title.fittingSize.width, height:title.fittingSize.height))
        
        
        
        
        
    }

    
    

    
    
    
    

}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


