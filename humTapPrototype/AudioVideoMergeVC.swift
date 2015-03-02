//
//  AudioVideoMergeVC.swift
//  humTapPrototype
//
//  Created by Mohsin on 18/02/2015.
//  Copyright (c) 2015 mrazam110. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import MediaPlayer
import UIKit
import AVKit


class AudioVideoMergeVC: UIViewController ,UIImagePickerControllerDelegate,MPMediaPickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var lblAudioName: UILabel!
    @IBOutlet weak var lblVideoName: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var lblErrorMsg: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgThumbnail: UIImageView!
    
    
    let videoPicker = UIImagePickerController()
    let audioPicker = MPMediaPickerController()
    
    var audioUrl : NSURL!
    var videoUrl : NSURL!
    var outputUrl : NSURL!

    var preserveAudio = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        videoPicker.delegate = self
        audioPicker.delegate = self
        
        self.lblErrorMsg.hidden = true
        self.activityView.hidden = true
        
        self.btnPlay.hidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    
    
    
    //What to do when the picker returns with a video
    func imagePickerController(videoPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as NSString
        
        if mediaType.isEqualToString(kUTTypeImage as NSString) {
            // if Media is an image
            println("image selected")
            var chosenImage = info[UIImagePickerControllerOriginalImage] as UIImage
            dismissViewControllerAnimated(true, completion: nil)
        }
        
        else if mediaType.isEqualToString(kUTTypeMovie as NSString) {
            
            // Media is a video
            self.videoUrl = info[UIImagePickerControllerMediaURL] as NSURL
            self.lblVideoName.text = videoUrl.lastPathComponent
            dismissViewControllerAnimated(true, completion: nil)
            
            if Visualization.getDuratonInSec(self.videoUrl) > 24.0 {
                showVideoDurationAlert("Your selected video's length is grater then 24sec it will trim upto 24sec automatically", okCallBack: { () -> Void in
                    
                })
            }
        }
    }
    
    
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(videoPicker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //What to do when the mediaPicker returns with a audio
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        
        println(mediaItemCollection.count )
        println(mediaItemCollection.items[0])
        
        let theChosenAudio : MPMediaItem = mediaItemCollection.items[0] as MPMediaItem
        self.lblAudioName.text = theChosenAudio.title
        self.audioUrl = theChosenAudio.assetURL
        
        println(self.audioUrl)
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //What to do if the media picker cancels.
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func runAVPlayer(url: NSURL){
            let av = AVPlayerViewController()
             av.player =  AVPlayer(URL: url)
            self.presentViewController(av, animated: true, completion: nil)
    }
    
    
    
    //get a photo from the library. We present as a popover on iPad, and fullscreen on smaller devices.
    @IBAction func videoFromLibrary(sender: UIButton) {
        
        // show the alert for the video duration
            self.videoPicker.allowsEditing = false
            self.videoPicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            //videoPicker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            self.videoPicker.mediaTypes = [kUTTypeMovie as NSString]
            self.presentViewController(self.videoPicker, animated: true, completion: nil)
        
        
    }
    
    //take a video, check if we have a camera first.
    @IBAction func shootVideo(sender: UIButton) {
        
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            
            // show the alert for the video duration
            
            showVideoDurationAlert(nil, okCallBack: { () -> Void in

                self.videoPicker.allowsEditing = false
                self.videoPicker.sourceType = UIImagePickerControllerSourceType.Camera
                //videoPicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera)!
                self.videoPicker.mediaTypes = [kUTTypeMovie as NSString]
                self.videoPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Video
                self.videoPicker.videoMaximumDuration = 24.0
                
                self.presentViewController(self.videoPicker, animated: true, completion: nil)
                
            })
            
        } else {
            noCamera()
        }
    }
    
    
    // select audio using media picker
    @IBAction func selectAudio(sender: UIButton){
        
        audioPicker.prompt = "Select Audio"
        
        presentViewController(audioPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func defaultVideo(sender: AnyObject) {
        
        self.videoUrl = NSBundle.mainBundle().URLForResource("DemoVideo", withExtension: "mp4")
        self.lblVideoName.text = "DemoVideo.mp4"
        
        // set thumbnail image of video
        self.imgThumbnail.image = Visualization.getThumbnailOfVide(self.videoUrl)
    }
    
    
    @IBAction func defaultAudio(sender: AnyObject) {
        self.audioUrl = NSBundle.mainBundle().URLForResource("humtap", withExtension: "mp3")
        self.lblAudioName.text = "Humtap.mp3"
    }
    
    
    
    @IBAction func audioPreserve(sender: UISwitch) {
        self.preserveAudio = sender.on
    }
    
    
    @IBAction func merge(sender: AnyObject) {
        
        
        if self.audioUrl != nil && self.videoUrl != nil {
            
            self.activityView.hidden = false
            self.activityView.startAnimating()

            Visualization.mergeAudiVideo(audioUrl: self.audioUrl!, videoUrl: self.videoUrl!, outputVideName: "MergeVideo",maximumVideoDuration : 24.0, preserveAudio: self.preserveAudio) { (outputUrl, errorDesc) -> Void in
                
                if errorDesc == nil {
                    
                    // update view on main queua(tread)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.activityView.stopAnimating()
                        self.outputUrl = outputUrl
                        self.runAVPlayer(self.outputUrl!)

                        self.btnPlay.hidden = false
                        
                        // set thumbnail image of video
                        self.imgThumbnail.image = Visualization.getThumbnailOfVide(self.outputUrl)
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
        }
            
            // if no audio or video
        else{
            let alert = UIAlertController(title: "ALERT!", message: "Kindly select both audio and video", preferredStyle: UIAlertControllerStyle.Alert)
            let backAction = UIAlertAction(title: "BACK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(backAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        

    }
    
    @IBAction func play(sender: AnyObject) {
        if self.outputUrl != nil {
            // paly a merge video
            self.runAVPlayer(self.outputUrl!)

        }
        else {
            let alert = UIAlertController(title: "ALERT!", message: "Kindly merge before to play", preferredStyle: UIAlertControllerStyle.Alert)
            
            let backAction = UIAlertAction(title: "BACK", style: UIAlertActionStyle.Default, handler: nil)
            
            alert.addAction(backAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func showVideoDurationAlert(message: String?,okCallBack : () -> Void){
        let alert = UIAlertController(title: "NOTE", message: "Video duration should be not greater than 24sec, if it is then it will trim upto 24sec automatically", preferredStyle: UIAlertControllerStyle.Alert)
        
        if message != nil {
            alert.message = message!
        }
        
        
        let backAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
        _ in
          okCallBack()
        })
        
        alert.addAction(backAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }


}
