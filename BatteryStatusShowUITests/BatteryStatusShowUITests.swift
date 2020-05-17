//
//  BatteryStatusShowUITests.swift
//  BatteryStatusShowUITests
//
//  Created by slee on 2017/5/10.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import XCTest

class BatteryStatusShowUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUI() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let batteryStatusShowWindow = app.windows["Battery Status Show"]
        let toolbarsQuery = batteryStatusShowWindow.toolbars
        toolbarsQuery.buttons["IOS"].click()
        
        let peripheralButton = toolbarsQuery.buttons["Peripheral"]
        peripheralButton.click()
        toolbarsQuery.buttons["Log"].click()
        
        let startButton = batteryStatusShowWindow.buttons["Start"]
        startButton.click()
        batteryStatusShowWindow.buttons["Stop"].click()
        startButton.click()
        batteryStatusShowWindow.checkBoxes["Label"].doubleClick()
        peripheralButton.click()
        toolbarsQuery.buttons["Graph"].click()
        toolbarsQuery.buttons["macOS"].click()
        app.menuBars.menuBarItems["Window"].click()
        batteryStatusShowWindow.toolbars.containing(.button, identifier:"macOS").element.click()
        
        
        let query2 = app.radioButtons.matching(NSPredicate(format: "title LIKE '*🖱*'"))
        //(identifier: "💻").radioButtons.allElementsBoundByIndex
        
        
        
        if query2.count > 0 {
            query2.element(boundBy: 0).tap()
        }
       
        app.radioButtons["📈"].tap()
        app.radioButtons["📱"].tap()
       // app.radioButtons["🖱 41%"].tap()
        app.radioButtons["🖌"].tap()
        
        let query = app.radioButtons.containing(NSPredicate(format: "title LIKE %@","*💻*"))

     
        
        
        if query.count > 0 {
            query.element(boundBy: 0).tap()
        }
        

    //    app.radioButtons["💻"].tap()
        
   
        batteryStatusShowWindow.typeKey(XCUIKeyboardKey.escape, modifierFlags:[])
        batteryStatusShowWindow.buttons[XCUIIdentifierCloseWindow].click()
        
    }
    
}
