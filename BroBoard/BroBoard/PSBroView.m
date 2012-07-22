//
//  PSBroView.m
//  BroBoard
//
//  Created by Peter Shih on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 This is an example of a subclass of PSCollectionViewCell
 */

#import "PSBroView.h"
#import "DSURLHelper.h"

#define MARGIN 0

@interface PSBroView ()


@property (nonatomic, retain) UILabel *captionLabel;

-(void)createAndDisplayCaptionLabel;

@end

@implementation PSBroView

@synthesize
imageView = m_imageView,
captionLabel = m_captionLabel;

@synthesize showCaptionLabel = m_showCaptionLabel;

- (id)initWithFrame:(CGRect)frame {
   self = [super initWithFrame:frame];
   if (self) {
      self.backgroundColor = [UIColor lightGrayColor];
      
      self.imageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
      self.imageView.clipsToBounds = YES;
      [self addSubview:self.imageView];
      
      [self setShowCaptionLabel:NO];
   }
   return self;
}

- (void) setShowCaptionLabel:(BOOL)showCaptionLabel
{
   if (showCaptionLabel)
   {
      if (m_captionLabel == nil) {
         [self createAndDisplayCaptionLabel];
      } else {
         self.captionLabel.hidden = NO;
      }
   }
   else {
      if (m_captionLabel != nil && !self.captionLabel.isHidden) {
         self.captionLabel.hidden = YES;
      }
   }
   m_showCaptionLabel = showCaptionLabel;
}

- (BOOL) showCaptionLabel {
   return m_showCaptionLabel;
}

- (void)createAndDisplayCaptionLabel{
   self.captionLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
   self.captionLabel.font = [UIFont boldSystemFontOfSize:14.0];
   self.captionLabel.numberOfLines = 0;
   [self addSubview:self.captionLabel];
}

- (void)prepareForReuse {
   [super prepareForReuse];
   self.imageView.image = nil;
   self.captionLabel.text = nil;
}

- (void)dealloc {
   self.imageView = nil;
   self.captionLabel = nil;
   [super dealloc];
}

- (void)layoutSubviews {
   [super layoutSubviews];
   
   CGFloat width = self.frame.size.width - MARGIN * 2;
   CGFloat top = MARGIN;
   CGFloat left = MARGIN;
   
   // Image
   CGFloat objectWidth = [[self.object objectForKey:@"width"] floatValue];
   CGFloat objectHeight = [[self.object objectForKey:@"height"] floatValue];
   CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
   self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
   
   // Label
   if (self.showCaptionLabel) {
      CGSize labelSize = CGSizeZero;
      labelSize = [self.captionLabel.text sizeWithFont:self.captionLabel.font constrainedToSize:CGSizeMake(width, INT_MAX) lineBreakMode:self.captionLabel.lineBreakMode];
      top = self.imageView.frame.origin.y + self.imageView.frame.size.height + MARGIN;
      
      self.captionLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);      
   }
}

- (void)fillViewWithObject:(id)object {
   [super fillViewWithObject:object];
   
   NSURL *URL = [NSURL URLWithString: [[DSURLHelper sharedURLHelper] absolutePath:[object objectForKey:@"url"]]];
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
   [NSURLConnection connectionWithRequest:request delegate:self];
   
   if (self.showCaptionLabel) {
      self.captionLabel.text = [object objectForKey:@"title"];
   }
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
   return [PSBroView heightForViewWithObject:object inColumnWidth:columnWidth includingCaption:NO];
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth includingCaption:(BOOL)includingCaption {
   CGFloat height = 0.0;
   CGFloat width = columnWidth - MARGIN * 2;
   
   height += MARGIN;
   
   // Image
   CGFloat objectWidth = [[object objectForKey:@"width"] floatValue];
   CGFloat objectHeight = [[object objectForKey:@"height"] floatValue];
   CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
   height += scaledHeight;
   
   // Label
   if (includingCaption) {
      NSString *caption = [object objectForKey:@"title"];
      CGSize labelSize = CGSizeZero;
      UIFont *labelFont = [UIFont boldSystemFontOfSize:14.0];
      labelSize = [caption sizeWithFont:labelFont constrainedToSize:CGSizeMake(width, INT_MAX) lineBreakMode:UILineBreakModeWordWrap];
      height += labelSize.height;      
   }
   
   height += MARGIN;
   
   return height;
}

#pragma NSURLConnection delegate

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
   m_connectionSuccess = [(NSHTTPURLResponse *)response statusCode] == 200;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  The 
// response data for a POST is only for useful for debugging purposes, 
// so we just drop it on the floor.
{
   if (m_imageData == nil) {
      m_imageData = [[NSMutableData alloc] initWithData:data];
   } else {
      [m_imageData appendData:data];
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
   if (m_connectionSuccess) {
      self.imageView.image = [UIImage imageWithData:m_imageData];
      [m_imageData release];
      m_imageData = nil;
   }
}

@end
