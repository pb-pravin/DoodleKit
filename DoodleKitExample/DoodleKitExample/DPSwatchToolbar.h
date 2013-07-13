//
//  DPSwatchToolbar.h
//  DoodleKitExample
//
//  Created by Dave Shanley on 7/12/13.
//  Copyright (c) 2013 Alexander Belliotti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPPieTimer.h"
#import "DPSwatch.h"

@protocol DPSwatchToolbarDelegate <NSObject>

- (void)toolbarCountdownDidFinish;
- (void)doodlerDidChangeToSwatch:(DPSwatch *)swatch;
- (void)doodlerDidSelectEraser;
- (void)doodlerDidSelectTrash;

@end

@interface DPSwatchToolbar : UIView <DPPieTimerDelegate>

@property (nonatomic, strong) DPPieTimer *progressView;
@property (nonatomic, strong) NSArray *swatches;
@property (nonatomic, weak) id<DPSwatchToolbarDelegate> delegate;

- (void)showToolbar;
- (void)startCountdown;


@end