//
//  FileViewController.m
//  PBB
//
//  Created by Fairy on 14-5-29.
//  Copyright (c) 2014年 pyc.com.cn. All rights reserved.
//

#import "FileViewController.h"
#import "AppDelegate.h"
#import "ModelController.h"
#import "DataViewController.h"
#import "MyOutLineViewController.h"
#import "PDFParser.h"
#import "BookmarkViewController.h"


#define FPK_REUSABLE_VIEW_NONE 0
#define FPK_REUSABLE_VIEW_SEARCH 1
#define FPK_REUSABLE_VIEW_TEXT 2
#define FPK_REUSABLE_VIEW_OUTLINE 3
#define FPK_REUSABLE_VIEW_BOOKMARK 4



static const NSInteger FPKReusableViewNone = FPK_REUSABLE_VIEW_NONE;
static const NSInteger FPKReusableViewSearch = FPK_REUSABLE_VIEW_SEARCH;
static const NSInteger FPKReusableViewText = FPK_REUSABLE_VIEW_TEXT;
static const NSInteger FPKReusableViewOutline = FPK_REUSABLE_VIEW_OUTLINE;
static const NSInteger FPKReusableViewBookmarks = FPK_REUSABLE_VIEW_BOOKMARK;




#define FPK_SEARCH_VIEW_MODE_MINI 0
#define FPK_SEARCH_VIEW_MODE_FULL 1

static const NSInteger FPKSearchViewModeMini = FPK_SEARCH_VIEW_MODE_MINI;
static const NSInteger FPKSearchViewModeFull = FPK_SEARCH_VIEW_MODE_FULL;


@interface FileViewController ()

@property (readonly, strong, nonatomic) ModelController *modelController;

@end

@implementation FileViewController
{
    NSString *_loginName;
    NSTimer *_myTimer;
    NSInteger _nums;
    NSInteger _x;
    NSInteger _y;

    NSUInteger currentReusableView;         // This flag is used to keep track of what alternate controller is displayed to the user
    NSUInteger currentSearchViewMode;
}

@synthesize modelController = _modelController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _pdfDocument = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"Manual1.pdf"];
//    _pdfDocument = [[NSBundle mainBundle] pathForResource:@"input_pdf" ofType:@"pdf"];
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    //获取阅读的历史记录
    NSInteger pageNum = [[NSUserDefaults standardUserDefaults] integerForKey:FPK_READHISTORY_PAGENUM(_receviveFileId)];
    DataViewController *startingViewController = [self.modelController viewControllerAtIndex:pageNum storyboard:self.storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    self.pageViewController.dataSource = self.modelController;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//            pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
//        }
    
    self.pageViewController.view.frame = pageViewRect;
    [self.pageViewController didMoveToParentViewController:self];
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.pdfView.gestureRecognizers = self.pageViewController.gestureRecognizers;
	// Do any additional setup after loading the view.
    
    _loginName = [[userDao shareduserDao] getLogName];
    
    // 限制剩余时间操作
        _nums = _limitTime;
        if (_nums!=0) {
            _ibTimeView.hidden = NO;
            // 设置时间提醒标签
            CGFloat width = kScreenWidth;
            if (IS_LANDSCAPE) {
                width = kScreenHeight;
            }
            
            _x = _nums / 60;
            _y = _nums % 60;
            _myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerwithTimesNums) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_myTimer forMode:NSRunLoopCommonModes];
        }
    
    
    //searchBar去除背景
    [[[[ _ibSearchBar.subviews objectAtIndex :0] subviews] objectAtIndex:0] removeFromSuperview];
    [_ibSearchBar setBackgroundColor:[UIColor clearColor]];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
}



- (void)timerwithTimesNums
{
    if (_y<0) {
        _x--;
        _y = 60;
    }
    
    if (_x == 0) {
        _ibTimeLabel.text = [NSString stringWithFormat:@"%ld秒",(long)_y--];
        if (_y < 10) {
            _ibTimeView.backgroundColor = [UIColor redColor];
            _ibTimeView.alpha = 0.3;
            if (_y < 0) {
                [self dismissAlternateViewController];
                [self back:nil];
                [_myTimer invalidate];
            }
        }
        
    } else {
        _ibTimeLabel.text = [NSString stringWithFormat:@"%ld分%ld秒",(long)_x,(long)_y--];
    }
    
}

- (ModelController *)modelController
{
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[ModelController alloc] initWithPDFPath:_pdfDocument];
    }
    
    return _modelController;
}

- (IBAction)ibBarBack:(id)sender {
    [self back:nil];
}

- (void)back:(UIBarButtonItem *)barItem{
    
    //删除明文文件
//    NSFileManager *manager = [NSFileManager defaultManager];
//    [manager removeItemAtPath:_filePath error:nil];
    //不读时，记录当前页面
    [[NSUserDefaults standardUserDefaults] setInteger:[self pageNum] forKey:FPK_READHISTORY_PAGENUM(_receviveFileId)];
    
    [_myTimer invalidate];
    [self.navigationController pushViewController:detailView animated:YES];

}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UIPageViewController delegate methods

