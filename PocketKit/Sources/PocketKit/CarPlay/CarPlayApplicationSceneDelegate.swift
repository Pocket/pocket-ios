//
//  CarPlayApplicationSceneDelegate.swift
//  Listen
//
//  Created by Daniel Brooks on 4/17/23.
//  Copyright © 2023 PKT. All rights reserved.
//

import CarPlay
import UIKit
import PKTListen
import Sync
import Localization

class CarPlayApplicationSceneDelegate: NSObject {
    /// The template manager handles the connection to CarPlay and manages the displayed templates.
    let templateManager: CarPlayTemplateManager

    override init() {
        let source = Services.shared.source

        var saves: [SavedItem] = []
        var archive: [SavedItem] = []

        do {
            let savesController = source.makeSavesController()
            try savesController.performFetch()
            saves = savesController.fetchedObjects ?? []
        } catch {

        }

        do {
            let archiveController = source.makeArchiveController()
            try archiveController.performFetch()
            archive = archiveController.fetchedObjects ?? []
        } catch {

        }

        templateManager = CarPlayTemplateManager(
            saves: PKTListenAppConfiguration(source: ListenViewModel.source(savedItems: saves, title: Localization.saves)),
            archive: PKTListenAppConfiguration(source: ListenViewModel.source(savedItems: archive, title: Localization.archive))
        )
    }

    // MARK: UISceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if scene is CPTemplateApplicationScene, session.configuration.name == "CarPlayApplicationSceneConfiguration" {
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        if scene.session.configuration.name == "CarPlayApplicationSceneConfiguration" {
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if scene.session.configuration.name == "CarPlayApplicationSceneConfiguration" {
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if scene.session.configuration.name == "CarPlayApplicationSceneConfiguration" {
        }
    }

}

// MARK: CarPlayApplicationSceneDelegate

extension CarPlayApplicationSceneDelegate: CPTemplateApplicationSceneDelegate {

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        templateManager.connect(interfaceController)
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        templateManager.disconnect()
    }
}
