/*
     File: DataViewController.m
 Abstract: The app's view controller which presents viewable content.
  Version: 3.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "DataViewController.h"
#import "PDFScrollView.h"
#import "TiledPDFView.h"

@interface DataViewController ()
{
    NSArray *_selections;
}

@end

@implementation DataViewController

@synthesize _searchData;

-(void) dealloc {
    if( self.page != NULL ) CGPDFPageRelease( self.page );
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.page = CGPDFDocumentGetPage( self.pdf, self.pageNumber );
    NSLog(@"self.page==NULL? %@",self.page==NULL?@"yes":@"no");

    if( self.page != NULL )
        CGPDFPageRetain( self.page );
    
    //在srollview中加载pdf页面
    [self.scrollView setPDFPage:self.page];
}

-(void)viewWillAppear:(BOOL)animated {
    // Disable zooming if our pages are currently shown in landscape
    if( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
        [self.scrollView setUserInteractionEnabled:YES];
    } else {
        [self.scrollView setUserInteractionEnabled:NO];
    }
    NSLog(@"%s scrollView.zoomScale=%f",__PRETTY_FUNCTION__,self.scrollView.zoomScale);
}

//每次更新UI,都调用该方法
-(void)viewDidLayoutSubviews {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSLog(@"%s",__PRETTY_FUNCTION__);
        if (IS_LANDSCAPE) {
            [self restoreScale];
        }
        
    }
    
    if (_searchData) {
        [self restSearchResultColor:_searchData];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if( fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
        [self.scrollView setUserInteractionEnabled:NO];
    } else {
        [self.scrollView setUserInteractionEnabled:YES];
    }
}

//iPad双页面
-(void)restoreScale {
    // Called on orientation change.
    // We need to zoom out and basically reset the scrollview to look right in two-page spline view.
    CGRect pageRect = CGPDFPageGetBoxRect( self.page, kCGPDFMediaBox );
    CGFloat yScale = self.view.frame.size.height/pageRect.size.height;
    CGFloat xScale = self.view.frame.size.width/pageRect.size.width;
    self.myScale = MIN( xScale, yScale );
    NSLog(@"%s self.myScale=%f",__PRETTY_FUNCTION__, self.myScale);
    self.scrollView.bounds = self.view.bounds;
    self.scrollView.zoomScale = 1.0;
    self.scrollView.PDFScale = self.myScale;
    self.scrollView.tiledPDFView.bounds = self.view.bounds;
    self.scrollView.tiledPDFView.myScale = self.myScale;
    [self.scrollView.tiledPDFView.layer setNeedsDisplay];
}


//搜索结果着色
-(void)restSearchResultColor:(NSString *)searchStr
{
    //获取当前搜索界面
    TiledPDFView *tileView = self.scrollView.tiledPDFView;
    //获取搜索到的内容数组
    if (searchStr) {
        _selections = [tileView.scanner select:searchStr];
    }else{
        _selections= nil;
    }
    [tileView setSelections:_selections];
    //重绘当前页面，给搜索数据着色
    [tileView.layer setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
