//
//  AdProvider.swift
//  BLUE
//
//  Created by Karol on 24/11/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import Foundation
import Firebase

class AdsProvider : NSObject{
    var adsShouldBeVisible = false
    
    var fullScreenAd : GADInterstitial!{
        willSet{
            fullScreenAd?.delegate = nil
        }
    }
    
    var counter : Int{
        get{
            if (UserDefaults.standard.object(forKey: "fullScreenCounter") != nil){
                return UserDefaults.standard.integer(forKey: "fullScreenCounter")
            }else{
                return 0
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "fullScreenCounter")
        }
    }
    
    var showFullScreen : Bool{
        return counter % 5 == 0
    }
    
    weak var viewController : ViewController!
    private var fullScreenAdID = "ca-app-pub-3940256099942544/1033173712"
    private let bannerViewMapViewAdID = "ca-app-pub-3940256099942544/2934735716"
    
    func initiateAds(){
        guard adsShouldBeVisible else {return}
        viewController.adView.adUnitID = bannerViewMapViewAdID
        viewController.adView.rootViewController = viewController
        viewController.adView.adSize = kGADAdSizeSmartBannerPortrait
        viewController.adView.load(GADRequest())
        
        fullScreenAd = GADInterstitial(adUnitID: fullScreenAdID)
        fullScreenAd.load(GADRequest())
    }
    
    func showFullScreenAd(){
        guard adsShouldBeVisible else {return}
        guard fullScreenAd != nil else {return}
        guard fullScreenAd.isReady else{return}
        counter += 1
        guard showFullScreen else {return}
        fullScreenAd.present(fromRootViewController: viewController)
        fullScreenAd = createNewFullScreenAd()
    }
    
    func createNewFullScreenAd() -> GADInterstitial{
        let ad = GADInterstitial(adUnitID: fullScreenAdID)
        ad.load(GADRequest())
        return ad
    }
    
    func createNewAd(){
        guard adsShouldBeVisible else {
            viewController.adView.isHidden = true
            return
        }
        viewController.adView.delegate = nil
        viewController.adView.load(GADRequest())
    }
}
