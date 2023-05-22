//
//  CarPlayTemplateManager.swift
//  PKTListen
//
//  Created by Daniel Brooks on 4/17/23.
//  Copyright © 2023 PKT. All rights reserved.
//

import CarPlay
import Foundation
import os
import MediaPlayer
import PKTListen
import Localization

class CarPlayTemplateManager: NSObject {
    /// A reference to the CPInterfaceController that passes in after connecting to CarPlay.
    private var carplayInterfaceController: CPInterfaceController?

    /// The CarPlay session configuation contains information on restrictions for the specified interface.
    var sessionConfiguration: CPSessionConfiguration!

    /// The observer of the Now Playing item changes.
    var nowPlayingItemObserver: NSObjectProtocol?

    /// The observer of the playback state changes.
    var playbackObserver: NSObjectProtocol?

    /// Saves PKT Listen Configuration
    var saves: PKTListenAudibleItemQueue!

    /// Archive PKT Listen Configuration
    var archive: PKTListenAudibleItemQueue!

    /// The current queue of songs.
    var currentQueue: PKTListenAudibleItemQueue?

    var tabBarTemplate: CPTabBarTemplate?

    func connect(_ interfaceController: CPInterfaceController, saves: PKTListenAudibleItemQueue, archive: PKTListenAudibleItemQueue) {
        self.saves = saves
        self.archive = archive
        carplayInterfaceController = interfaceController
        carplayInterfaceController!.delegate = self
        sessionConfiguration = CPSessionConfiguration(delegate: self)
        addObservers()
        self.tabBarTemplate = loggedInTemplate()
        carplayInterfaceController!.setRootTemplate(self.tabBarTemplate!, animated: true, completion: nil)
        // Future improvement, we can enable the album artist button to push a view (and create a Playable audio queue) that shows all Articles by a specific publisher
        CPNowPlayingTemplate.shared.isAlbumArtistButtonEnabled = false
    }

    /// Called when CarPlay disconnects.
    func disconnect() {
        CPNowPlayingTemplate.shared.remove(self)
        nowPlayingItemObserver = nil
        playbackObserver = nil
        MPMusicPlayerController.applicationQueuePlayer.pause()
    }
}

extension CarPlayTemplateManager {

    private func loggedInTemplate() -> CPTabBarTemplate {
        var tabTemplates = [CPTemplate]()
        tabTemplates.append(savesTemplate())
        tabTemplates.append(archiveTemplate())
        return CPTabBarTemplate(templates: tabTemplates)
    }

    private func savesTemplate() -> CPListTemplate {
        let playlistTemplate = CPListTemplate(
            title: Localization.saves, // TODO: Get this from ListenAppConfiguration
            sections: [
                loadCPSection(for: saves)
            ]
        )
        playlistTemplate.tabImage = UIImage(asset: .saves)
        return playlistTemplate
    }

    private func archiveTemplate() -> CPListTemplate {
        let playlistTemplate = CPListTemplate(
            title: Localization.archive, // TODO: Get this from ListenAppConfiguration
            sections: [
                loadCPSection(for: archive)
            ]
        )
        playlistTemplate.tabImage = UIImage(asset: .archive)
        return playlistTemplate
    }

    private func loadCPSection(for audibleQueue: PKTListenAudibleItemQueue) -> CPListSection {
        return CPListSection(
            items: audibleQueue.configuration.source.list.compactMap({ item in
                let cpListItem = CPListItem(text: item.album?.albumTitle, detailText: item.album?.albumStudio)
                cpListItem.handler = { [weak self] playlistItem, completion in
                    guard let self else {
                        completion()
                        return
                    }
                    self.currentQueue = audibleQueue
                    audibleQueue.play(item)
                    self.updateUpdateNextButton()
                    self.carplayInterfaceController?.pushTemplate(CPNowPlayingTemplate.shared, animated: true, completion: nil)
                    // TODO: Ask Nicole if we need to stage the next one?
                    completion()
                }
                return cpListItem
            })
        )
    }

    /// Add observers for playback and Now Playing item.
    private func addObservers() {
        CPNowPlayingTemplate.shared.add(self)
        /// - Tag: observe
        self.playbackObserver = NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: nil,
            queue: .main) {
                notification in
                print("Playback changed")
            }

        self.nowPlayingItemObserver = NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil,
            queue: .main) { [weak self]
                notification in
                print("Item changed")

                guard let self else {
                    return
                }
                self.updateUpdateNextButton()
            }
    }

    private func updateUpdateNextButton() {
        guard let currentQueue = self.currentQueue, currentQueue.staged != nil else {
            CPNowPlayingTemplate.shared.isUpNextButtonEnabled = false
            return
        }
        CPNowPlayingTemplate.shared.isUpNextButtonEnabled = true
    }
}

extension CarPlayTemplateManager: CPNowPlayingTemplateObserver {
    func nowPlayingTemplateUpNextButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
        // Show the queue of songs.
        if let queue = self.currentQueue {
            if queue == self.archive {
                // TODO: Should this be a push or switch the tab??
                self.carplayInterfaceController?.pushTemplate(archiveTemplate(), animated: true, completion: nil)
            } else {
                self.carplayInterfaceController?.pushTemplate(savesTemplate(), animated: true, completion: nil)
            }
        }
        self.updateUpdateNextButton()
    }

    func nowPlayingTemplateAlbumArtistButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
        // If a user taps the AlbumArtistButton, a search for songs from that artist begins.
        if let albumArtist = MPMusicPlayerController.applicationQueuePlayer.nowPlayingItem?.albumArtist {

        }
    }
}

extension CarPlayTemplateManager: CPInterfaceControllerDelegate {
    func templateWillAppear(_ aTemplate: CPTemplate, animated: Bool) {
    }

    func templateDidAppear(_ aTemplate: CPTemplate, animated: Bool) {
    }

    func templateWillDisappear(_ aTemplate: CPTemplate, animated: Bool) {
    }

    func templateDidDisappear(_ aTemplate: CPTemplate, animated: Bool) {
    }
}

extension CarPlayTemplateManager: CPSessionConfigurationDelegate {
    func sessionConfiguration(_ sessionConfiguration: CPSessionConfiguration,
                              limitedUserInterfacesChanged limitedUserInterfaces: CPLimitableUserInterface) {
    }
}

extension CarPlayTemplateManager: CPTabBarTemplateDelegate {
    func tabBarTemplate(_ tabBarTemplate: CPTabBarTemplate, didSelect selectedTemplate: CPTemplate) {

    }
}