/*
 - (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
 {
 
 }
 */

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        //竖屏时，或iPhone上，return UIPageViewControllerSpineLocationMin；
        //pageViewController数组中，仅有一个页面显示，所以 doubleSided 赋值NO
        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
        NSArray *viewControllers = @[currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }
    
    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    //横屏时，return UIPageViewControllerSpineLocationMid；
    //pageViewController数组中有两个VC页面
    //如果显示的是偶数页，那么就同时显示当前页面和下一个相邻的页面
    //如果显示的是奇数页，就同时显示前一个相邻的页面，和当前页面。
    DataViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = nil;
    
    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController
                                                      viewControllerAfterViewController:currentViewController];
        
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController
                                                         viewControllerBeforeViewController:currentViewController];
        
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:NULL];
    
    
    return UIPageViewControllerSpineLocationMid;
}


- (IBAction)ibaOutline:(UIButton *)sender {
    
    MyOutLineViewController *outlineVC = nil;
    
    if (currentReusableView != FPK_REUSABLE_VIEW_OUTLINE) {
        
        currentReusableView = FPK_REUSABLE_VIEW_OUTLINE;
        outlineVC = [[MyOutLineViewController alloc] init];
        [[NSBundle mainBundle] loadNibNamed:@"OutlineView" owner:outlineVC options:nil];
        [outlineVC setDelegate:self];
        
        // We set the inital entries, that is the top level ones as the initial one. You can save them by storing
        // this array and the openentries array somewhere and set them again before present the view to the user again.
//        PDFParser *pdf = [[PDFParser alloc] initWithFileName:_pdfDocument];
        PDFParser *pdf = [[PDFParser alloc] initWithPDFDoc:_modelController.pdf];
        [outlineVC setOutlineEntries:[[pdf getPDFContents] mutableCopy]];
        
        CGSize popoverContentSize = CGSizeMake(372, 530);
        
        UIView * sourceView = self.view;
        CGRect sourceRect = [self.view convertRect:sender.bounds fromView:sender];
        
        [self presentViewController:outlineVC fromRect:sourceRect sourceView:sourceView contentSize:popoverContentSize];
        
        //		[outlineVC release];
        
    } else {
        
        [self dismissAlternateViewController];
        
    }
}


