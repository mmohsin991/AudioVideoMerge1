//
//  ViewController.swift
//  AudioVideoMerge
//
//  Created by Mohsin on 16/02/2015.
//  Copyright (c) 2015 PanaCloud. All rights reserved.
//

import UIKit

import AVFoundation
import AssetsLibrary
import MediaPlayer

class ViewController: UIViewController {
    
    var moviePlayer : MPMoviePlayerController!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.activityView.hidden = true
        self.lblErrorMsg.hidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func loadMoviePlayer(url: NSURL){
        
        
        self.moviePlayer = MPMoviePlayerController(contentURL: url)
        
        let player: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: url)
        player.view.frame = CGRectMake(0, 0, self.view.frame.width / 2, self.view.frame.height / 2)
        self.view.addSubview(player.view)
        self.presentMoviePlayerViewControllerAnimated(player)
        
        
    }
    
    
    
    func mergeAudiVideo(#audioUrl: NSURL, videoUrl : NSURL, outputVideName: String, callBack : (outputUrl: NSURL? , errorDesc: String?)->Void){
        var mixComposition = AVMutableComposition()
        
        
        //first load your audio file using AVURLAsset, Make sure you give the correct path of your videos.
        let audioAsset = AVURLAsset(URL: audioUrl, options: nil)
        let  audio_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        
        
        //Now we will load video file.
        let videoAsset = AVURLAsset(URL: videoUrl, options: nil)
        let  video_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        
        
        //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
        
        let b_compositionAudioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        var error : NSError?
        let audios = audioAsset.tracksWithMediaType(AVMediaTypeAudio)
        let assetTrackAudio:AVAssetTrack = audios[0] as AVAssetTrack
        
        
        // increment it for looping the while condition
        var durationOfVideoInSec = CMTimeGetSeconds(videoAsset.duration)
        var incDurationOfAudioInSec = CMTimeGetSeconds(kCMTimeZero)
        
        // variable audio time range (it will be deserase in last repeation b/c to fit with video duration)
        var variable_audio_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        var addDurationOfAudio = kCMTimeZero
        
        
        
        if CMTimeGetSeconds(audioAsset.duration) < CMTimeGetSeconds(videoAsset.duration){
            
            // do loop here
            while incDurationOfAudioInSec < durationOfVideoInSec{
                
                // if audio duration is increases from the whole video duration then reduce the last repeate track of audio to fit with video duration
                if incDurationOfAudioInSec+CMTimeGetSeconds(audioAsset.duration) > durationOfVideoInSec{
                    let calculateTimeInSec = durationOfVideoInSec-incDurationOfAudioInSec
                    let tempDuration = CMTimeMakeWithSeconds(calculateTimeInSec, 1)
                    variable_audio_timeRange = CMTimeRangeMake(kCMTimeZero, tempDuration)
                }
                
                b_compositionAudioTrack.insertTimeRange(variable_audio_timeRange, ofTrack: assetTrackAudio, atTime: addDurationOfAudio, error: nil)
                
                // add the next starting point of the audio
                addDurationOfAudio = CMTimeAdd(addDurationOfAudio, audioAsset.duration)
                
                // increment audio duration
                incDurationOfAudioInSec += CMTimeGetSeconds(audioAsset.duration)
            }
            
            
        }
            
            // if audio duration is greater then video duration
        else if CMTimeGetSeconds(audioAsset.duration) > CMTimeGetSeconds(videoAsset.duration){
            b_compositionAudioTrack.insertTimeRange(video_timeRange, ofTrack: assetTrackAudio, atTime: kCMTimeZero, error: nil)
        }
        
        
        //Now we are creating the second AVMutableCompositionTrack containing our video and add it to our AVMutableComposition object.
        
        let a_compositionVideoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        let videos = videoAsset.tracksWithMediaType(AVMediaTypeVideo)
        let assetTrackVideo:AVAssetTrack = videos[0] as AVAssetTrack
        a_compositionVideoTrack.insertTimeRange(video_timeRange, ofTrack: assetTrackVideo, atTime: kCMTimeZero, error: nil)
        
        
        
        //define the path where you want to store the final video created with audio and video merge.
        let dirPaths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docsDir = dirPaths[0] as NSString
        
        let outputFilePath = docsDir.stringByAppendingPathComponent("\(outputVideName).mp4")
        
        let outputFileUrl = NSURL(fileURLWithPath: outputFilePath)
        
        if NSFileManager.defaultManager().fileExistsAtPath(outputFilePath){
            NSFileManager.defaultManager().removeItemAtPath(outputFilePath, error: nil)
        }
        
        
        //Now create an AVAssetExportSession object that will save your final video at specified path.
        
        let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        
        assetExport.outputFileType = "com.apple.quicktime-movie"
        assetExport.outputURL = outputFileUrl
        
        
        
        assetExport.exportAsynchronouslyWithCompletionHandler { () -> Void in
            // when export Finished
            if assetExport.status == AVAssetExportSessionStatus.Completed{
                let outputUrl = assetExport.outputURL
                let library = ALAssetsLibrary()
                
                if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(assetExport.outputURL){
                    library.writeVideoAtPathToSavedPhotosAlbum(outputUrl, completionBlock: { (url, error) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if error != nil {
                                //  println("Some error: \(error)")
                                callBack(outputUrl: nil, errorDesc: "Some error: \(error)")
                            }
                            else{
                                println("video saved")
                                
                                callBack(outputUrl: assetExport.outputURL, errorDesc: nil)
                            }
                        })
                    })
                }
            }
            
            
        }
        
        
    }
    
    
    
    
    @IBAction func btnMergeTapped(sender: UIButton) {
        
        self.activityView.hidden = false
        self.activityView.startAnimating()
        
        
        
        var docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as NSString
        
        
        println("all folder: \(NSFileManager.defaultManager().contentsOfDirectoryAtPath(docPath, error: nil))")
        
        // duration 3:14
        let videoUrl = NSBundle.mainBundle().URLForResource("Pakistan", withExtension: "mp4")
        // duration 3:28
        let videoUrl1 = NSBundle.mainBundle().URLForResource("PakInd", withExtension: "mp4")
        
        // duration 1:11
        let audioUrl = NSBundle.mainBundle().URLForResource("National", withExtension: "mp3")
        // duration 4:31
        let audioUrl1 = NSBundle.mainBundle().URLForResource("NationalSong", withExtension: "mp3")
        
        
        mergeAudiVideo(audioUrl: audioUrl1!, videoUrl: videoUrl!, outputVideName: "outputvideo11") { (outputUrl, errorDesc) -> Void in
            
            if errorDesc == nil {

                // update view on main queua(tread)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activityView.stopAnimating()
                    self.loadMoviePlayer(outputUrl!)

                })
                

            }
            else{
                println(errorDesc)
                
                // update view on main queua(tread)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activityView.stopAnimating()
                    self.lblErrorMsg.hidden = false
                    self.lblErrorMsg.text = errorDesc
                })
            }
        }
        
        


        
        
        //
        //        let player: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: videoUrl)
        //        player.view.frame = CGRectMake(0, 0, self.view.frame.width / 2, self.view.frame.height / 2)
        //        self.view.addSubview(player.view)
        //        self.presentMoviePlayerViewControllerAnimated(player)
        
    }
    
    
    
}
