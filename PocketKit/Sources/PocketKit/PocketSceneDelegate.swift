import UIKit
import SwiftUI
import MediaPlayer

/// `PocketSceneDelegate` is the UIWindowSceneDelegate
class PocketSceneDelegate: NSObject, UIWindowSceneDelegate {

    internal var window: UIWindow?

    // MARK: UISceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if scene.session.configuration.name == "PocketSceneDelegate" {
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        if scene.session.configuration.name == "PocketSceneDelegate" {
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if scene.session.configuration.name == "PocketSceneDelegate" {
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if scene.session.configuration.name == "PocketSceneDelegate" {
        }
    }
}

extension PocketSceneDelegate: UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    sceneConfig.delegateClass = PocketAppDelegate.self
    return sceneConfig
  }
}
