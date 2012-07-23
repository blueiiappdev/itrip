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

#define kCustomRowHeight    300
#define kCustomRowCount     7

#define kTitleTagInCell             20
#define kImageTagInCell             21
#define kDateTagInCell              22
#define kIntroTagInCell             23
#define kAuthorTagInCell            24
#define kDaysTagInCell              25
#define kAddressTagInCell           26
#define kFavCountTagInCell          10
#define kCommentCountTagInCell      11

#pragma mark -

@interface TripDetailController ()

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

- (void)startIconDownload:(NSIndexPath *)indexPath;

- (void)showHeaderCell:(UITableViewCell*)cell indexPath:(NSIndexPath*) indexPath;
- (void)showTableCell:(UITableViewCell*)cell indexPath:(NSIndexPath*) indexPath;
- (void)showImage:(UIImageView*)imageView onCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath;

- (NSString*)dateToString:(NSDate*)date;
@end

@implementation TripDetailController

@synthesize tripRecord = m_tripRecord;
@synthesize tripId = m_tripId;
@synthesize headerCell;
@synthesize tableCell;
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
   //NSError *error = [request error];
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
   
	int count = [m_tripRecord.dailyRecords count] + 1;
	
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
   static NSString *HeaderCellIndentifier = @"HeaderCellIndentifier";
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
	
   UITableViewCell *cell = indexPath.row > 0 ? [tableView dequeueReusableCellWithIdentifier:CellIdentifier] : [tableView dequeueReusableCellWithIdentifier:HeaderCellIndentifier];
   
   if (cell == nil)
	{
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
      //for 0th cell
      if (indexPath.row == 0) 
      {
         [[NSBundle mainBundle] loadNibNamed:@"DetailTripHeaderCell" owner:self options:nil];
         cell = self.headerCell;
         self.headerCell = nil;
      }
      else 
      {
         [[NSBundle mainBundle] loadNibNamed:@"TripDetailTableCell" owner:self options:nil];
         cell = self.tableCell;
         self.tableCell = nil;       
      }
   }
   
   // Leave cells empty if there's no data yet
   if (self.tripRecord != nil)
	{
      if (indexPath.row == 0) {
         [self showHeaderCell:cell indexPath:indexPath];
      } else {
         [self showTableCell:cell indexPath:indexPath];
      }
   }
   
   return cell;
}

-(void)showHeaderCell:(UITableViewCell*) cell indexPath:(NSIndexPath*)indexPath {
   DSTripRecord *tripRecord = self.tripRecord;
   NSString* dateStr = [self dateToString:tripRecord.start]; // [NSDateFormatter localizedStringFromDate:tripRecord.start dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
   NSLog(@"dateStr=%@, realDate=%@", dateStr, tripRecord.start);
   ((UILabel*) [cell viewWithTag:kDateTagInCell]).text = dateStr;
   ((UILabel*) [cell viewWithTag:kTitleTagInCell]).text = tripRecord.title;
   ((UILabel*) [cell viewWithTag:kAuthorTagInCell]).text = tripRecord.authorName;
   ((UILabel*) [cell viewWithTag:kFavCountTagInCell]).text = [NSString stringWithFormat:@"%d", tripRecord.favCount];
   ((UILabel*) [cell viewWithTag:kCommentCountTagInCell]).text = [NSString stringWithFormat:@"%d", tripRecord.commentCount];
   ((UILabel*) [cell viewWithTag:kDaysTagInCell]).text = [NSString stringWithFormat:@"%d", tripRecord.days];
   
   [self showImage:(UIImageView*)[cell viewWithTag:kImageTagInCell] onCell:cell indexPath:indexPath];
}

