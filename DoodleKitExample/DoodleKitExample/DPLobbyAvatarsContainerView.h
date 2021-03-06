//
//  DPLobbyAvatarsView.h
//  DoodleKitExample
//
//  Created by Alexander Belliotti on 7/13/13.
//  Copyright (c) 2013 Alexander Belliotti. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPPlayer;

@class DPLobbyAvatarView;

@interface DPLobbyAvatarsContainerView : UIView

- (DPLobbyAvatarView *)avatarForPlayerNumber:(NSUInteger)playerIndex;

@end
