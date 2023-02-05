//
//  SocialMediaKeevApp.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/9/22.
//

import SwiftUI
import Firebase
import UserNotifications
import FirebaseMessaging

@main
struct SocialMediaKeevApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)  var delegate
    init() {
      //  FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
// MARK: Firebase Push Notifications Configuration




class AppDelegate: NSObject, UIApplicationDelegate{
    let gcmMessageIDKey = "gcm.message_id"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        FirebaseApp.configure()
        // Setting Up Cloud Messaging
        Messaging.messaging().delegate = self
//        UNUserNotificationCenter.current().delegate = self
//        if #available(iOS 10.0, *) {
//            // iOS Display notification (sent via APNS)
//         // r   UNUserNotificationCenter.current().delegate = self
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in
//            }
//        } else {
//            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        
        
        
        return true
    }
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        print("Recived: \(userInfo)")

        completionHandler(.newData)

    }
    
    
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
          // DO SOMETHING WITH MESSAGE DATA HERE

      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      return UIBackgroundFetchResult.newData
    }
    
    // IN ORDER TO RECEIVE NOTIFICATIONS YOU NEED TO IMPLEMENT TYHESE METHODS
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    func application(_ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken;
    }

}

//MARK: Cloud Messaging
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      let dataDict: [String: String] = ["token": fcmToken ?? ""]
        // Store token in Firestore For sending Notifications From server in the future...
        print(dataDict)
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
           // self.fcmToken.text  = "Remote FCM registration token: \(token)"
          }
        }
     
    }
    
    
}
//Mark: User Notifications... AKA in_App Notifications
extension AppDelegate:  UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      let userInfo = notification.request.content.userInfo
        // DO SOMETHING WITH MSG DATA
        if let messageID = userInfo[gcmMessageIDKey] {
            print("MessageID: \(messageID)")
        }

      Messaging.messaging().appDidReceiveMessage(userInfo)

      // Change this to your preferred presentation option
        completionHandler([[.banner,.badge, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("MessageID: \(messageID)")
        }

      Messaging.messaging().appDidReceiveMessage(userInfo)
        print(userInfo)

      completionHandler()
    }

}
