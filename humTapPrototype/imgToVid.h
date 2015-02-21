//
//  NSObject+imgToVid.h
//  imgToVideoSwift
//
//  Created by Raza Master on 13/02/2015.
//  Copyright (c) 2015 mrazam110. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface imgToVid : UIViewController
- (void)createVideo:(NSMutableArray*)imgArr andAudio:(NSString*)audioFile;

@end