-(void)showTableCell:(UITableViewCell*) cell indexPath:(NSIndexPath *)indexPath {
   DSTripDailyRecord *dailyRecord = [self.tripRecord.dailyRecords objectAtIndex:indexPath.row-1];
   
   NSString* dateStr = [self dateToString:dailyRecord.date]; // [NSDateFormatter localizedStringFromDate:dailyRecord.date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
   NSLog(@"dateStr=%@, realDate=%@", dateStr, dailyRecord.date);
   ((UILabel*) [cell viewWithTag:kDateTagInCell]).text = dateStr;
   ((UILabel*) [cell viewWithTag:kIntroTagInCell]).text = dailyRecord.intro;
   ((UILabel*) [cell viewWithTag:kTitleTagInCell]).text = dailyRecord.title;
   ((UILabel*) [cell viewWithTag:kFavCountTagInCell]).text = [NSString stringWithFormat:@"%d", dailyRecord.favCount];
   ((UILabel*) [cell viewWithTag:kCommentCountTagInCell]).text = [NSString stringWithFormat:@"%d", dailyRecord.commentCount];
   
   [self showImage:(UIImageView*)[cell viewWithTag:kImageTagInCell] onCell:cell indexPath:indexPath];
}

- (NSString*) dateToString:(NSDate *)date {
   static NSDateFormatter *formatter = nil;
   if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];  
      [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
      formatter.dateStyle = NSDateFormatterShortStyle;
      formatter.timeStyle = NSDateFormatterShortStyle;
   }
   return [formatter stringFromDate:date];
}

- (void)showImage:(UIImageView *)imageView onCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
   UIImage* photo = nil;
   NSString* url = nil;
   if (indexPath.row == 0)
   {
      photo = self.tripRecord.authorPhoto;
      if (self.tripRecord.authorPhotoUrl)
      {
         url = [[DSURLHelper sharedURLHelper] absolutePath:self.tripRecord.authorPhotoUrl];
      }
   }
   else
   {
      DSTripDailyRecord *dailyRecord = [self.tripRecord.dailyRecords objectAtIndex:indexPath.row-1];
      photo = dailyRecord.photo;
      url = [[DSURLHelper sharedURLHelper] absolutePath:dailyRecord.photoUrl];
   }
   
   // Only load cached images; defer new downloads until scrolling ends
   if (!photo)
   {
      if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
      {
         [self startIconDownload:indexPath];
      }
      // if a download is deferred or in progress, return a placeholder image
      imageView.image = [UIImage imageNamed:@"Placeholder.png"];                
   }
   else
   {
      imageView.image = photo;
   }
}


#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(NSIndexPath *)indexPath
{
   IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
   if (iconDownloader == nil) 
   {
      NSString* url = nil;
      if (indexPath.row == 0)
      {
         if (self.tripRecord.authorPhotoUrl)
         {
            url = [[DSURLHelper sharedURLHelper] absolutePath:self.tripRecord.authorPhotoUrl];
         }
      }
      else
      {
         DSTripDailyRecord *dailyRecord = [self.tripRecord.dailyRecords objectAtIndex:indexPath.row-1];
         url = [[DSURLHelper sharedURLHelper] absolutePath:dailyRecord.photoUrl];
      }
      iconDownloader = [[IconDownloader alloc] init];
      iconDownloader.imageUrl = url;
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
         UIImage* photo = nil;
         if (indexPath.row == 0)
         {
            photo = self.tripRecord.authorPhoto;
         }
         else
         {
            DSTripDailyRecord *dailyRecord = [self.tripRecord.dailyRecords objectAtIndex:indexPath.row -1];
            photo = dailyRecord.photo;
         }
         
         if (!photo) // avoid the app icon download if the app already has an icon
         {
            [self startIconDownload:indexPath];
         }
      }
   }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(UIImage*)image indexPath:(NSIndexPath *)indexPath
{
   IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
   if (iconDownloader != nil)
   {
      UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
      UIImageView* imageView2 = (UIImageView*)[cell viewWithTag:kImageTagInCell];
      imageView2.image = image;
      if (indexPath.row == 0) 
      {
         self.tripRecord.authorPhoto = image;
      }
      else 
      {
         DSTripDailyRecord *dailyRecord = [self.tripRecord.dailyRecords objectAtIndex:(indexPath.row-1)];
         dailyRecord.photo = image;
      }
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