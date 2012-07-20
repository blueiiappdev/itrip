//
//  PSViewController.m
//  BroBoard
//
//  Created by Peter Shih on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"
#import "LoadingMoreFooterView.h"
#import "PSBroView.h"
#import "JSONKit.h"
#import "DSTripDetailViewController.h"

/**
 This is an example of a controller that uses PSCollectionView
 */

/**
 Detect iPad
 */
static BOOL isDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      return YES; 
   }
#endif
   return NO;
}

@interface PSViewController ()
{
   int _minPage;
   int _maxPage;
}

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) PSCollectionView *collectionView;
@property (nonatomic, retain) UISearchBar* searchBar;

@end

@implementation PSViewController

@synthesize
items = _items,
collectionView = _collectionView,
searchBar = m_searchBar;

@synthesize 
loadingAfter = m_loadingAfter,
loadingBefore = m_loadingBefore;

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      self.items = [NSMutableArray array];
   }
   return self;
}

- (void)viewDidUnload {
   [super viewDidUnload];
   
   self.collectionView.delegate = nil;
   self.collectionView.collectionViewDelegate = nil;
   self.collectionView.collectionViewDataSource = nil;
   
   self.collectionView = nil;
}

- (void)dealloc {
   self.collectionView.delegate = nil;
   self.collectionView.collectionViewDelegate = nil;
   self.collectionView.collectionViewDataSource = nil;
   
   self.collectionView = nil;
   self.items = nil;
   
   self.searchBar = nil;
   
   [super dealloc];
}

- (void)viewDidLoad {
   [super viewDidLoad];
   
   [self resetPage];
   
   self.view.backgroundColor = [UIColor lightGrayColor];
   int searchBarHeight = 35;
   UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, searchBarHeight)];
   searchBar.placeholder = @"Search";
   searchBar.showsCancelButton = YES;
   searchBar.delegate = self;
   self.searchBar = searchBar;
   [self.view addSubview:searchBar];
   [searchBar release];
   
   self.collectionView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0, searchBarHeight, self.view.frame.size.width, self.view.frame.size.height - searchBarHeight)];
   [self.view addSubview:self.collectionView];
   self.collectionView.collectionViewDelegate = self;
   self.collectionView.collectionViewDataSource = self;
   self.collectionView.headerViewDelegate = self;
   self.collectionView.backgroundColor = [UIColor whiteColor];
   self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
   
   if (isDeviceIPad()) {
      self.collectionView.numColsPortrait = 4;
      self.collectionView.numColsLandscape = 5;
   } else {
      self.collectionView.numColsPortrait = 3;
      self.collectionView.numColsLandscape = 3;
   }
   
   UILabel *loadingLabel = [[UILabel alloc] initWithFrame:self.collectionView.bounds];
   loadingLabel.text = @"Loading...";
   loadingLabel.textAlignment = UITextAlignmentCenter;
   self.collectionView.loadingView = loadingLabel;
   [loadingLabel release];
   
   [self loadDataSource];
}

- (void)loadDataSource {
   // Request
   int targetPage = _minPage;
   if (self.loadingAfter) {
      targetPage = --_minPage;
   } else if (self.loadingBefore) {
      targetPage = ++_maxPage;
   } 
   
   NSString* urlStr = [NSString stringWithFormat:@"%@/demos/gallery?page=%d", [NSString stringWithUTF8String: kHostUrl], targetPage];
   NSURL *URL = [NSURL URLWithString:urlStr];
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];   
   [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)dataSourceDidLoad {
   [self.collectionView reloadData];
}

- (void)dataSourceDidError {
   [self.collectionView reloadData];
}

#pragma mark - PSCollectionViewDelegate and DataSource
- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView {
   return [self.items count];
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
   NSDictionary *item = [self.items objectAtIndex:index];
   
   PSBroView *v = (PSBroView *)[self.collectionView dequeueReusableView];
   if (!v) {
      v = [[PSBroView alloc] initWithFrame:CGRectZero];
   }
   
   [v fillViewWithObject:item];
   
   return v;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
   NSDictionary *item = [self.items objectAtIndex:index];
   
   return [PSBroView heightForViewWithObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(PSCollectionViewCell *)view atIndex:(NSInteger)index {
   NSDictionary *item = [self.items objectAtIndex:index];
   
   UINavigationController* navController = (UINavigationController*)self.parentViewController;
   navController.navigationBarHidden = NO;
   DSTripDetailViewController* tripDetailController = [[DSTripDetailViewController alloc] initWithNibName:@"DSTripDetailView" bundle:nil];

   NSMutableDictionary* d = [NSMutableDictionary dictionaryWithDictionary:item];
   [d setValue:((PSBroView*)view).imageView.image forKey:@"image"];
   tripDetailController.tripItem = d;
   
   [navController pushViewController:tripDetailController animated:YES];
}

#pragma NSURLConnection delegate

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
   _connectedSuccess = responseCode == 200;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  The 
// response data for a POST is only for useful for debugging purposes, 
// so we just drop it on the floor.
{
   if (_galleryData == nil) {
      _galleryData = [[NSMutableData alloc] initWithData:data];
   } else {
      [_galleryData appendData:data];
   }
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails. 
// We shut down the connection and display the failure.  Production quality code 
// would either display or log the actual error.
{
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been 
// done successfully.  We shut down the connection with a nil status, which 
// causes the image to be displayed.
{
   if (_connectedSuccess) {
      id res = [_galleryData objectFromJSONData];
      //      id res = [NSJSONSerialization JSONObjectWithData:_galleryData options:NSJSONReadingMutableContainers error:nil];
      if (res) {
         NSArray* arr = (NSArray*)res;
         if (self.loadingAfter) {
            if (arr.count > 0) {
               [self.items insertObjects:res atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, arr.count)]];
            }
            self.loadingAfter = NO;
            [self.collectionView.headerView  egoRefreshScrollViewDataSourceDidFinishedLoading: self.collectionView];
         } else if (self.loadingBefore) {
            self.loadingBefore = NO;
            self.collectionView.footerView.showActivityIndicator = NO;
            
            if (arr.count > 0) {
               [self.items insertObjects:res atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.items.count, [arr count])]];
            } else {
               self.collectionView.footerView.hidden = YES;
            }
         } else {
            self.items = [NSMutableArray arrayWithArray:arr];
         }
         
         if (arr.count > 0) {
            [self dataSourceDidLoad];
         }
      } else {
         [self dataSourceDidError];
      }
      
      [_galleryData release];
      _galleryData = nil;
      
   } else {
      [self dataSourceDidError];
   }
}

#pragma mark - UISearchBarDelegate

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
   [self.searchBar endEditing:YES];
   NSString* urlStr = [NSString stringWithFormat:@"%@/demos/searchgallery?query=%@", [NSString stringWithUTF8String: kHostUrl], searchBar.text];
   NSURL *URL = [NSURL URLWithString:urlStr];
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];   
   [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
   [self.searchBar endEditing:YES];
   if ([searchBar.text isEqualToString:@""]) {
      [self resetPage];
      [self loadDataSource];
   }
}

- (void) resetPage 
{
   _minPage = 1;
   _maxPage = 1;
}

#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
   self.loadingAfter = YES;
   
   [self performSelector:@selector(loadDataSource) withObject:nil afterDelay:1.0f];  //make a delay to show loading process for a while
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return self.loadingAfter; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
   return [NSDate date];
}

@end
