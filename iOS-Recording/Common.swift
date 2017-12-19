//
//  Common.swift
//  iOS-Recording
//
//  Created by Sachin on 18/12/17.
//  Copyright © 2017 Pixelpoint. All rights reserved.
//

import UIKit
import AVFoundation

class Common: NSObject {
    
    // MARK: Shared Instance
    class  var sharedInstance: Common {
        struct singleton {
            static let instance = Common()
        }
        return singleton.instance
    }
    
    /////////////  Gettting directory common path ///////
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    ////////// Saving video in docoment directory ///////////
    func saveVideoInDocumentDirectory(_ VideoPath: String!, VideoData: NSData!) {
        
        let fileManager = FileManager.default
        let paths = (getDirectoryPath() as NSString).appendingPathComponent(VideoPath)
        print(paths)
        if !fileManager.fileExists(atPath: paths){
            VideoData?.write(toFile: paths, atomically: false)
        } else {
            print("File is already saved with this name")
        }
    }
    
    /////// Get video path from document directory ///////
    func getVideoPathFromDocumentDirectory(_ video_id: String!) -> String{
        let fileManager = FileManager.default
        let videoPAth = (self.getDirectoryPath() as NSString).appendingPathComponent(video_id)
        if fileManager.fileExists(atPath: videoPAth){
            return videoPAth
        }else{
            print("No video")
            return ""
        }
    }
    
    ///////// Getting video url from directory path ///////////
    func GetVideoUrl(path : String) -> URL {
        
        let directoryURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        /////// Url of video //////
        
        let VideoURL = directoryURL.appendingPathComponent("video.mov")
        
        let videoFileURL = URL(fileURLWithPath: path)
        let videodata = NSData(contentsOf: videoFileURL)
        
        try? videodata?.write(to: VideoURL)
        
        return VideoURL
        
    }
    
    ////////// Getting the thumb image from video url //////
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
}

/////// For converting the cmtime of video in hour min and seconds //////
extension CMTime {
    
    var durationText:String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

