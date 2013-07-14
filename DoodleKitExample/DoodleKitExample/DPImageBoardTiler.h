//
//  DPImageQuadrantDataSource.h
//  DoodleKitExample
//
//  Created by Alexander Belliotti on 7/13/13.
//  Copyright (c) 2013 Alexander Belliotti. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DPImageBoardDataSource.h"

@protocol DPImageBoardTilerDelegate;

@interface DPImageBoardTiler : NSObject <DPImageBoardDataSource>

@property (nonatomic, assign) NSUInteger userIndex;

@property (nonatomic, weak) id<DPImageBoardTilerDelegate> delegate;

- (id)initWithImage:(UIImage *)image delegate:(id<DPImageBoardTilerDelegate>)delegate;

- (void)tile;

@end

@protocol DPImageBoardTilerDelegate <NSObject>

- (void)imageTilerFinished:(DPImageBoardTiler *)tiler;

@end