-(void)dismissAlternateViewController {
    
    // This is just an utility method that will call the appropriate dismissal procedure depending
    // on which alternate controller is visible to the user.
    
    switch(currentReusableView) {
            
        case FPKReusableViewNone:
            break;
            
        case FPKReusableViewText:
            
            if(self.presentedViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
            currentReusableView = FPKReusableViewNone;
            
            break;
            
        case FPKReusableViewOutline:
        case FPKReusableViewBookmarks:
            
            // Same procedure for both outline and bookmark.
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                
#ifdef __IPHONE_8_0
                if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
                {
                    if(self.presentedViewController) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
                else
#endif
                {
                    
                    [_reusablePopover dismissPopoverAnimated:YES];
                }
                
            } else {
                
                /* On iPad iOS 8 and iPhone whe have a presented view controller */
                
                if(self.presentedViewController) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
            currentReusableView = FPKReusableViewNone;
            break;
            
        case FPKReusableViewSearch:
            
            if(currentSearchViewMode == FPKSearchViewModeFull) {
                
                //                [searchManager cancelSearch];
                //                [self dismissSearchViewController:searchViewController];
                currentReusableView = FPKReusableViewNone;
                
            } else if (currentSearchViewMode == FPKSearchViewModeMini) {
                //                [searchManager cancelSearch];
                //                [self dismissMiniSearchView];
                currentReusableView = FPKReusableViewNone;
            }
            
            // Cancel search and remove the controller.
            
            break;
        default: break;
    }
}

-(void)presentViewController:(UIViewController *)controller fromRect:(CGRect)rect sourceView:(UIView *)view contentSize:(CGSize)contentSize {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
#ifdef __IPHONE_8_0
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            
            controller.modalPresentationStyle = UIModalPresentationPopover;
            
            UIPopoverPresentationController * popoverPresentationController = controller.popoverPresentationController;
            
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popoverPresentationController.sourceRect = rect;
            popoverPresentationController.sourceView = view;
            popoverPresentationController.delegate = self;
            
            [self presentViewController:controller animated:YES completion:nil];
            
        } else
#endif
        {
            
            [self prepareReusablePopoverControllerWithController:controller];
            
            [_reusablePopover setPopoverContentSize:contentSize animated:YES];
            [_reusablePopover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        
    } else {
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(UIPopoverController *)prepareReusablePopoverControllerWithController:(UIViewController *)controller {
    
    UIPopoverController * popoverController = nil;
    
    if(!_reusablePopover) {
        
        popoverController = [[UIPopoverController alloc]initWithContentViewController:controller];
        popoverController.delegate = self;
        self.reusablePopover = popoverController;
        self.reusablePopover.delegate = self;
        
    } else {
        
        [_reusablePopover setContentViewController:controller animated:YES];
    }
    
    return _reusablePopover;
}

-(void)dismissMyOutlineViewController:(MyOutlineViewController *)ovc
{
    [self dismissAlternateViewController];
}


-(void)myOutlineViewController:(MyOutlineViewController *)ovc didRequestPage:(NSUInteger)page
{

    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (UIInterfaceOrientationIsPortrait(ORIENTATION) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        self.pageViewController.doubleSided = NO;
        DataViewController *startingViewController = [self.modelController viewControllerAtIndex:page-1 storyboard:self.storyboard];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        [self dismissAlternateViewController];
        return;
    }
    
    DataViewController *currentViewController = [self.modelController viewControllerAtIndex:page-1 storyboard:self.storyboard];
    NSArray *viewControllers = nil;
    
    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    

    [self dismissAlternateViewController];
}
-(void)myOutlineViewController:(MyOutlineViewController *)ovc didRequestPage:(NSUInteger)page file:(NSString *)file
{
    
}
-(void)myOutlineViewController:(MyOutlineViewController *)ovc didRequestDestination:(NSString *)destinationName file:(NSString *)file
{
    
}


#pragma mark UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self DoSearch:[searchBar text]];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self DoSearch:[searchBar text]];
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _ibSearchBar.hidden = YES;
    [self DoSearch:@""];
    [_ibSearchBar resignFirstResponder];
    _ibBackBtn.hidden = NO;
    _ibOutLineBtn.hidden = NO;
    _ibSearchBtn.hidden = NO;
}
-(void)DoSearch:(NSString *)txt
{
    //赋值成全局变量，以便翻页，或旋转屏幕时，重新查询时使用。
    if ([txt length]==0) {
        txt = nil;
    }
    _modelController.searchTxt = txt;
    //搜索当前页面入口
    NSArray *VcArr = self.pageViewController.viewControllers;
    DataViewController *currentViewController = VcArr[0];
    [currentViewController restSearchResultColor:txt];
    
    //iPad双屏情况时，着色第二页面
    if ([VcArr count] == 2) {
        [VcArr[1] restSearchResultColor:txt];
    }
}

-(NSString *)documentId
{
    return _pdfDocument;
}
-(NSUInteger)pageNum
{
    DataViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    return indexOfCurrentViewController;
}


#pragma mark BookmarkViewController, _Delegate and _Actions


-(void)dismissBookmarkViewController:(BookmarkViewController *)bvc {
    
    [self dismissAlternateViewController];
}

-(void)bookmarkViewController:(BookmarkViewController *)bvc didRequestPage:(NSUInteger)page{
    
    if (UIInterfaceOrientationIsPortrait(ORIENTATION) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        self.pageViewController.doubleSided = NO;
        DataViewController *startingViewController = [self.modelController viewControllerAtIndex:page-1 storyboard:self.storyboard];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        
        [self dismissAlternateViewController];
        return;
    }
    
    DataViewController *currentViewController = [self.modelController viewControllerAtIndex:page-1 storyboard:self.storyboard];
    NSArray *viewControllers = nil;
    
    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    
    [self dismissAlternateViewController];

}

-(IBAction) ibaBookmarks:(UIButton *)bookmarksButton
{
    
    //
    //	We create an instance of the BookmarkViewController and push it onto the stack as a model view controller, but
    //	you can also push the controller with the navigation controller or use an UIActionSheet.
    
    BookmarkViewController *bookmarksVC = nil;
    
    if (currentReusableView == FPK_REUSABLE_VIEW_BOOKMARK) {
        
        [self dismissAlternateViewController];
        
    } else {
        
        currentReusableView = FPK_REUSABLE_VIEW_BOOKMARK;

        bookmarksVC = [[BookmarkViewController alloc] init];
        [[NSBundle mainBundle] loadNibNamed:@"BookmarkView" owner:bookmarksVC options:nil];
        bookmarksVC.delegate = self;
        
        CGSize popoverContentSize = CGSizeMake(372, 650);
        
        UIView * sourceView = self.view;
        CGRect sourceRect = [self.view convertRect:bookmarksButton.bounds fromView:bookmarksButton];
        
        [self presentViewController:bookmarksVC fromRect:sourceRect sourceView:sourceView contentSize:popoverContentSize];
    }
} 

//显示，隐藏搜索框
- (IBAction)ibSearchBtn:(id)sender {
    
    if (_ibSearchBar.hidden) {
        _ibSearchBar.hidden = NO;
        _ibBackBtn.hidden = YES;
        _ibOutLineBtn.hidden = YES;
        _ibSearchBtn.hidden = YES;

        [self DoSearch:[_ibSearchBar text]];
        [_ibSearchBar becomeFirstResponder];
        
    }else{
        _ibSearchBar.hidden = YES;
        _ibBackBtn.hidden = NO;
        _ibOutLineBtn.hidden = NO;
        _ibSearchBtn.hidden = NO;
        [self DoSearch:@""];
        [_ibSearchBar resignFirstResponder];
    }
}

@end
