//
//  Switcher
//
//  Created by 김수환 on 2022/01/08.
//

import SwiftUI
import Darwin // needed for exit(0)

@main
struct SwitcherApp: App {
    // Linking a created AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        // IMPORTANT
        Settings {
            ContentView()
            
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate{
    var state = Wrapper()
    var statusItem: NSStatusItem?
    var popOver = NSPopover()
    public func applicationDidFinishLaunching(_ notification: Notification) {
        if AXIsProcessTrusted() {
            createEventTap()
            MakeMenuButton()
        } else{
            ShellCommand(arg: Privacy_Accessibility)
            WelcomeView().openInWindow(title: "Switcher", sender: self)
            createEventTap()
            MakeMenuButton()
        }
       
    }


    
    func MakeMenuButton(){
        let menuView = MenuView()
        popOver.behavior = .transient
        popOver.animates = true
//        set empty view controller
        popOver.contentViewController = NSViewController()
        popOver.contentViewController?.view = NSHostingView(rootView: menuView)
//        making view as main view
//        popOver.contentViewController?.view.window?.makeKey()
        popOver.contentSize = NSSize(width: 360, height: 800)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let MenuButton = statusItem?.button{
//            MenuButton.image = NSImage(systemSymbolName: "command", accessibilityDescription: nil)
//            MenuButton.title = "􀙀"
            MenuButton.image = NSImage(named: "IMG")
            MenuButton.action = #selector(MenuButtonToggle)
        }

    }
    
    
    @objc func MenuButtonToggle(sender: AnyObject) {
//      showing popover
            if popOver.isShown{
                popOver.performClose(sender)
            }else{
                if let MenuButton = statusItem?.button{
                    //Top Get Button Location for popover arrow
                    self.popOver.show(relativeTo: MenuButton.bounds, of: MenuButton, preferredEdge: NSRectEdge.minY)
                }
            }
    }
    

    func createEventTap() {
      let eventTap = CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: [.keyDown, .leftMouseDown, .rightMouseDown, .scrollWheel],
        callback: { proxy, _, cgEvent, ctx in
          if let event = NSEvent(cgEvent: cgEvent),
             let wrapper = ctx?.load(as: Wrapper.self) {
            if let newEvent = handle(event: event, cgEvent: cgEvent, wrapper: wrapper, proxy: proxy) {
              /// Quoting from https://developer.apple.com/documentation/coregraphics/cgeventtapcallback?language=swift
              /// Your callback function should return one of the following:
              /// - The (possibly modified) event that is passed in. This event is passed back to the event system.
              ///   - [we call passUnretained here since the event system is retaining the original event]
              /// - A newly-constructed event. After the new event has been passed back to the event system, the new event will be released along with the original event.
              ///   - [we call passRetained here because the event system will eventually release the event we return]
              /// - `NULL` if the event passed in is to be deleted.
              if newEvent == cgEvent {
                return .passUnretained(cgEvent)
              } else {
                return .passRetained(newEvent)
              }
            } else {
              return nil
            }
          } else {
            print("Unexpected failure to construct state or NSEvent")
            return .passUnretained(cgEvent)
          }
        }, userInfo: &state)
      if let eventTap = eventTap {
        RunLoop.current.add(eventTap, forMode: .common)
        CGEvent.tapEnable(tap: eventTap, enable: true)
      }
    }
  }


extension View {
    
    @discardableResult
    func openInWindow(title: String, sender: Any?) -> NSWindow {
        let controller = NSHostingController(rootView: self)
        let win = NSWindow(contentViewController: controller)
        win.contentViewController = controller
        win.title = title
        win.makeKeyAndOrderFront(sender)
        return win
    }
    func displayAlert() -> NSWindow {
        let controller = NSHostingController(rootView: self)
        let win = NSWindow(contentViewController: controller)
//        win.isMovableByWindowBackground = false
        win.contentViewController = controller
        win.makeKeyAndOrderFront(nil)
        win.titleVisibility = .hidden
        win.titlebarAppearsTransparent = true
        win.isOpaque = false
        win.backgroundColor = NSColor.clear
        win.alphaValue = 0.98 //you can remove this line but it adds a nice effect to it
        win.styleMask.remove(.closable)
        win.styleMask.remove(.fullScreen)
        win.styleMask.remove(.miniaturizable)
        win.styleMask.remove(.fullSizeContentView)
        win.styleMask.remove(.resizable)
        win.orderFrontRegardless()
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
            win.close()
        }
        return win
    }

}



