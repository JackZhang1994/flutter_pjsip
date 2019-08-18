//
//  AVSound.h
//  Runner
//
//  Created by gejianmin on 2019/8/17.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN
static AVAudioPlayer* staticAudioPlayer;

@interface AVSound : NSObject
{
    AVAudioSession* _audioSession;
}

+(instancetype)sharedInstance;

-(void)play;
-(void)playWithString:(NSString *)urlString type:(NSString *)type loop:(BOOL)isLoop;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
