//
//  VisualizationAPI.swift
//  humTapPrototype
//
//  Created by Mohsin on 18/02/2015.
//  Copyright (c) 2015 mrazam110. All rights reserved.
//

import AVFoundation
import AssetsLibrary
import MediaPlayer

class Visualization {
    
    class func mergeAudiVideo(#audioUrl: NSURL, videoUrl : NSURL, outputVideName: String, maximumVideoDuration: Float, preserveAudio: Bool, callBack : (outputUrl: NSURL? , errorDesc: String?)->Void){
        var mixComposition = AVMutableComposition()
        
        
        //first load your audio file using AVURLAsset, Make sure you give the correct path of your videos.
        let audioAsset = AVURLAsset(URL: audioUrl, options: nil)
        let  audio_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        
        
        //Now we will load video file.
        let videoAsset = AVURLAsset(URL: videoUrl, options: nil)
        
        var durationOfVideoInSec = Float64(maximumVideoDuration)
        // if the duration of video is less then 24 sec then update the duration of video
        if durationOfVideoInSec > CMTimeGetSeconds(videoAsset.duration) {
            durationOfVideoInSec = CMTimeGetSeconds(videoAsset.duration)
        }

        let  video_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(durationOfVideoInSec, 1))
        
        
        //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
        
        let b_compositionAudioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        var error : NSError?
        let audios = audioAsset.tracksWithMediaType(AVMediaTypeAudio)
        let assetTrackAudio:AVAssetTrack = audios[0] as AVAssetTrack
        
        
        // increment it for looping the while condition
        var incDurationOfAudioInSec = CMTimeGetSeconds(kCMTimeZero)
        
        // variable audio time range (it will be deserase in last repeation b/c to fit with video duration)
        var variable_audio_timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        var addDurationOfAudio = kCMTimeZero
        
        
        
        if CMTimeGetSeconds(audioAsset.duration) < durationOfVideoInSec{
            
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
        else if CMTimeGetSeconds(audioAsset.duration) > durationOfVideoInSec{
            b_compositionAudioTrack.insertTimeRange(video_timeRange, ofTrack: assetTrackAudio, atTime: kCMTimeZero, error: nil)
            
        }
        
        //Now we are creating the second AVMutableCompositionTrack containing our video and add it to our AVMutableComposition object.
        
        let a_compositionVideoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        let videos = videoAsset.tracksWithMediaType(AVMediaTypeVideo)
        let assetTrackVideo:AVAssetTrack = videos[0] as AVAssetTrack
        a_compositionVideoTrack.insertTimeRange(video_timeRange, ofTrack: assetTrackVideo, atTime: kCMTimeZero, error: nil)
        
        
        // if the user preserve the audio of the real video
        if preserveAudio{
            let a_compositionAudioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            let audiosTemp = videoAsset.tracksWithMediaType(AVMediaTypeAudio)
            let assetTrackAudioTemp:AVAssetTrack = audiosTemp[0] as AVAssetTrack
            a_compositionAudioTrack.insertTimeRange(video_timeRange, ofTrack: assetTrackAudioTemp, atTime: kCMTimeZero, error: nil)
            
        }
        
        
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
        
        // slow down the  humtap music sound in last 2 seconds
        let params = AVMutableAudioMixInputParameters(track:b_compositionAudioTrack)
        
        // set the volume of the humtap music
        let volume: Float  = 0.4
        params.setVolume(volume, atTime:CMTimeMakeWithSeconds(0,1))
        let timeStart = CMTimeMakeWithSeconds(durationOfVideoInSec - 2.0, 1)
        let timeDuration = CMTimeMakeWithSeconds(2.0, 1)
        params.setVolumeRampFromStartVolume( volume, toEndVolume:0, timeRange:CMTimeRangeMake(timeStart,timeDuration))
        let mix = AVMutableAudioMix()
        mix.inputParameters = [params]
        
        
        assetExport.audioMix = mix
        
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
    
    
    class func getDuratonInSec(url : NSURL) -> Float{
        
        let tempAsset = AVURLAsset(URL: url, options: nil)
        
        return Float(CMTimeGetSeconds(tempAsset.duration))
        
    }
    
    class func getThumbnailOfVide(videoUrl: NSURL) -> UIImage?{
        
        let asset: AVAsset = AVAsset.assetWithURL(videoUrl) as AVAsset
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        // take the snapshoot of the middle duration of video
        let timeInSec = CMTimeGetSeconds(asset.duration)/2
        
        let time = CMTimeMakeWithSeconds(timeInSec, 1)
        
        var error : NSError?
        let myImage = imageGenerator.copyCGImageAtTime(time, actualTime: nil, error: &error)
        
        if myImage != nil {
            return UIImage(CGImage: myImage!)
        }

        return nil
    }
    
    
}