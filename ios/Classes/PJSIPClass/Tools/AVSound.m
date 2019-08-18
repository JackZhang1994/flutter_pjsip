//
//  AVSound.m
//  Runner
//
//  Created by gejianmin on 2019/8/17.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "AVSound.h"

@implementation AVSound

-(instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

+(instancetype)sharedInstance{
    static AVSound *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


-(void)playWithString:(NSString *)urlString type:(NSString *)type loop:(BOOL)isLoop{
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:urlString ofType:type]];
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [_audioSession setActive:YES error:nil];
   

    if(!staticAudioPlayer){
        staticAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [staticAudioPlayer prepareToPlay];
        if (isLoop) {
            [staticAudioPlayer setNumberOfLoops:1000000];
        }
    }
}
-(void)play{
    staticAudioPlayer.volume = 10;
    if (!staticAudioPlayer.isPlaying) {
        [staticAudioPlayer play];
    }
}

-(void)stop{
    staticAudioPlayer.currentTime = 0;
    [staticAudioPlayer stop];
}

@end
