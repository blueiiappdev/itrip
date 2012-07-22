//
//  DSURLHelper.h
//  iTrip
//
//  Created by Ramon Liu on 7/22/12.
//  Copyright (c) 2012 DreamStart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSURLHelper : NSObject
{
   NSString*   m_host;
   NSString*   m_tripBoard;
}

+(DSURLHelper*) sharedURLHelper;

-(id) init;

-(NSString*) absolutePath:(NSString*)relativePath;

-(NSString*) tripBoardGallery:(int)page;
-(NSString*) tripBoardSearchGallery:(NSString*)keyword;
-(NSString*) tripBoardTripRecord:(NSString*)tid;
@end
