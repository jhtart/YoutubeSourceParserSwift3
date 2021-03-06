# YoutubeSourceParserSwift3 

==================<br/>
[![Build Status](https://img.shields.io/travis/movielala/YoutubeSourceParserKit/master.svg)](https://travis-ci.org/movielala/YoutubeSourceParserKit)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
[![Dependencies](https://img.shields.io/badge/dependencies-none-brightgreen.svg)](https://github.com/mobileplayer/mobileplayer-ios)


YouTube Video Link Parser for Swift3. Heavily inspried from mojilala's repo [YoutubeSourceParserKit](https://github.com/mojilala/YoutubeSourceParserKit)


##Usage

```
if let testURL = URL(string: "https://www.youtube.com/watch?v=5ZbmVDxNGn8") {
    YoutubeSourceParser.h264videos(withYoutubeURL: testURL, completion: { (videoInfo, error) in
        guard let videoInfo = videoInfo else { return; }

        if let isStream = videoInfo["isStream"] as? Bool, isStream == true, 
           let streamURL = videoInfo["url"] {
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
```
