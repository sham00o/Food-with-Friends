//
//  Food_with_FriendsTests.swift
//  Food with FriendsTests
//
//  Created by Samuel Liu on 2/5/15.
//  Copyright (c) 2015 Samuel Liu. All rights reserved.
//

import UIKit
import XCTest

class Food_with_FriendsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func inviteTest() {
        let invite = Invite()
        
        invite.event_id = "1234"
        invite.inviter_id = "1111"
        
        // assert that the invites can be altered
        XCTAssertEqual(invite.event_id, "1234", "event id not set")
        XCTAssertEqual(invite.inviter_id, "1111", "creator id not set")
    }
    
    func inviteViewTest() {
        let view = InviteController()
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(view.view, "View Did Not load")        
    }
    
    func eventTest() {
        let event = Event()
        
        event.id = "1234"
        event.creator_id = "1111"
        event.creator_name = "Sam"
        event.location = "chipotle"
        
        // assert that the ViewController.view is not nil
        XCTAssertEqual(event.id, "1234", "event id not set")
        XCTAssertEqual(event.creator_id, "1111", "creator id not set")
        XCTAssertEqual(event.creator_name, "sam", "event name not set")
        XCTAssertEqual(event.location, "chipotle", "event location not set")
        
    }
    
    
    func eventViewTest() {
        let view = EventController()
        
        view.downloadEvents()
        view.downloadInvites()
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(view.view, "View Did Not load")
        XCTAssertNotNil(view.events, "Events did not download")
        
    }
    
    func eventCreateTest() {
        let view = EventCreateController()
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(view.view, "View Did Not load")
        
    }
    
    func eventDetailTest() {
        let view = EventDetailController()
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(view.view, "View Did Not load")
        
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
