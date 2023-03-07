//
//  File.swift
//  
//
//  Created by Daniel Brooks on 3/7/23.
//
import Combine
import Foundation
import Analytics


class DeleteAccountViewModel: ObservableObject {
    @Published var isPresentingDeleteYourAccount = false
    @Published var isPresentingCancelationHelp = false
 
    private let userManagementService: UserManagementServiceProtocol
    private let tracker: Tracker

    
    init(tracker: Tracker, userManagementService: UserManagementServiceProtocol) {
        self.userManagementService = userManagementService
        self.tracker = tracker
//        // Set up a listener to track analytics if the user taps cancelation help
//        isPresentingCancelationHelpListener = $isPresentingCancelationHelp
//            .receive(on: DispatchQueue.global(qos: .utility))
//            .sink {  [weak self] isPresentingCancelationHelp in
//                guard let strongSelf = self else {
//                    Log.warning("weak self when logging analytics for settings")
//                    return
//                }
//                if isPresentingCancelationHelp {
//                    strongSelf.trackHelpCancelingPremiumTapped()
//                }
//            }
    }
    
}
