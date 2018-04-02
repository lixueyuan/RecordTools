# [RecordTools](https://github.com/lixueyuan/RecordTools.git)
# 项目演示
## [DJ电音超级鼓-Super Music Pads](https://itunes.apple.com/cn/app/dj%E7%94%B5%E9%9F%B3%E8%B6%85%E7%BA%A7%E9%BC%93-super-music-pads/id1265703767?mt=8)

## 注意

### 该工具结构为
1. 总音频控制器AEAudioController
2. 音频播放器
3. 录制器

### 在音频播放器准备完毕的情况下使用
```
/**将音频播放器添加到音频控制器的通道中进行播放
*****可添加一个播放器,亦可添加多个,以NSArray的形式添加
*/
[_audioController addChannels:@[_player]];
```
### 在音频播放器使用完毕时,及时用AEAudioController中移除
```
/**当不在使用该音频播放器时,进行通道移除
*****可添加一个播放器,亦可添加多个,以NSArray的形式移除
*/
[_audioController removeChannels:@[_player]];
```
# 用法


##  初始化音频控制器

```
@property (strong, nonatomic) AEAudioController *audioController;

- (AEAudioController *)audioController {
    if (!_audioController) {
        _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:YES];
        NSError *eror;
        [_audioController start:&eror];
    }
    return  _audioController;
}
```


## 录音功能

1. 声明AERecorder对象
```
@property (strong, nonatomic) AERecorder *recorder;

```
2. 在录制的地方去初始化(这里我以录音按钮为例)
```
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

```

## 播放录制的音频

1. 声明AEAudioFilePlayer对象
```
@property (nonatomic, strong) AEAudioFilePlayer *player;

```
2. 拿到录制的音频文件播放
```
if ( _player ) {
    [_audioController removeChannels:@[_player]];
    self.player = nil;
    _playTheTapeButton.selected = NO;
} else {
    //打开沙盒路径
    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //查找刚存入的音频文件名
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
    //播放完成以后的回调
    _player.completionBlock = ^{
        ViewController *strongSelf = weakSelf;
        strongSelf->_playTheTapeButton.selected = NO;
        weakSelf.player = nil;
    };
    //将音频播放器添加到音频控制器的通道中进行播放
    [_audioController addChannels:@[_player]];

    _playTheTapeButton.selected = YES;
}

```


## 正常播放音频
1. 声明音频播放器
```
@property (nonatomic, strong) AEAudioFilePlayer *player2;
```
2. 播放本地音频(这里以我自己导入的音频文件Drum_20.mp3为例)
```
- (void)playNewSongCH1:(NSURL *)songURL {
    if (_player2) {
        [self.audioController removeChannels:@[_player2]];
        _player2 = nil;
    }

    // 创建AEAudioFilePlayer对象
    _player2 = [[AEAudioFilePlayer alloc] initWithURL:songURL error:nil];
    // 将音频播放器添加到音频控制器的通道中进行播放
    [self.audioController addChannels:@[_player2]];
    _player2.removeUponFinish = YES;
    __weak ViewController *weakSelf = self;
    //播放完成以后的回调
    _player2.completionBlock = ^{
        ViewController *strongSelf = weakSelf;
        strongSelf->_playTheTapeButton.selected = NO;
        weakSelf.player = nil;
    };
    [_audioController addChannels:@[_player2]];

    _playTheMusicButton.selected = YES;
}
```
# issue
## [随时联系我QQ](1120753616)
## [我的博客](https://blog.csdn.net/lixueyuan1995)
## [❤️Vx](18507138507)
