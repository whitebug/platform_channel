import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private let EVENT_CHANNEL = "im.parrot.keyPressedChannel"
    
    private var streamHandler: NativeStreamHandler?

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(enterPressed)),
            UIKeyCommand(input: InputKey.one.rawValue,
              modifierFlags: .shift,
              action: #selector(performCommand(sender:)),
              discoverabilityTitle: NSLocalizedString("LowPriority", comment: "Low priority")),
        ]
    }

    @objc func enterPressed() {
        print("Enter pressed")
        currentKey = "enter"
        // send key name to stream
        keysToStream(key: currentKey)
    }
    
    private enum InputKey: String {
        case one = "1"
        case two = "2"
        case three = "3"
    }
    
    @objc func performCommand(sender: UIKeyCommand) {
        guard let key = InputKey(rawValue: sender.input ?? "no key") else {
        return
      }
        currentKey = key.rawValue
        print(currentKey)
        keysToStream(key: currentKey)
    }
    
    var currentKey = "no key"
        
    func getKeyPressed() -> String {
        return currentKey
    }
    
    private func receiveKeyPressed(result: FlutterResult) {
        result(getKeyPressed())
    }
    
    func setUpEventChannel() {
        guard let controller: FlutterViewController = window?.rootViewController as? FlutterViewController else {
            fatalError("Invalid root view controller")
        }
        
        let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: controller as! FlutterBinaryMessenger)
        
        if (self.streamHandler == nil) {
            self.streamHandler = NativeStreamHandler()
        }
        
        eventChannel.setStreamHandler((self.streamHandler as! FlutterStreamHandler & NSObjectProtocol))
    }
    
    func keysToStream(key: String) {
        self.streamHandler?.eventSink?(key as Any?)
    }
    
    override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let keyPressedChannel = FlutterMethodChannel(name: "im.parrot.keyPressed", binaryMessenger: controller.binaryMessenger)
        
      keyPressedChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          guard call.method == "getCurrentKey" else {
              result(FlutterMethodNotImplemented)
              return
          }
          self?.receiveKeyPressed(result: result)
      })
        
      // event channel
        setUpEventChannel()
      
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

public class NativeStreamHandler: FlutterStreamHandler {
    
    var eventSink: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
}
