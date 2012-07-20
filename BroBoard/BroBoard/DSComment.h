//
//  DSComment.h
//  iTrip
//
//  Created by Ramon Liu on 7/20/12.
//  Copyright (c) 2012 DreamStart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSComment : NSObject
{
   NSString*      m_authorId;
   NSString*      m_authorName;
   NSDate*        m_publishDate;
   NSString*      m_content;
}

@property(retain) NSString*  authorId;
@property(retain) NSString*  authorName;
@property(retain) NSDate*    publishDate;
@property(retain) NSString*  content;

@end
