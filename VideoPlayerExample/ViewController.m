//
//  ViewController.m
//  VideoPlayerExample
//
//  Created by Yongliang Wang on 1/30/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import "ViewController.h"
#import "VIMVideoPlayer.h"
#import "VIMVideoPlayerView.h"

@interface ViewController ()<VIMVideoPlayerViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) VIMVideoPlayerView *videoPlayerView;
@property(nonatomic, assign) CGRect originFrame;
@property(nonatomic, assign) BOOL isFullscreenMode;

@property(nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Test";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.videoPlayerView = [[VIMVideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame)*9/16)];
    self.videoPlayerView.delegate = self;
    
    [self.videoPlayerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    [self.videoPlayerView.player enableTimeUpdates];
    [self.videoPlayerView.player enableAirplay];
    
    [self.view addSubview:self.videoPlayerView];
    
    //    http://devstreaming.apple.com/videos/wwdc/2015/1014o78qhj07pbfxt9g7/101/hls_vod_mvp.m3u8
    //    http://www.eapple.com.cn/video/eapple/playlist.m3u8
    [self.videoPlayerView.player setURL:[NSURL URLWithString:@"http://devstreaming.apple.com/videos/wwdc/2015/1014o78qhj07pbfxt9g7/101/hls_vod_mvp.m3u8"]];
    [self.videoPlayerView.player play];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.videoPlayerView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.videoPlayerView.frame)) style:UITableViewStyleGrouped];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)){
        self.originFrame = self.videoPlayerView.frame;
        self.videoPlayerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        self.isFullscreenMode = YES;
        
    }else if(UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){
        self.videoPlayerView.frame = self.originFrame;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        self.isFullscreenMode = NO;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"%@", NSStringFromCGSize(size));
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if(! self.isFullscreenMode){
            self.originFrame = self.videoPlayerView.frame;
            self.videoPlayerView.frame = [[UIApplication sharedApplication].keyWindow frame];
        }else{
            self.videoPlayerView.frame = self.originFrame;
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if(! self.isFullscreenMode){
            self.isFullscreenMode = YES;
            [self.videoPlayerView removeFromSuperview];
            
            [[UIApplication sharedApplication].keyWindow addSubview:self.videoPlayerView];
        }else{
            self.isFullscreenMode = NO;
            [self.videoPlayerView removeFromSuperview];
            [self.view addSubview:self.videoPlayerView];
            
        }
    }];
}

- (void)videoPlayerViewWantsFullscreen:(VIMVideoPlayerView *)videoPlayerView
{
    NSNumber *value = @(UIInterfaceOrientationLandscapeLeft);
    if(self.isFullscreenMode){
        value = @(UIInterfaceOrientationPortrait);
    }
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscape|UIInterfaceOrientationMaskPortrait;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Test text %ld", (long)indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}
@end
