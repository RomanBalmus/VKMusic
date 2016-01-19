//
//  VideoPlayerManage.m
//  AVQueuePlayerDemo
//
//  Created by 杨争 on 9/2/14.
//  Copyright (c) 2014 ZY. All rights reserved.
//
#import <objc/runtime.h>
#import "VideoPlayerManage.h"
#import <HysteriaPlayer/HysteriaPlayer.h>


@implementation VideoPlayerManage{
    id timeObserver;
}

+ (instancetype)instance
{
    /*static VideoPlayerManage *playerManage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerManage = [[VideoPlayerManage alloc] init];
    });*/
    return nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        _playerListArray = [[NSMutableArray alloc] init];
        _metadataList = [[NSMutableArray alloc] init];

        self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithArray:self.playerListArray]];

    }
    return self;
}
- (void)setPlayerDataSourceWithURLArray:(NSArray *)urlArray
{
    /* if (self.playerListArray.count>0) {
     if (self.queuePlayer != nil && [self.queuePlayer currentItem] != nil){
     @try{
     [[self.queuePlayer currentItem] removeObserver:self forKeyPath:@"status"];
     [[self.queuePlayer currentItem] removeObserver:self forKeyPath:@"loadedTimeRanges"];
     [self.playerListArray removeObject:self.queuePlayer.currentItem];
     
     }@catch(id anException){
     //do nothing, obviously it wasn't attached because an exception was thrown
     NSLog(@"no observer do nothing");
     }
     [[NSNotificationCenter defaultCenter]removeObserver:self];
     
     }
     
     
     
     }*/
    
    for (AVPlayerItem *obj in self.playerListArray) {
        //[obj seekToTime:kCMTimeZero];
        @try{
            [obj removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
            [obj removeObserver:self forKeyPath:@"status" context:nil];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
        }
    }
    
    self.playerListArray = nil;
    //[self.queuePlayer removeAllItems];
    
    
    NSMutableArray *playerItems = [[NSMutableArray alloc]init];
    NSMutableArray *metaItems = [[NSMutableArray alloc]init];
    
    for (id item in urlArray) {
        NSDictionary*data=(NSDictionary*)item;
        [metaItems addObject:data];
        AVPlayerItem *videoItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:[data objectForKey:@"url"]]];
        [playerItems addObject:videoItem];
        
        
    }
    self.metadataList=metaItems;
    self.playerListArray = playerItems;
    
    int index = 0;
    for (id item in self.playerListArray) {
        //完成一集播放时
        index++;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFinishedPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:item ];
        
        //KVO
        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

    }
    
}
- (void)setPlayerDataSourceWithURLArrayFromLocal:(NSArray *)urlArray
{
   /* if (self.playerListArray.count>0) {
        if (self.queuePlayer != nil && [self.queuePlayer currentItem] != nil){
            @try{
                [[self.queuePlayer currentItem] removeObserver:self forKeyPath:@"status"];
                [[self.queuePlayer currentItem] removeObserver:self forKeyPath:@"loadedTimeRanges"];
                [self.playerListArray removeObject:self.queuePlayer.currentItem];

            }@catch(id anException){
                //do nothing, obviously it wasn't attached because an exception was thrown
                NSLog(@"no observer do nothing");
            }
            [[NSNotificationCenter defaultCenter]removeObserver:self];

        }
        


    }*/
    
    for (AVPlayerItem *obj in self.playerListArray) {
        //[obj seekToTime:kCMTimeZero];
        @try{
            [obj removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
            [obj removeObserver:self forKeyPath:@"status" context:nil];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
        }
    }
    
    self.playerListArray = nil;
    //[self.queuePlayer removeAllItems];
    
    
    NSMutableArray *playerItems = [[NSMutableArray alloc]init];
    NSMutableArray *metaItems = [[NSMutableArray alloc]init];

    for (id item in urlArray) {
        NSDictionary*data=(NSDictionary*)item;
        [metaItems addObject:data];
        AVPlayerItem *videoItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:[data objectForKey:@"url"]]];
        [playerItems addObject:videoItem];
     
        
    }
    self.metadataList=metaItems;
    self.playerListArray = playerItems;

    
    for (id item in self.playerListArray) {
        //完成一集播放时
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFinishedPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:item ];
        
        //KVO
        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
    }

}
- (void)setUpdatePlayerDataSourceWithURLArray:(id)item
{

    
    
  
    
   /* for (AVPlayerItem *obj in self.playerListArray) {
        
        @try{
            
            [obj removeObserver:self forKeyPath:@"status"];
            [obj removeObserver:self forKeyPath:@"loadedTimeRanges"];
            
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
            NSLog(@"no observer do nothing");
        }
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];*/

   /* if (self.playerListArray.count>0) {
        if (self.queuePlayer != nil && [self.queuePlayer currentItem] != nil){
         
            @try{
                [[self.queuePlayer currentItem] removeObserver:self forKeyPath:@"status"];
                [[self.queuePlayer currentItem] removeObserver:self forKeyPath:@"loadedTimeRanges"];
                       }@catch(id anException){
                            //do nothing, obviously it wasn't attached because an exception was thrown
                           NSLog(@"no observer do nothing");
                    }
            
            [[NSNotificationCenter defaultCenter]removeObserver:self];
           // [self.playerListArray removeAllObjects];
            
            
        }
        
        
        
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
*/
    NSDictionary * data=(NSDictionary*)item;
    [self.metadataList addObject:data];
        AVPlayerItem *videoItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:[data objectForKey:@"url"]]];
        [self.playerListArray addObject:videoItem];
        
        
    
    
    
    
  
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFinishedPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:videoItem ];
    
    
        
        //KVO
        [videoItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        [videoItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
    
}

- (void)play
{
    [self.queuePlayer play];
    if ([self.delegate respondsToSelector:@selector(vmanager:playOrPause:)]) {
        [self.delegate vmanager:self playOrPause:YES];
    }
}

- (void)pause
{
    [self.queuePlayer pause];
    if ([self.delegate respondsToSelector:@selector(vmanager:playOrPause:)]) {
        [self.delegate vmanager:self playOrPause:NO];
    }
}

- (void)playNext
{
    [self.queuePlayer advanceToNextItem];
}

- (void)playWithIndex:(NSInteger)index
{
    NSLog(@" playWithIndex: %ld",(long)index);
    self.lastItemIndex = index;
    [self.playedItems addObject:@(index)];
    [self.queuePlayer removeAllItems];
    for (NSInteger i = index; i <self.playerListArray.count; i ++) {
        AVPlayerItem* obj = [self.playerListArray objectAtIndex:i];
        if ([self.queuePlayer canInsertItem:obj afterItem:nil]) {
            [obj seekToTime:kCMTimeZero];
            [self.queuePlayer insertItem:obj afterItem:nil];
            [self play];
        }
    }
}
- (void)playPrevious
{
    NSInteger nowIndex = [self.playerListArray indexOfObject:self.queuePlayer.currentItem];
    if (nowIndex == 0)
    {
        [self playWithIndex:self.playerListArray.count - 1];

    } else {
        [self playWithIndex:(nowIndex -1)];
    }
}

-(void)removeItemAtIndex:(NSInteger )index{
    AVPlayerItem *item = (AVPlayerItem*)[self.playerListArray objectAtIndex:index];
    [self.playerListArray removeObjectAtIndex:index];
    [self.queuePlayer removeItem:item];

}

/*- (void)updateStatus:(AVPlayerItem *)playerItem
{
    self.timeObserver = [[VideoPlayerManage instance].queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat timeDuration = CMTimeGetSeconds(playerItem.duration);
        CGFloat timeCurrent = CMTimeGetSeconds(playerItem.currentTime);
        [self.slider setMaximumValue:timeDuration];
        [self.slider setValue:timeCurrent animated:YES];
        _timeLabel.text = [NSString stringWithFormat:@"%d/%d",(int)timeCurrent,(int)timeDuration];
    }];
}*/

- (NSTimeInterval)availableDuration:(AVPlayerItem *)item {
    NSArray *loadedTimeRanges = [item loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
    CGFloat result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)itemDidFinishedPlaying:(NSNotification *)notif
{

    NSLog(@" itemDidFinishedPlaying");
   
    
   // [[NSNotificationCenter defaultCenter]postNotificationName:@"songChanged" object:self userInfo:@{@"index":[NSNumber numberWithInteger:index],@"url":[[self.musicList objectAtIndex:index]objectForKey:@"url"] }];
    
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"PopupDismiss" object:self ];
    
    
   // NSNotificationCenter.defaultCenter().addObserver(self, selector: "popUpProgress:", name:"PopupProgress", object: nil)
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
           // NSLog(@"可以播放了 = %@",self.timeObserver);
            
            CGFloat timeDuration = CMTimeGetSeconds(playerItem.duration);
            CGFloat timeCurrent = CMTimeGetSeconds(playerItem.currentTime);
          //  [self.slider setMaximumValue:timeDuration];
           // [self.slider setValue:timeCurrent animated:YES];
            
            NSLog(@"time duration/current %f / %f",timeDuration,timeCurrent);
           // NSLog(@"intex: %lu",(unsigned long)[self.playerListArray indexOfObject:object]);
            AVAsset *currentPlayerAsset = playerItem.asset;
            NSLog(@"playing?: %d",self.queuePlayer.rate>0);
            if(self.queuePlayer.rate>0){
               
                [self setNowPlayingInfo:[self.playerListArray indexOfObject:object]];

                NSInteger ix=[self.playerListArray indexOfObject:object];
                NSDictionary *metadata = [self.metadataList objectAtIndex:ix];
                if ([self.delegate respondsToSelector:@selector(vmanager:playerItem:andInfo:)]) {
                    [self.delegate vmanager:self playerItem:playerItem andInfo:metadata];
                }
                
            /*[[NSNotificationCenter defaultCenter]postNotificationName:@"songChanged" object:self userInfo:@{@"artist":[metadata objectForKey:@"artist"],@"duration":[NSNumber numberWithFloat:timeDuration],@"title":[metadata objectForKey:@"title"],@"index":[NSNumber numberWithInteger:[self.playerListArray indexOfObject:object]],@"url":[(AVURLAsset *)currentPlayerAsset URL] }];*/
                
                __block VideoPlayerManage *blockSelf = self;
               
                if (timeObserver!=nil) {
                    [self.queuePlayer removeTimeObserver:timeObserver];
                    timeObserver=nil;
                }
                if ( timeObserver == nil ) {
                    timeObserver = [self.queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(100, 1000)
                                                                                                  queue:NULL // main queue
                                                                                             usingBlock:^(CMTime time) {
                                                                                                 double duration = CMTimeGetSeconds(playerItem.duration);
                                                                                                 double times = CMTimeGetSeconds(playerItem.currentTime);
                                                                                                // NSLog(@"total duration: %f",duration);
                                                                                                 if ([blockSelf.delegate respondsToSelector:@selector(vmanager:updateProgress:currentTime:)]) {
                                                                                                     [blockSelf.delegate vmanager:blockSelf updateProgress:(CGFloat) (times / duration) currentTime:times];
                                                                                                 }
                                                                                             }];
                }
            
            }
            //[[[VideoPlayerManage instance] queuePlayer] removeTimeObserver:self.timeObserver];
           // self.timeObserver = nil;
           // [self updateStatus:playerItem];
            
         
        }
        
        
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        CGFloat availableTime = [self availableDuration:playerItem];
        CGFloat durationTime = CMTimeGetSeconds(playerItem.duration);
       // [self.progressView setProgress:availableTime / durationTime animated:NO];
        
        NSLog(@"progress: %f",availableTime / durationTime);
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"PopupProgress" object:self userInfo:@{@"availableTime":[NSNumber numberWithFloat: availableTime],@"durationTime":[NSNumber numberWithFloat: durationTime] }];

    }
}

-(void)setNowPlayingInfo:(NSInteger)currentInx{
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSDictionary *metadata = [self.metadataList objectAtIndex:currentInx];

      
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
       // MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"play"]];
        
        [songInfo setObject:[metadata objectForKey: @"title"] forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:[metadata objectForKey:@"artist"] forKey:MPMediaItemPropertyArtist];
       // [songInfo setObject:[metadata objectForKey:@"album"] forKey:MPMediaItemPropertyAlbumTitle];
       // [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
       // NSLog(@"my metadata: %@",songInfo);
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
    }
    
}
-(void)setNowPlayingInfoDictionary:(NSDictionary*)metadata{
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        // MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"play"]];
        
        [songInfo setObject:[metadata objectForKey: @"title"] forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:[metadata objectForKey:@"artist"] forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:[NSNumber numberWithFloat: [[HysteriaPlayer sharedInstance]getPlayingItemDurationTime ]] forKey:MPMediaItemPropertyPlaybackDuration];
        // [songInfo setObject:[metadata objectForKey:@"album"] forKey:MPMediaItemPropertyAlbumTitle];
        // [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        // NSLog(@"my metadata: %@",songInfo);
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
    }
    
}
@end
