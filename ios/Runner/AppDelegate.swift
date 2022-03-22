import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Google Maps API Key
    GMSServices.provideAPIKey("AIzaSyCTi7nCedQAS25n4DtLlpC-ZvKTReyE1ng")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
