//
//  ViewController.swift
//  YoutubeSourceParserSwift3
//
//  Created by Elon on 2017. 4. 5..
//  Copyright © 2017년 Elon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let testURL = URL(string: "https://www.youtube.com/watch?v=5ZbmVDxNGn8") {
            YoutubeSourceParser.h264videos(withYoutubeURL: testURL, completion: { (videoInfo, error) in
                guard let videoInfo = videoInfo else { return; }
                
                if let isStream = videoInfo["isStream"] as? Bool, isStream == true, let streamURL = videoInfo["url"] {
                    print("streamURL = \(streamURL)")
                }
                
                let videoInfoQualityHD720 = videoInfo["hd720"] as? [String: Any]
                let videoInfoQualityMedium = videoInfo["medium"] as? [String: Any]
                let videoInfoQualitySmall = videoInfo["small"] as? [String: Any]
                
                if let qualityHD720URL = videoInfoQualityHD720?["url"] as? String {
                    print("qualityHD720URL = \(qualityHD720URL)")
                }
                
                if let qualityMediumURL = videoInfoQualityMedium?["url"] as? String {
                    print("qualityHD720URL = \(qualityMediumURL)")
                }
                
                if let qualitySmallURL = videoInfoQualitySmall?["url"] as? String {
                    print("qualityHD720URL = \(qualitySmallURL)")
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

