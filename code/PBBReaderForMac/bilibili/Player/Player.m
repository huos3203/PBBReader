//
//  Player.m
//  bilibili
//
//  Created by TYPCN on 2016/3/3.
//  Copyright © 2016 TYPCN. All rights reserved.
//

#import "Player.h"
#import "PlayerManager.h"
#import <MuPDFFramework/MuPDFFramework.h>
//#import "MuPDFFramework.h"

@implementation Player{
    NSMutableDictionary *attrs;
    mpv_handle *mpv_handle_var;
}

@synthesize view;
@synthesize windowController;

- (id)init{
    [NSException raise:@"NoVideoError" format:@"You must init player with video"];
    return NULL;
}

- (id)initWithVideo:(VideoAddress *)m_video attrs:(NSDictionary *)dict{
    self = [super init];
    if(self){
        self.video = m_video;
        if(dict){
            attrs = [dict mutableCopy];
        }else{
            attrs = [[NSMutableDictionary alloc] init];
        }
        
        NSString *queue_name = [NSString stringWithFormat:@"player_queue_%ld",time(0)];
        self.queue = dispatch_queue_create([queue_name UTF8String], DISPATCH_QUEUE_SERIAL);
        //这样，必须保证文件名字正确，视频文件名不能存在.pdf字样
        BOOL isPDF = [[self.video.firstFragmentURL lowercaseString] containsString:@".pdf"];
        if (isPDF)
        {
            //PDF
            NSBundle *muBundle = [NSBundle bundleForClass:MuPDFViewController.self];
            NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"muPDF" bundle:muBundle];
            windowController = [storyBoard instantiateControllerWithIdentifier:@"playerWindow"];
            MuPDFViewController *muPDF = (MuPDFViewController *)windowController.contentViewController;
            //测试文件来源
            //NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"Manual" ofType:@"pdf"];
            //正式文件来源
            NSString *pdfPath = self.video.firstFragmentURL;
            muPDF.openfilepath = pdfPath;
            
            //当mupdf播放器被关闭时
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(ReleasePlayerWindows:)
                                                         name:@"ReleasePlayerWindows"
                                                       object:nil];
        }
        else
        {
            //视频
            NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
            windowController = [storyBoard instantiateControllerWithIdentifier:@"playerWindow"];
            view = (PlayerView *)windowController.contentViewController;
            [view loadWithPlayer:self];
        }
        
        [windowController showWindow:self];
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    }
    
    return self;
}

-(void)ReleasePlayerWindows:(NSNotification *)notification
{
    NSLog(@"--PlayerWindow destory---");
    [self destory];
}

- (id)getAttr:(NSString *)key{
    return attrs[key];
}

- (void)setAttr:(NSString *)key data:(id)data{
    attrs[key] = data;
}

- (void)stopAndDestory{
    [windowController.window performClose:self];
    view = nil;
    windowController = nil;
    [[PlayerManager sharedInstance] removePlayer:self];
}

- (void)destory{
    [[PlayerManager sharedInstance] removePlayer:self];
    view = nil;
    windowController = nil;
}

- (void)dealloc{
    NSLog(@"[Player] Dealloc player %@",self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
