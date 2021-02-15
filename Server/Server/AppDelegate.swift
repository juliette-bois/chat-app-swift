//
//  AppDelegate.swift
//  Server
//
//  Created by Juliette Bois on 04.02.21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var server = Server()
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        server.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        server.stop()
    }


}

