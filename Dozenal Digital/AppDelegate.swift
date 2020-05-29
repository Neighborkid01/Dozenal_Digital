//
//  AppDelegate.swift
//  Dozenal Digital
//
//  Created by admin on 1/30/20.
//  Copyright © 2020 Caleb Roland. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Global vars
    var statusItem: NSStatusItem?
    var timer: Timer?
    var button: NSButton?
    
    // Settings vars
    var radix = 12
    var showSeonds = true
    let defaults = UserDefaults.standard
    
    // User defaults keys
    let SHOW_SECONDS_KEY = "showSecondsKey"
    let RADIX_KEY = "radixKey"
    
    // Vars for timer func
    var date = Date()
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    
    var day = 0
    var month = 0
    var year = 0
    var hour = 0
    var minute = 0
    var second = 0
    
    var dayDoz = ""
    var monthDoz = ""
    var yearDoz = ""
    var hourDoz = ""
    var minuteDoz = ""
    var secondDoz = ""
    var dateString = ""
    var zerosString = ""
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Getting refference to the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: -1)
        guard let bttn = statusItem?.button else {
            print("status bar item failed. Try removing some menu bar item.")
            NSApp.terminate(nil)
            return
        }
        button = bttn
        
        radix = defaults.integer(forKey: RADIX_KEY) // returns 0 on failure
        showSeonds = defaults.bool(forKey: SHOW_SECONDS_KEY)
        if radix != 0 {
            radix = defaults.integer(forKey: RADIX_KEY)
        } else {
            radix = 2
            defaults.set(radix, forKey: RADIX_KEY)
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(redisplayClock), userInfo: nil, repeats: true)
        
        constructMenu()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Ending the timer
        timer?.invalidate()
    }
    
    // Timer Function
    @objc func redisplayClock() {
        dateFormatter.dateFormat = "E"
        date = Date()
        let maxLengthTimeString = String(60, radix: radix, uppercase: true)
        
        // Initializing date/time components
        day = calendar.component(.day, from: date)
        month = calendar.component(.month, from: date)
        year = calendar.component(.year, from: date)
        hour = calendar.component(.hour, from: date)
        minute = calendar.component(.minute, from: date)
        // Seconds calculated in leading 0's section (if showSeconds)
        
        // Converting to dozenal strings
        dayDoz = String(day, radix: self.radix, uppercase: true)
        monthDoz = String(month, radix: self.radix, uppercase: true)
        yearDoz = String(year, radix: self.radix, uppercase: true)
        hourDoz = String(hour, radix: self.radix, uppercase: true)
        minuteDoz = String(minute, radix: self.radix, uppercase: true)
        // Seconds calculated in leading 0's section (if showSeconds)
        
        // Adding leading 0's
        if (hourDoz.count < maxLengthTimeString.count) {
            zerosString = ""
            for _ in 0 ..< (maxLengthTimeString.count - hourDoz.count) {
                zerosString += "0"
            }
            hourDoz = "\(zerosString)\(hourDoz)"
        }
        if (minuteDoz.count < maxLengthTimeString.count) {
            zerosString = ""
            for _ in 0 ..< (maxLengthTimeString.count - minuteDoz.count) {
                zerosString += "0"
            }
            minuteDoz = "\(zerosString)\(minuteDoz)"
        }
        
        if self.showSeonds {
            // Finding seconds
            second = calendar.component(.second, from: date)
            secondDoz = String(second, radix: self.radix, uppercase: true)
            
            // Adding leading 0's
            if (secondDoz.count < maxLengthTimeString.count) {
                zerosString = ""
                for _ in 0 ..< (maxLengthTimeString.count - secondDoz.count) {
                    zerosString += "0"
                }
            } else {
                zerosString = ""
            }
            secondDoz = ":\(zerosString)\(secondDoz)"
        }
        
        // Creating date string and setting button title
        dateString = "\(dateFormatter.string(from: date)) \(monthDoz)/\(dayDoz)/\(yearDoz) \(hourDoz):\(minuteDoz)\(secondDoz)"
        button!.title = dateString
    }
    
    // Menu item funcitons
    @objc func toggleSeconds(_ sender: Any?) {
        showSeonds = !showSeonds
        defaults.set(showSeonds, forKey: SHOW_SECONDS_KEY)
        secondDoz = ""
        constructMenu()
        redisplayClock()
    }
    @objc func increaseRadix(_ sender: Any?) {
        radix += 1
        defaults.set(radix, forKey: RADIX_KEY)
        constructMenu()
        redisplayClock()
    }
    @objc func decreaseRadix(_ sender: Any?) {
        radix -= 1
        defaults.set(radix, forKey: RADIX_KEY)
        constructMenu()
        redisplayClock()
    }
    
    @objc func setRadix(sender:RadixMenuItem) {
        radix = sender.radix!
        defaults.set(radix, forKey: RADIX_KEY)
        constructMenu()
        redisplayClock()
    }
    
    func constructMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        let subMenu = NSMenu()
        var menuItem: NSMenuItem
        var subMenuItem: RadixMenuItem

        
        if (showSeonds) {
            menu.addItem(NSMenuItem(title: "Hide seconds", action: #selector(toggleSeconds(_:)), keyEquivalent: ""))
        } else {
            menu.addItem(NSMenuItem(title: "Show seconds", action: #selector(toggleSeconds(_:)), keyEquivalent: ""))
        }
        menu.addItem(NSMenuItem.separator())
        
        menuItem = NSMenuItem(title: "Current Base: \(radix)", action: nil, keyEquivalent: "")
        menuItem.isEnabled = false
        menu.addItem(menuItem)
        if (radix < 36) {
            menu.addItem(NSMenuItem(title: "Increase base", action: #selector(increaseRadix(_:)), keyEquivalent: ""))
        }
        if (radix > 2) {
            menu.addItem(NSMenuItem(title: "Decrease base", action: #selector(decreaseRadix(_:)), keyEquivalent: ""))
        }
        
        // Creating sub menu
        menuItem = NSMenuItem(title: "Set Base", action: nil, keyEquivalent: "")
        menu.addItem(menuItem)
        for i in 2...36 { // 2-36 are all valid radixes
            subMenuItem = RadixMenuItem(title: "\(i)", action: #selector(setRadix(sender:)), keyEquivalent: "")
            subMenuItem.radix = i
            subMenu.addItem(subMenuItem)
        }
        menu.setSubmenu(subMenu, for: menuItem)
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        
        statusItem?.menu = menu
    }

    class RadixMenuItem: NSMenuItem {
        var radix: Int?
    }
}

