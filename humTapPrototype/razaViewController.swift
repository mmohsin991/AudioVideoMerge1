//
//  razaViewController.swift
//  humTapPrototype
//
//  Created by Raza Master on 18/02/2015.
//  Copyright (c) 2015 mrazam110. All rights reserved.
//

import UIKit
import MediaPlayer

class razaViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var player = MPMoviePlayerViewController()
    var imgArr:[UIImage] = []
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var collectView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgArr.append(UIImage(named: "IMG_0476"))
        imgArr.append(UIImage(named: "IMG_0475"))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        indicator.hidden = true
        collectView.reloadData()
        println(imgArr)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showActionSheet(sender: AnyObject) {
        let optionsMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Cancelled")
        })
        
        optionsMenu.addAction(cancelAction)
        
        self.presentViewController(optionsMenu, animated: true, completion: nil)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = self.collectView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as myCollectionViewCell
        
        cell.imgView.image = imgArr[indexPath.row]
        cell.backgroundColor = UIColor.redColor()
        
        return cell
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        //If the device has a camera, take a picture, otherwise,
        //just pick from photo library
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        }else{
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        imagePicker.delegate = self
        
        //Place image picker on the Screen
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        
        //Get picked image from info dictionary
        var image = info[UIImagePickerControllerOriginalImage] as UIImage
        
        //Put that image onto the screen in our image view
        //var imageObbj:UIImage! = self.imageResize(image, sizeChange: CGSizeMake(400, 533))
        
        imgArr.append(image)
        imagePicker.allowsEditing = true
        
        //Take image picker off the screen
        // you must call this dismiss method
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }*/
    
    @IBAction func playVideo(sender: AnyObject) {
        indicator.hidden = false
        indicator.startAnimating()
        
        if imgArr.count != 0 {
            var imgVid = imgToVid()
            imgVid.createVideo(NSMutableArray(array: imgArr), andAudio: "pakistan.mp3")
            
            NSThread.sleepForTimeInterval(4)
            
            var docDir = NSHomeDirectory().stringByAppendingPathComponent("Documents")
            var vid = docDir.stringByAppendingPathComponent("final_video.mp4")
            
            player = MPMoviePlayerViewController(contentURL: NSURL(fileURLWithPath: vid))
            self.presentMoviePlayerViewControllerAnimated(player)
        }else{
            UIAlertView(title: "No Image", message: "Add Image from Camera Button", delegate: self, cancelButtonTitle: "OK").show()
        }
        
    }
}
