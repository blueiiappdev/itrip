/*
 File: RootViewController.m 
 Abstract: Controller for the main table view of the LazyTable sample.
 This table view controller works off the AppDelege's data model.
 produce a three-stage lazy load:
 1. No data (i.e. an empty table)
 2. Text-only data from the model's RSS feed
 3. Images loaded over the network asynchronously
 
 This process allows for asynchronous loading of the table to keep the UI responsive.
 Stage 3 is managed by the dailyRecord corresponding to each row/cell.
 
 Images are scaled to the desired height.
 If rapid scrolling is in progress, downloads do not begin until scrolling has ended.
 
 Version: 1.2 
 
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
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
 
 */

#import "TripDetailController.h"
#import "ASIHTTPRequest.h"
#import "DSURLHelper.h"
#import "JSONKit.h"

#define kCustomRowHeight    260.0
#define kCustomRowCount     7

#pragma mark -

@interface TripDetailController ()

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

- (void)startIconDownload:(DSTripDailyRecord *)dailyRecord forIndexPath:(NSIndexPath *)indexPath;

@end

@implementation TripDetailController

@synthesize tripRecord = m_tripRecord;
@synthesize tripId = m_tripId;
@synthesize headerCell;
@synthesize imageDownloadsInProgress;


#pragma mark 

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
//   self.tableView.rowHeight = kCustomRowHeight;
   
   NSURL* url = [NSURL URLWithString:[[DSURLHelper sharedURLHelper] tripBoardTripRecord:m_tripId]];
   ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
   [request setDelegate:self];
   [request startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
   // Use when fetching text data
   NSString *responseString = [request responseString];
   NSDictionary* tr = (NSDictionary*)[responseString objectFromJSONString];
   m_tripRecord = [[DSTripRecord alloc] initWithMap: tr];
   [self.tableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
   NSError *error = [request error];
}

- (void)dealloc
{
   [m_tripRecord release];
	[imageDownloadsInProgress release];
   
   [headerCell release];
   [super dealloc];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   
   // terminate all pending download connections
   NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
   [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

#pragma mark -
#pragma mark Table view creation (UITableViewDataSource)

// customize the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if (m_tripRecord == nil || m_tripRecord.dailyRecords == nil)
   {
      return 0;
   }
   
	int count = [m_tripRecord.dailyRecords count];
	
	// ff there's no data yet, return enough rows to fill the screen
   if (count == 0)
	{
      return kCustomRowCount;
   }
   return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return indexPath.row == 0 ? 150 : kCustomRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// customize the appearance of table view cells
	//
	static NSString *CellIdentifier = @"LazyTableCell";
   static NSString *CellIdentifier2 = @"LazyTableCell2";
   static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
   
   // add a placeholder cell while waiting on table data
   int nodeCount = [self.tripRecord.dailyRecords count];
	
	if (nodeCount == 0 && indexPath.row == 0)
	{
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
      if (cell == nil)
		{
         cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                        reuseIdentifier:PlaceholderCellIdentifier] autorelease];   
         cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
      }
      
		cell.detailTextLabel.text = @"Loading…";
		
		return cell;
   }
	
   UITableViewCell *cell = indexPath.row > 0 ? [tableView dequeueReusableCellWithIdentifier:CellIdentifier] : [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
   UILabel *textLabel2, *detailTextLabel2;
   UIImageView *imageView2;
   if (cell == nil)
	{
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
      int width = self.view.bounds.size.width;
      
      //for 0th cell
      if (indexPath.row == 0) {
         [[NSBundle mainBundle] loadNibNamed:@"DetailTripHeaderCell" owner:self options:nil];
         cell = self.headerCell;
         self.headerCell = nil;
      }
      else {
         //for normal cell
         
         imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 200)];
         imageView2.tag = 1;
         
         textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, width, 25)];
         textLabel2.tag = 2;
         
         detailTextLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 230, width, 25)];
         detailTextLabel2.tag = 3;
         
         [cell addSubview:imageView2];
         [cell addSubview:textLabel2];
         [cell addSubview:detailTextLabel2];
         
         [imageView2 release];
         [textLabel2 release];
         [detailTextLabel2 release];         
      }
   }
   
   // Leave cells empty if there's no data yet
   if (nodeCount > 0)
	{
      DSTripDailyRecord *dailyRecord = [self.tripRecord.dailyRecords objectAtIndex:indexPath.row];
      
      imageView2 = (UIImageView*)[cell viewWithTag:1];
      textLabel2 = (UILabel*) [cell viewWithTag:2];
      detailTextLabel2 = (UILabel*) [cell viewWithTag:3];
      
		textLabel2.text = dailyRecord.title;
      detailTextLabel2.text = dailyRecord.intro;
		
      // Only load cached images; defer new downloads until scrolling ends
      if (!dailyRecord.photo)
      {
         if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
         {
            [self startIconDownload:dailyRecord forIndexPath:indexPath];
         }
         // if a download is deferred or in progress, return a placeholder image
         imageView2.image = [UIImage imageNamed:@"Placeholder.png"];                
      }
      else
      {
         imageView2.image = dailyRecord.photo;
      }
      
   }
   
   return cell;
}


#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(DSTripDailyRecord *)dailyRecord forIndexPath:(NSIndexPath *)indexPath
{
   IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
   if (iconDownloader == nil) 
   {
      iconDownloader = [[IconDownloader alloc] init];
      iconDownloader.dailyRecord = dailyRecord;
      iconDownloader.indexPathInTableView = indexPath;
      iconDownloader.delegate = self;
      [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
      [iconDownloader startDownload];
      [iconDownloader release];   
   }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
   if ([self.tripRecord.dailyRecords count] > 0)
   {
      NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
      for (NSIndexPath *indexPath in visiblePaths)
      {
         DSTripDailyRecord *dailyRecord = [self.tripRecord.dailyRecords objectAtIndex:indexPath.row];
         
         if (!dailyRecord.photo) // avoid the app icon download if the app already has an icon
         {
            [self startIconDownload:dailyRecord forIndexPath:indexPath];
         }
      }
   }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
   IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
   if (iconDownloader != nil)
   {
      UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
      
      // Display the newly loaded image
//      cell.imageView.image = iconDownloader.dailyRecord.appIcon;
      
      //added by ramon
      UIImageView* imageView2 = (UIImageView*)[cell viewWithTag:1];
      imageView2.image = iconDownloader.dailyRecord.photo;
   }
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
   if (!decelerate)
	{
      [self loadImagesForOnscreenRows];
   }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   [self loadImagesForOnscreenRows];
}

- (void)viewDidUnload {
   [self setHeaderCell:nil];
   [super viewDidUnload];
}
@end