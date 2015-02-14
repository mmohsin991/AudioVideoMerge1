//
//  ViewController.swift
//  AudioVideoMerge1
//
//  Created by Mohsin on 13/02/2015.
//  Copyright (c) 2015 PanaCloud. All rights reserved.
//

import UIKit

import AVFoundation
import AssetsLibrary
import MediaPlayer

class ViewController: UIViewController {

    var moviePlayer : MPMoviePlayerController!
    
    @IBOutlet weak var vwMoviePlayer: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var videoAsset: AVURLAsset!
    var audioAsset: AVURLAsset!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.vwMoviePlayer.hidden = true
        self.activityView.hidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func mergeAndSave(){
        
        //Create AVMutableComposition Object which will hold our multiple AVMutableCompositionTrack or we can say it will hold our video and audio files.
       
        //AVMutableComposition* mixComposition = [AVMutableComposition composition];

        var mixComposition = AVMutableComposition()

        
        
        //Now first load your audio file using AVURLAsset. Make sure you give the correct path of your videos.

        //        NSURL *audio_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Asteroid_Sound" ofType:@"mp3"]];
        
        let path1 = NSBundle.mainBundle().pathForResource("National", ofType: "mp3")
        let audio_url : NSURL? = NSURL(fileURLWithPath: path1!)
        
     //   AVURLAsset  *audioAsset = [[AVURLAsset alloc]initWithURL:audio_url options:nil];
        let audioAsset = AVURLAsset(URL: audio_url, options: nil)
        let  audio_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        
        
        
        
        //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
        
 //       AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        let b_compositionAudioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
//        [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        var error : NSError?
        let audios = audioAsset.tracksWithMediaType(AVMediaTypeAudio)
        let assetTrackAudio:AVAssetTrack = audios[0] as AVAssetTrack
        b_compositionAudioTrack.insertTimeRange(audio_timeRange, ofTrack: assetTrackAudio, atTime: kCMTimeZero, error: nil)

    
        
        
        //Now we will load video file.
        
//        NSURL *video_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Asteroid_Video" ofType:@"m4v"]];
//        AVURLAsset  *videoAsset = [[AVURLAsset alloc]initWithURL:video_url options:nil];
//        CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,audioAsset.duration);

        
        let path2 = NSBundle.mainBundle().pathForResource("Pakistan", ofType: "mp4")
        
        let video_url : NSURL? = NSURL(fileURLWithPath: path2!)
        
        let videoAsset = AVURLAsset(URL: video_url, options: nil)
        
        let  video_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        
        
        
        //Now we are creating the second AVMutableCompositionTrack containing our video and add it to our AVMutableComposition object.
//        AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        
        let a_compositionVideoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
//        [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

        let videos = videoAsset.tracksWithMediaType(AVMediaTypeVideo)
        let assetTrackVideo:AVAssetTrack = videos[0] as AVAssetTrack
        a_compositionVideoTrack.insertTimeRange(video_timeRange, ofTrack: assetTrackVideo, atTime: kCMTimeZero, error: nil)

        
        
        
        
        //decide the path where you want to store the final video created with audio and video merge.
        //NSArray dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        let dirPaths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//        NSString *docsDir = [dirPaths objectAtIndex:0];
        let docsDir = dirPaths[0] as NSString
        
//NSString *outputFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"FinalVideo.mov"]];
        let outputFilePath = docsDir.stringByAppendingPathComponent("FinalVideo1.mov")
        
        
//        NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
        
        let outputFileUrl = NSURL(fileURLWithPath: outputFilePath)
        
//
//        if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
//        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];

        if NSFileManager.defaultManager().fileExistsAtPath(outputFilePath){
            NSFileManager.defaultManager().removeItemAtPath(outputFilePath, error: nil)
        }
        
        
        //Now create an AVAssetExportSession object that will save your final video at specified path.
//        AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
//        
        let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        
//        _assetExport.outputFileType = @"com.apple.quicktime-movie";
//        _assetExport.outputURL = outputFileUrl;
        
        assetExport.outputFileType = "com.apple.quicktime-movie"
        assetExport.outputURL = outputFileUrl
        
        
        
//        [_assetExport exportAsynchronouslyWithCompletionHandler:
//        ^(void ) {
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//        [self exportDidFinish:_assetExport];
//        });
//        }
//        ];
        
        assetExport.exportAsynchronouslyWithCompletionHandler { () -> Void in

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.exportDidFinish(assetExport)
            })
        }
        
        
        
        
        
    }
    
    func exportDidFinish(session: AVAssetExportSession){
        
        if session.status == AVAssetExportSessionStatus.Completed{
            let outputUrl = session.outputURL
            let library = ALAssetsLibrary()
    
            if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(session.outputURL){
                library.writeVideoAtPathToSavedPhotosAlbum(outputUrl, completionBlock: { (url, error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if error != nil {
                            println("Some error: \(error)")
                        }
                        else{
                            println("video saved")
                            self.loadMoviePlayer(session.outputURL)
                        }

                    })

                    
                })
            }
        }
        
        self.activityView.stopAnimating()
        self.activityView.hidden = true
        
    }

    
    
    func loadMoviePlayer(url: NSURL){
     
        
        self.moviePlayer = MPMoviePlayerController(contentURL: url)
        
//        self.moviePlayer.view.hidden = false
//        self.moviePlayer.view.frame = CGRectMake(0.0, 0.0, self.moviePlayer.view.frame.size.width,  self.moviePlayer.view.frame.size.height)
//        
//        self.moviePlayer.view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
//        
//        self.moviePlayer.scalingMode = MPMovieScalingMode.AspectFit
//        self.moviePlayer.fullscreen = false
//        self.moviePlayer.prepareToPlay()
//        self.moviePlayer.readyForDisplay
//        self.moviePlayer.controlStyle = MPMovieControlStyle.Embedded
//        self.moviePlayer.shouldAutoplay = false
//        self.view.addSubview(self.moviePlayer.view)
//        self.moviePlayer.view.hidden = false
        
        let player: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: url)
        player.view.frame = CGRectMake(0, 0, self.view.frame.width / 2, self.view.frame.height / 2)
        self.view.addSubview(player.view)
        self.presentMoviePlayerViewControllerAnimated(player)
        
        
    }
    
    
    
    

    @IBAction func btnMergeTapped(sender: UIButton) {
        
        self.activityView.hidden = false
        self.activityView.startAnimating()
        
        self.vwMoviePlayer.hidden = true
        
       //  mergeAndSave()
        
        
        var docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as NSString
        
        println("all folder: \(NSFileManager.defaultManager().contentsOfDirectoryAtPath(docPath, error: nil))")


        

        let videoUrl = NSBundle.mainBundle().URLForResource("Pakistan", withExtension: "mp4")
        let videoUrl1 = NSBundle.mainBundle().URLForResource("PakInd", withExtension: "mp4")
        
        let audioUrl = NSBundle.mainBundle().URLForResource("National", withExtension: "mp3")

//        
//        let player: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: audioUrl)
//        player.view.frame = CGRectMake(0, 0, self.view.frame.width / 2, self.view.frame.height / 2)
//        self.view.addSubview(player.view)
//        self.presentMoviePlayerViewControllerAnimated(player)
        
    }
    


}

