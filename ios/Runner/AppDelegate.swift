import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private let EVENT_CHANNEL = "im.parrot.keyPressedChannel"
    private var streamHandler: NativeStreamHandler?
    private var currentKey = "no key"

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: InputKey.enter.rawValue,
              modifierFlags: [],
              action: #selector(sendNoModifierKeyToSteam(sender:)),
              discoverabilityTitle: NSLocalizedString("Enter", comment: "Enter")),
            UIKeyCommand(input: InputKey.ctrlF.rawValue,
                         modifierFlags: .control,
              action: #selector(sendCtrlKeyToSteam(sender:)),
              discoverabilityTitle: NSLocalizedString("ControlF", comment: "Control F")),
            UIKeyCommand(input: InputKey.ctrlF.rawValue,
                         modifierFlags: .shift,
              action: #selector(sendShiftKeyToStream(sender:)),
              discoverabilityTitle: NSLocalizedString("ShiftF", comment: "Shift F")),
        ]
    }
    
    private enum InputKey: String {
        case enter = "\r"
        case ctrlF = "f"
    }
    
    @objc func sendNoModifierKeyToSteam(sender: UIKeyCommand) {
        guard let key = InputKey(rawValue: sender.input ?? "no key") else {
        return
      }
        currentKey = key.rawValue
        switch key.rawValue {
        case "\r":
            currentKey = "enter"
        default:
            currentKey = "noKey"
        }
        keysToStream(key: currentKey)
    }
    
    @objc func sendCtrlKeyToSteam(sender: UIKeyCommand) {
        guard let key = InputKey(rawValue: sender.input ?? "no key") else {
        return
      }
        currentKey = key.rawValue
        switch key.rawValue {
        case "f":
            currentKey = "ctrlF"
        default:
            currentKey = "noCtrlKey"
        }
        keysToStream(key: currentKey)
    }
    
    @objc func sendShiftKeyToStream(sender: UIKeyCommand) {
        guard let key = InputKey(rawValue: sender.input ?? "no key") else {
        return
      }
        currentKey = key.rawValue
        print(currentKey)
        switch key.rawValue {
        case "f":
            currentKey = "shiftF"
        default:
            currentKey = "noShiftKey"
        }
        keysToStream(key: currentKey)
    }
        
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
