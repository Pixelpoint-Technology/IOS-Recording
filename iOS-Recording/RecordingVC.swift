//
//  RecordingVC.swift
//  iOS-Recording
//
//  Created by Sachin on 19/12/17.
//  Copyright © 2017 Pixelpoint. All rights reserved.
//


import UIKit
import AVFoundation
import CoreData

class RecordingVC: UIViewController,AVCaptureFileOutputRecordingDelegate {
    
    var camPreview: UIView!
    
    let cameraButton = UIButton()
    
    let timerLbl = UILabel()
    var count = 0
    var timer = Timer()
    
    let captureSession = AVCaptureSession()
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var activeInput: AVCaptureDeviceInput!
    
    var outputURL: URL!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        camPreview = UIView(frame: self.view.frame)
        self.view.addSubview(camPreview)
        
        if SessionsetupCheck() {
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = camPreview.bounds
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            camPreview.layer.addSublayer(previewLayer)
            
            startSession()
        }
        
        
        cameraButton.frame = CGRect(x: self.view.frame.size.width/2-35, y: self.view.frame.size.height-80, width: 70, height: 70)
        cameraButton.addTarget(self, action: #selector(self.startRecording), for: .touchUpInside)
        cameraButton.layer.cornerRadius = cameraButton.frame.size.height/2
        cameraButton.backgroundColor = UIColor.red
        cameraButton.setImage(UIImage(named: "play"), for: .normal)
        camPreview.addSubview(cameraButton)
        
        timerLbl.frame = CGRect(x: cameraButton.frame.origin.x+10, y: cameraButton.frame.origin.y, width: 50, height: cameraButton.frame.size.height)
        timerLbl.textAlignment = .center
        timerLbl.textColor = UIColor.black
        timerLbl.text = "0"
        timerLbl.isHidden = true
        camPreview.addSubview(timerLbl)
        
    }
    
    ///////// Checking the session setup///////
    func SessionsetupCheck() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // camera setup for video
        let camera = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error \(error)")
            return false
        }
        
        // mic setup for getting the sound
        let mic = AVCaptureDevice.default(for: .audio)
        
        do {
            let micInput = try AVCaptureDeviceInput(device: mic!)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error \(error)")
            return false
        }
        
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    
    func startSession() {
        if !captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.startRunning()
            }
        }
    }
    
    
    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    
    @objc func startRecording() {
        
        if movieOutput.isRecording == false {
            cameraButton.setImage(UIImage(named: "stop"), for: .normal)
            timerLbl.isHidden = false
            
            let connection = movieOutput.connection(with: .video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error \(error)")
                }
                
            }
            
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.changeTimer), userInfo: nil, repeats: true)
            
        }
        else {
            cameraButton.setImage(UIImage(named: "play"), for: .normal)
            timerLbl.isHidden = true
            stopRecording()
            timer.invalidate()
            count = 0
            timerLbl.text = "\(count)"
            
        }
    }
    
    @objc func changeTimer() {
        count = count+1
        timerLbl.text = "\(count)"
    }
    
    ///////// Save video in directory and save id in coredata to retrive it in future. /////
    func saveVideo(outputUrl: URL) {
        let video_id = NSUUID().uuidString
        let video_data : NSData? = NSData(contentsOf: outputUrl)
        Common().saveVideoInDocumentDirectory(video_id, VideoData: video_data)
        
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        //////// saving video id to coredata  ///////
        let managedContext = appDelegate.persistentContainer.viewContext
        let videoEntity = NSEntityDescription.insertNewObject(forEntityName: "Videos", into: managedContext) as! Videos
        videoEntity.video_id = video_id
        try? managedContext.save()
    }
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


