# IOS-Recording

It's a simple example of recording the video and the save it locally in document directory and we can play it later with it's url.

# Requirements

IOS 8.0+
XCode 9.0+
Swift 4.0 +

# Quick Guide

In this example we have use the simple CollectionView for display the recorded video and also used the coredata for saving the video name for getting the list of saved video from document directory.

![img_5856 png](https://user-images.githubusercontent.com/34330116/34153070-c3c7cb9a-e4d6-11e7-9ae7-5f7cba99574d.png)

Created the Common class from common method and document directry method of getting and saving videos.

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
    
    
    For recording the video we used the simplest approach AVFoundation framework with AVCaptureFileOutputRecordingDelegate method.
    
        //////////  recording is started ////////
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
        print("Start Recording")
        
    }
    
    
    ////////// Complete the recording ////////////
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Finish Recording")
        self.saveVideo(outputUrl: outputFileURL)
        isNewvideo = true
        self.navigationController?.popViewController(animated: true)
    }
    
    For playing the saved video we have used the AVPlayerViewController.
    
    
![img_5857 png](https://user-images.githubusercontent.com/34330116/34153226-4a90ae3a-e4d7-11e7-807b-1d5a6f743b14.png)
    
    let player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    
    
    # Collaboration
    
    Feel free to collaborate with ideas, issues and pull requests.
    
    
