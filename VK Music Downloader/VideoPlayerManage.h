//
//  VideoPlayerManage.h
//  AVQueuePlayerDemo
//
//  Created by 杨争 on 9/2/14.
//  Copyright (c) 2014 ZY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@class VideoPlayerManage;
@protocol VideoPlayerManageDelegate <NSObject>
@optional
-(void)vmanager:(VideoPlayerManage*)vmanager newStart:(AVPlayerItem*)param;
-(void)vmanager:(VideoPlayerManage*)vmanager updateProgress:(CGFloat)param currentTime:(CGFloat)currentTime;
-(void)vmanager:(VideoPlayerManage*)vmanager playerItem:(AVPlayerItem*)playerItem andInfo:(NSDictionary*)info;
-(void)vmanager:(VideoPlayerManage*)vmanager playOrPause:(BOOL)playOrPause;

@end
@interface VideoPlayerManage : NSObject

@property (strong, nonatomic) AVQueuePlayer *queuePlayer;
@property (strong, nonatomic) NSMutableArray *playerListArray;
@property (strong, nonatomic) NSMutableArray *metadataList;
@property (nonatomic, weak) id <VideoPlayerManageDelegate> delegate;
@property (nonatomic) NSInteger lastItemIndex;

@property (nonatomic, strong) NSMutableSet *playedItems;

/**
 *  单例
 *
 *  @return id
 */
+ (instancetype)instance;

/**
 *  初始化Player的数据源
 *
 *  @param urlArray url数组,存NSString类型
 */
- (void)setPlayerDataSourceWithURLArray:(NSArray *)urlArray;

- (void)setUpdatePlayerDataSourceWithURLArray:(id)item;
- (void)setPlayerDataSourceWithURLArrayFromLocal:(NSArray *)urlArray;
- (void)removeItemAtIndex:(NSInteger )index;
-(void)setNowPlayingInfoDictionary:(NSDictionary*)metadata;

/**
 *  播放下一集
 */
- (void)playNext;
- (void)playPrevious;

/**
 *  播放某一集
 *
 *  @param index 某集的序号
 */
- (void)playWithIndex:(NSInteger)index;

/**
 *  播放
 */
- (void)play;

/**
 *  暂停
 */
- (void)pause;


@end
