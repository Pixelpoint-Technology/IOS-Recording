//
//  VideoListVC.swift
//  iOS-Recording
//
//  Created by Sachin on 12/12/17.
//  Copyright © 2017 Pixelpoint. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import AVKit

var isNewvideo = false

class VideoListVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var listArr: NSArray!
    var videolist: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Videos"
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        videolist = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        videolist.register(UINib(nibName: "CustomCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        videolist.backgroundColor = UIColor.clear
        videolist.delegate = self
        videolist.dataSource = self
        self.view.addSubview(videolist)
        
        getListdata()
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isNewvideo {
            isNewvideo = false
            getListdata()
        }
        
    }
    
    func getListdata()  {
        /////////// Getting list of videos from coredata ///////
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Videos", in: managedContext)
        fetchRequest.entity = entity
        fetchRequest.returnsObjectsAsFaults = false
        listArr = try? managedContext.fetch(fetchRequest) as NSArray
        videolist.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCell
        
        let vid_entity = listArr.object(at: indexPath.row) as! Videos
        let videoPath = Common().getVideoPathFromDocumentDirectory(vid_entity.video_id)
        let videoUrl = Common().GetVideoUrl(path: videoPath)
        let img = Common().getThumbnailImage(forUrl: videoUrl)
        
        let asset = AVURLAsset(url: videoUrl)
        cell.durationLbl.text = asset.duration.durationText
        print(asset.duration.durationText)
        if img != nil {
            cell.imageview.image = img
        }
        else{
//            cell.imageview.image = UIImage(named: "")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.view.frame.size.width-20)/2
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vid_entity = listArr.object(at: indexPath.row) as! Videos
        let videoPath = Common().getVideoPathFromDocumentDirectory(vid_entity.video_id)
        let videoUrl = Common().GetVideoUrl(path: videoPath)

        let player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }  

}
