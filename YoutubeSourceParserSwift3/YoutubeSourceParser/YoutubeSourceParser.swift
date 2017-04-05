//
//  YoutubeSourceParser.swift
//  minimeme
//
//  Created by Elon on 2017. 4. 4..
//  Copyright © 2017년 Han. All rights reserved.
//

import Foundation

extension URL {
    
    func dictionaryForQueryString() -> [String: Any]? {
        if let query = self.query {
            return query.dictionaryFromQueryStringComponents()
        }
        
        // find youtube ID from "https://m.youtube.com/#/watch?v=1hZ98an9wjo"
        let result = self.absoluteString.components(separatedBy: "?")
        if result.count > 1 {
            return result.last?.dictionaryFromQueryStringComponents()
        }
        
        return nil
    }
}

extension String {
    
    func stringByDecodingURLFormat() -> String? {
        let result = self.replacingOccurrences(of: "+", with: " ")
        return result.removingPercentEncoding
    }
    
    func dictionaryFromQueryStringComponents() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        for keyValue in self.components(separatedBy: "&") {
            let keyValueArray = keyValue.components(separatedBy: "=")
            if keyValueArray.count < 2 {
                continue
            }
            if let key = keyValueArray[0].stringByDecodingURLFormat(),
                let value = keyValueArray[1].stringByDecodingURLFormat() {
                parameters[key] = value
            }
        }
        
        return parameters
    }
}

typealias YoutubeSourceParserCompletion = (_ videoInfo: [String: Any]?, _ error: NSError?) -> Void

class YoutubeSourceParser: NSObject {
    private static let videoInfoURL = "https://www.youtube.com/get_video_info?video_id="
    private static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
    private static let qualityKeys = ["hd720", "medium", "small"]
    
    private static func youtubeID(fromYoutubeURL youtubeURL: URL) -> String? {
        if let youtubeHost = youtubeURL.host, youtubeURL.pathComponents.count > 0 {
            let youtubePathComponents = youtubeURL.pathComponents
            let youtubeAbsoluteString = youtubeURL.absoluteString
            if youtubeHost == "youtu.be" {
                return youtubePathComponents[1]
            } else if youtubeAbsoluteString.range(of: "www.youtube.com/embed") != nil {
                return youtubePathComponents[2]
            } else if youtubeHost == "youtube.googleapis.com" ||
                youtubeURL.pathComponents.first == "www.youtube.com" {
                return youtubePathComponents[2]
            } else if let queryString = youtubeURL.dictionaryForQueryString(),
                let youtubeID = queryString["v"] as? String {
                return youtubeID
            }
        }
        return nil
    }
    
    private static func h264videos(WithYoutubeID youtubeID: String, completion: YoutubeSourceParserCompletion?) {
        let urlString = String(format: "%@%@", videoInfoURL, youtubeID) as String
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        request.timeoutInterval = 5.0
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        
        var responseString = String()
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                responseString = String(data: data, encoding: .utf8) ?? ""
                
                let parts = responseString.dictionaryFromQueryStringComponents()
                if parts.count > 0 {
                    var videoTitle: String = ""
                    var streamImage: String = ""
                    if let title = parts["title"] as? String {
                        videoTitle = title
                    }
                    if let image = parts["iurl"] as? String {
                        streamImage = image
                    }
                    if let fmtStreamMap = parts["url_encoded_fmt_stream_map"] as? String {
                        var videoComponents: [String: Any] = [:]
                        // Live Stream
                        if let _ = parts["live_playback"]{
                            if let hlsvp = parts["hlsvp"] as? String {
                                videoComponents = [
                                    "url": hlsvp,
                                    "title": videoTitle,
                                    "image": streamImage,
                                    "isStream": true
                                ]
                            }
                        } else {
                            let fmtStreamMapArray = fmtStreamMap.components(separatedBy: ",")
                            videoComponents["title"] = videoTitle
                            videoComponents["isStream"] = false
                            
                            for videoEncodedString in fmtStreamMapArray {
                                for key in qualityKeys {
                                    if videoEncodedString.contains(key) == true {
                                        videoComponents[key] = videoEncodedString.dictionaryFromQueryStringComponents()
                                        break
                                    }
                                }
                            }
                        }
                        
                        if let completion = completion {
                            completion(videoComponents, nil)
                        }
                    }
                }
                
                if let completion = completion {
                    completion(nil, NSError(domain: "com.player.youtube.backgroundqueue", code: 1001, userInfo: ["error": "Invalid YouTube URL"]))
                }
            }
        }).resume()
    }

    static func h264videos(withYoutubeURL youtubeURL: URL, completion: YoutubeSourceParserCompletion? ) {
        DispatchQueue.global().async {
            if let youtubeID = self.youtubeID(fromYoutubeURL: youtubeURL) {
                self.h264videos(WithYoutubeID: youtubeID, completion: { (_ videoInfo: [String: Any]?, _ error: NSError?) in
                    DispatchQueue.main.async {
                        if let completion = completion {
                            completion(videoInfo, error)
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    if let completion = completion {
                        completion(nil, NSError(domain: "com.player.youtube.backgroundqueue", code: 1001, userInfo: ["error": "Invalid YouTube URL"]))
                    }
                }
            }
        }
    }
    
}
