//
//  DKDrawingTools.h
//  DoodleKit
//
//  Created by Ryan Crosby on 7/13/13.
//  Copyright (c) 2013 DaveVan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

enum _DKDoodleToolType {
    DKDoodleToolTypeNone = 0,
    DKDoodleToolTypePen,
};
typedef NSUInteger DKDoodleToolType;

@interface DKDrawingStrokeDefinition : NSObject < NSCoding >

@property (nonatomic, assign) DKDoodleToolType toolType;
@property (nonatomic, assign) CGPoint initialPoint;
@property (nonatomic, retain) NSArray *dataPoints;

@end

@interface DKPenPoint : NSObject  < NSCoding >

@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) CGPoint previousPoint;
@property (nonatomic, assign) CGPoint previousPreviousPoint;

+ (DKPenPoint *)penPointWithCurrentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)point1 previousPreviousPoint:(CGPoint)point2;

@end
