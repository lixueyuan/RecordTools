//
//  ViewController.m
//  RecordTools
//
//  Created by ios01 on 2017/8/23.
//  Copyright © 2017年 ios01. All rights reserved.
//


/*
 
 ***在一个项目中使用同一个音频控制器
 
   只在一个页面进行播放以及录制即可在当前页面创建AEAudioController对象
 
 */

#import "ViewController.h"

#import "AEAudioController.h"

#import "AERecorder.h"

@interface ViewController ()

@property (strong, nonatomic) AEAudioController *audioController;

@property (strong, nonatomic) AERecorder *recorder;

@property (nonatomic, strong) AEAudioFilePlayer *player;

@property (nonatomic, strong) AEAudioFilePlayer *player2;

@property (weak, nonatomic) IBOutlet UIButton *playTheTapeButton;
@property (weak, nonatomic) IBOutlet UIButton *playTheMusicButton;

@end

@implementation ViewController

- (AEAudioController *)audioController {
    if (!_audioController) {
        _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:YES];
        NSError *eror;
        [_audioController start:&eror];
    }
    return  _audioController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)startTheRecording:(UIButton *)sender {
    sender.selected =! sender.selected;
    if (sender.selected == YES) {
        if ( _recorder ) {
            [_recorder finishRecording];
            [self.audioController removeOutputReceiver:_recorder];
            [self.audioController removeInputReceiver:_recorder];
            self.recorder = nil;
        } else {
            self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
            NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"Recording.m4a"];
            NSError *error = nil;
            if ( ![_recorder beginRecordingToFileAtPath:path fileType:kAudioFileM4AType error:&error] ) {
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
                self.recorder = nil;
                return;
            }
            /*
             **下面两个属性方法分别为output input
             **当只加入output则不会录制手机音源意外的声音（即人声）
             **当只加入input则效果反之
             **设置两个方法即同时录制
             */
            [self.audioController addOutputReceiver:_recorder];
            [self.audioController addInputReceiver:_recorder];
        }
    }else {
        [_recorder finishRecording];
        [self.audioController removeInputReceiver:_recorder];
        [self.audioController removeOutputReceiver:_recorder];
        self.recorder = nil;
    }
}

- (IBAction)playTheMusic:(UIButton *)sender {
    sender.selected =! sender.selected;
    if (sender.selected == YES) {
        // 歌曲名和后缀名
        static NSString *audioFileName   = @"Drum_20";
        static NSString *audioFileFormat = @"mp3";
        NSURL *songURL = [[NSBundle mainBundle] URLForResource:audioFileName
                                                 withExtension:audioFileFormat];
        [self playNewSongCH1:songURL];
        
    }
}

- (IBAction)playTheTape:(UIButton *)sender {
    if ( _player ) {
        [_audioController removeChannels:@[_player]];
        self.player = nil;
        _playTheTapeButton.selected = NO;
    } else {
        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"Recording.m4a"];
        
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) return;
        
        NSError *error = nil;
        self.player = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL fileURLWithPath:path] error:&error];
        
        if ( !_player ) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[NSString stringWithFormat:@"Couldn't start playback: %@", [error localizedDescription]]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
            return;
        }
        
        _player.removeUponFinish = YES;
        __weak ViewController *weakSelf = self;
        _player.completionBlock = ^{
            ViewController *strongSelf = weakSelf;
            strongSelf->_playTheTapeButton.selected = NO;
            weakSelf.player = nil;
        };
        [_audioController addChannels:@[_player]];
        
        _playTheTapeButton.selected = YES;
    }
}

#pragma mark - 音频播放
- (void)playNewSongCH1:(NSURL *)songURL {
    if (_player2) {
        [self.audioController removeChannels:@[_player2]];
        _player2 = nil;
    }
    
    
    // 创建AEAudioFilePlayer对象
    _player2 = [[AEAudioFilePlayer alloc] initWithURL:songURL error:nil];
    // 进行播放
    [self.audioController addChannels:@[_player2]];
    _player2.removeUponFinish = YES;
    __weak ViewController *weakSelf = self;
    _player2.completionBlock = ^{
        ViewController *strongSelf = weakSelf;
        strongSelf->_playTheTapeButton.selected = NO;
        weakSelf.player = nil;
    };
    [_audioController addChannels:@[_player2]];
    
    _playTheMusicButton.selected = YES;
}
@end
