//
//  AppDelegate.swift
//  IPromote
//
//  Created by a0k07j2 on 8/31/21.
//

import UIKit
import CoreLocation
import PusherSwift
import NotificationBannerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate,PusherDelegate {

    var locationManager: CLLocationManager!
    var pusher: Pusher!

    var welcomeMessage = true
    var promotionalMessage = true
    var chocPromotionalMessage = true
    
    let uuid = UUID(uuidString: "A8FABA6C-8FF2-4C90-B144-BEFBA01949DF")!
    var beaconRegion: CLBeaconRegion!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.requestAlwaysAuthorization()

        beaconRegion = CLBeaconRegion.init(uuid: uuid, major: 4, minor: 46012, identifier: "98072D9F749B")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { _, _ in
        }
        
        let options = PusherClientOptions(
                host: .cluster("us2")
              )
              pusher = Pusher(
                key: "14cb2597ff616b6e7284",
                options: options
              )

              pusher.delegate = self

              // subscribe to channel
              let channel = pusher.subscribe("announcement")

              // bind a callback to handle an event
              let _ = channel.bind(eventName: "promotion", eventCallback: { (event: PusherEvent) in
                  if let data = event.data {
                    // you can parse the data as necessary
                    print(data)
                    let banner = NotificationBanner(title: "Walmart", subtitle: (data), style: .info)
                    banner.show()
                  }
              })

              pusher.connect()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .denied {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint.init(uuid: uuid, major: 4, minor: 46012))
    }
    
    func stopScanning() {
        locationManager.stopMonitoringVisits()
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print(state.rawValue)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            print(String(describing: beacons[0].proximity))

            updateDistance(beacons[0].proximity)
        } else {
            updateDistance(.unknown)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location updated")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        self.scheduleNotification(text: "welcome to Walmart")
        self.startScanning()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        self.scheduleNotification(text: "See you next time")
        self.stopScanning()
    }

    func scheduleNotification(text: String, identifier: String) {
      // 2
      let content = UNMutableNotificationContent()
      content.title = "Walmart"
      content.body = text

      // 4
        let request = UNNotificationRequest(
            identifier: identifier,
          content: content,
          trigger: nil)
        // 5
        UNUserNotificationCenter.current().add(request) { error in
          if let error = error {
            print(error)
          }
        }
    }

    func updateDistance(_ distance: CLProximity) {
            switch distance {
            case .unknown:
                break
            case .far:
                if self.welcomeMessage
                {
                    self.scheduleNotification(text: "Welcome to walmart",identifier: format(date: NSDate.now))
                }
                print("Far")
            case .near:
                if self.chocPromotionalMessage
                {
                    self.scheduleNotification(text: "You are nearing Cookies section and your favorite Kitkat is waiting for you", identifier: format(date: NSDate.now))
                }
                print("near")
            case .immediate:
                if self.promotionalMessage
                {
                    self.scheduleNotification(text: "There is a clearance next to you, Diet Coke is just 2$ for 12 pack.", identifier: format(date: NSDate.now))
                }
                print("immediate")
            @unknown default:
                fatalError()
            }
    }
    
    func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

