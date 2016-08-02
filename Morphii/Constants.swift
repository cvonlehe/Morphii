//
//  Constants.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/6/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import Foundation

class ViewControllerIDs {
    static let TabBarController = "TabBarController"
    static let SettingsViewController = "SettingsViewController"
    static let SettingsWebViewController = "SettingsWebViewController"
    static let HomeViewController = "HomeViewController"
    static let SearchViewController = "SearchViewController"
    static let OverlayViewController = "OverlayViewController"
    static let TutorialViewController = "TutorialViewController"
    static let TutorialContainerViewController = "TutorialContainerViewController"
    static let FavoritesViewController = "FavoritesViewController"
    static let ModifiedMorphiiOverlayViewController = "ModifiedMorphiiOverlayViewController"
    static let TrendingViewcController = "TrendingViewcController"
    static let ForceUpgradeViewController = "ForceUpgradeViewController"
    static let VideoTutorialViewController = "VideoTutorialViewController"
}

class CollectionViewCellIDs {
    static let MorphiiCollectionViewCell = "MorphiiCollectionViewCell"
    static let CollectionTableViewCell = "CollectionTableViewCell"
}

class TableViewCellIDs {
    static let CollectionTableViewCell = "CollectionTableViewCell"
    static let MorphiiTableViewCell = "MorphiiTableViewCell"
    static let TagsTableViewCell = "TagsTableViewCell"
    static let NoXFoundTableViewCell = "NoXFoundTableViewCell"
}

class NSUserDefaultKeys {
    static let returningUser = "returningUser"
    static let shouldNotAddURLToMessages = "shouldNotAddURLToMessages"
    static let lastDate = "lastDate"
    static let token = "token"
}

class URLs {
   
}

class MorphiiAPIKeys {
    static let records = "records"
    static let data = "data"
    static let metaData = "metaData"
    static let scaleType = "scaleType"
    static let id = "id"
    static let name = "name"
    static let sequence = "sequence"
    static let category = "category"
    static let keywords = "keywords"
    static let groupName = "groupName"
    static let showName = "showName"
}

class PFConfigValues {
    static let MORPHII_API_KEY = "MORPHII_API_KEY"
    static let MORPHII_API_BASE_URL = "MORPHII_API_BASE_URL"
    static let MORPHII_API_ACCOUNT_ID = "MORPHII_API_ACCOUNT_ID"
    static let MORPHII_API_USER_NAME = "MORPHII_API_USER_NAME"
    static let MORPHII_API_PASSWORD = "MORPHII_API_PASSWORD"
    static let appStoreUrl = "appStoreUrl"
    static let AWS_APP_ID = "AWS_APP_ID"
    static let AWS_POOL_ID = "AWS_POOL_ID"
}

class EntityNames {
    static let Morphii = "Morphii"
    static let User =  "User"
    static let TrendingData = "TrendingData"
}

class CacheNames {
    static let AllMorphiiFetchedResultsCollectionView = "AllMorphiiFetchedResultsCollectionView"
}

class CollectionReusableViewIds {
    static let HeaderCollectionReusableView = "HeaderCollectionReusableView"
}

class MorphiiAreas {
    static let containerHome = "container­-home"
    static let containerFavorites = "container­-favorites"
    static let containerTrending = "container­-trending"
    static let keyboardHome = "keyboard-home"
    static let keyboardRecent = "keyboard-recent"
    static let keyboardFavorites = "keyboard-favorites"
    static let keyboardSearch = "keyboard-search"
}

class ProfileChanges {
    static let addUrl = "Add URL to Message"
}

class ProfileActions {
    static let SetupMorphiiKeyboard = "Setup Morphii Keyboard"
    static let InviteFriends = "Invite Friends"
    static let Feedback = "Feedback"
    static let RateThisApp = "Rate this App"
    static let OurBlog = "Our Blog"
    static let PrivacyPolicy = "Privacy Policy"
    static let TermsAndConditions = "Terms and Conditions"
}

class ShareValues {
    static let cameraRoll = "com.apple.UIKit.activity.SaveToCameraRoll"
}

let acceptableCharacters = " #0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"