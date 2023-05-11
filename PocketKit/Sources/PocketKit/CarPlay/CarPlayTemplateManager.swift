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

class CarPlayTemplateManager: NSObject {
    /// A reference to the CPInterfaceController that passes in after connecting to CarPlay.
    private var carplayInterfaceController: CPInterfaceController?

    /// The CarPlay session configuation contains information on restrictions for the specified interface.
    var sessionConfiguration: CPSessionConfiguration!

    /// The observer of the Now Playing item changes.
    var nowPlayingItemObserver: NSObjectProtocol?

    /// The observer of the playback state changes.
    var playbackObserver: NSObjectProtocol?

    /// PKT Listen Configuration
    var saves: PKTListenConfiguration

    var archive: PKTListenConfiguration

    // TODO: is there a better more abstract init here so we can move CarPlayTemplate manager into PKTListen?
    init(saves: PKTListenConfiguration, archive: PKTListenConfiguration) {
        self.saves = saves
        self.archive = archive
    }

    func connect(_ interfaceController: CPInterfaceController) {
        carplayInterfaceController = interfaceController
        carplayInterfaceController!.delegate = self
        sessionConfiguration = CPSessionConfiguration(delegate: self)
        addObservers()
        carplayInterfaceController!.setRootTemplate(loggedInTemplate(), animated: true, completion: nil)
    }

    /// Called when CarPlay disconnects.
    func disconnect() {
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
        tabTemplates.append(playlistsTemplate())
        return CPTabBarTemplate(templates: tabTemplates)
    }

    private func savesTemplate() -> CPListTemplate {
        let items: [CPListItem] = saves.source.list.compactMap({ item in
            let item2 = item
        return CPListItem(text: item.album?.albumTitle, detailText: "")
        })
        let playlistTemplate = CPListTemplate(
                            title: "Saves",
                            sections: [CPListSection(items: [])])
        playlistTemplate.tabImage = UIImage(asset: .saves)
        return playlistTemplate
    }

    private func archiveTemplate() -> CPListTemplate {
        let playlistTemplate = CPListTemplate(
                            title: "Archive",
                            sections: [CPListSection(items: [])])
        playlistTemplate.tabImage = UIImage(asset: .archive)
        return playlistTemplate
    }

    private func playlistsTemplate() -> CPListTemplate {
        let playlistTemplate = CPListTemplate(
                            title: "Playlists",
                            sections: [CPListSection(items: [])])
        playlistTemplate.tabImage = UIImage(systemName: "list.star")
        return playlistTemplate
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

        }

        self.nowPlayingItemObserver = NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil,
            queue: .main) {
            notification in
        }
    }
}

extension CarPlayTemplateManager: CPNowPlayingTemplateObserver {
    func nowPlayingTemplateUpNextButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
        // Show the queue of songs.
//        if let queue = self.currentQueue {
//            CPNowPlayingTemplate.shared.isUpNextButtonEnabled = true
//            let listTemplate = CPListTemplate(title: "Playlist", sections: [CPListSection(items: queue.compactMap({ item -> CPListItem in
//                let listItem = CPListItem(text: item.albumTitle, detailText: item.albumArtist)
//                listItem.isPlaying = queue[MPMusicPlayerController.applicationQueuePlayer.indexOfNowPlayingItem].albumID == item.albumID
//                //searchHandlerForItem(listItem: listItem)
//                return listItem
//            }))])
//            self.carplayInterfaceController?.pushTemplate(listTemplate, animated: true, completion: nil)
//        } else {
//            CPNowPlayingTemplate.shared.isUpNextButtonEnabled = false
//        }
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
