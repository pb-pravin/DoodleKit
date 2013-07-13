//
//  GTViewController.m
//  DoodleTester
//
//  Created by Robert Corlett on 7/12/13.
//  Copyright (c) 2013 Robert Corlett. All rights reserved.
//

#import "GTViewController.h"
#import <GameKit/GameKit.h>


static NSInteger const HostTestFlag = 1 << 0;
static NSInteger const HostClaimFlag = 1 << 1;
static NSInteger const HostConfirmFlag = 1 << 2;
static NSInteger const StartGameFlag = 1 << 3;

@interface GTViewController ()
@property (nonatomic) NSMutableArray *deviceIDs;
@property (nonatomic) NSMutableSet *playersToInvite;
@property (nonatomic) GKMatch *match;
@property (nonatomic) NSInteger playerCount;
@property (nonatomic) BOOL isHost;
@property (nonatomic) NSString *hostPlayerID;
@property (nonatomic) NSMutableSet *confirmedPlayers;

@property (nonatomic) UILabel *startGameLabel;
@property (nonatomic) UILabel *iAmHostLabel;
@end

@implementation GTViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.playersToInvite = [NSMutableSet set];
        self.deviceIDs = [NSMutableArray array];
        self.confirmedPlayers = [NSMutableSet set];

        self.playerCount = 2;
        self.isHost = NO;
    }
    return self;
}


- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor orangeColor];
    self.view = view;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Click Me" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTouchButton) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [self.view addSubview:button];

    UILabel *startGameLabel = [self labelWithText:@"LETS GET THIS PARTY STARTED"];
    startGameLabel.center = CGPointMake(100.f, 100.f);
    [self.view addSubview:startGameLabel];
    self.startGameLabel = startGameLabel;
    [self.startGameLabel setHidden:YES];

    UILabel *iAmHostLabel = [self labelWithText:@"I THINK I AM THE HOST"];
    iAmHostLabel.center = CGPointMake(250.f, 250.f);
    [self.view addSubview:iAmHostLabel];
    self.iAmHostLabel = iAmHostLabel;
    self.iAmHostLabel.hidden = YES;
}

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    return label;
}

- (void)didTouchButton {
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = self.playerCount;
    request.maxPlayers = self.playerCount;

    GKMatchmakerViewController *viewController = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    viewController.matchmakerDelegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {

    self.match = match;
    self.match.delegate = self;
    if (match.expectedPlayerCount == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];

        NSString *myIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [self.deviceIDs addObject:myIdentifier];
        [self sendHostTest:myIdentifier];
    }
}

- (void)sendHostTest:(NSString *)deviceID {
    NSData *payload = [self payloadForDictionary:@{ @"DeviceID": deviceID } withFlag:HostTestFlag];
    [self sendDataToAllPlayers:payload];

}
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs {
    
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didReceiveAcceptFromHostedPlayer:(NSString *)playerID {
    
}

- (NSInteger)flagFromPayload:(NSData *)payload {
    NSInteger flag;
    [payload getBytes:&flag length:sizeof(NSInteger)];
    return flag;
}

- (NSDictionary *)dictionaryFromPayload:(NSData *)payload {
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:
                             [payload subdataWithRange:NSMakeRange(sizeof(NSInteger), [payload length] - sizeof(NSInteger))]];
    return dictionary;
}

- (void)sendDataToAllPlayers:(NSData *)data {
    NSLog(@"Sending data to all players");
    NSError *error;
    [self.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (error) { assert(0); }
}

- (void)sendDataToHost:(NSData *)data {
    NSLog(@"Sending data to host");
    NSError *error;
    [self.match sendData:data toPlayers:@[ self.hostPlayerID ] withDataMode:GKMatchSendDataReliable error:&error];
    if (error) { assert(0); }
}

- (void)receivedHostTestDictionary:(NSDictionary *)dictionary {
    NSString *deviceID = dictionary[@"DeviceID"];
    [self.deviceIDs addObject:deviceID];
    if (self.deviceIDs.count == self.playerCount) {
        [self.deviceIDs sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *string1 = (NSString *)obj1;
            NSString *string2 = (NSString *)obj2;
            return [string1 compare:string2];
        }];

        if ([self.deviceIDs[0] isEqualToString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]) {
            [self becomeHost];
        }
    }
}

- (void)sendHostConfirmation {
    NSData *payload = [self payloadForDictionary:@{ @"message-id": @"you are the host" } withFlag:HostConfirmFlag];
    [self sendDataToHost:payload];
}

- (void)sendStartGame {
    NSData *payload = [self payloadForDictionary:@{ @"message-id": @"start game" } withFlag:StartGameFlag];
    [self sendDataToAllPlayers:payload];

    [self startGame];
}

- (void)receivedHostConfirmDictionary:(NSDictionary *)dictionary fromPlayer:(NSString *)playerID {
    [self.confirmedPlayers addObject:playerID];
    if (self.confirmedPlayers.count == self.playerCount - 1) {
        [self sendStartGame];
    }
}

- (void)receivedHostClaimDictionary:(NSDictionary *)dictionary fromPlayer:(NSString *)playerID {
    self.hostPlayerID = playerID;
    [self sendHostConfirmation];
}

- (void)startGame {
    [self.startGameLabel setHidden:NO];
}

- (void)receivedHostStartGameDictionary:(NSDictionary *)dictionary {
    [self startGame];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    NSInteger flag = [self flagFromPayload:data];
    NSDictionary *dictionary = [self dictionaryFromPayload:data];


    NSLog(@"%d, %@", flag, dictionary);
    switch (flag) {
        case HostTestFlag: {
            [self receivedHostTestDictionary:dictionary];
            break;
        }
        case HostClaimFlag: {
            [self receivedHostClaimDictionary:dictionary fromPlayer:playerID];
        }
        case HostConfirmFlag: {
            [self receivedHostConfirmDictionary:dictionary fromPlayer:playerID];
            break;
        }
        case StartGameFlag: {
            [self receivedHostStartGameDictionary:dictionary];
            break;
        }
        default: {
            assert(0);
            break;
        }
    }
}

- (NSData *)payloadForDictionary:(NSDictionary *)dictionary withFlag:(NSInteger)flag {
    NSMutableData *prelude = [NSMutableData dataWithBytes:&flag length:sizeof(NSInteger)];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [prelude appendData:data];
    return prelude;
}

- (void)becomeHost {
    self.iAmHostLabel.hidden = NO;
    self.isHost = YES;

    NSData *payload = [self payloadForDictionary:@{ @"message-id": @"become-host" } withFlag:HostClaimFlag];
    [self sendDataToAllPlayers:payload];
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)match didFailWithError:(NSError *)error {
    
}

// This method is called when the match is interrupted; if it returns YES, a new invite will be sent to attempt reconnection. This is supported only for 1v1 games
- (BOOL)match:(GKMatch *)match shouldReinvitePlayer:(NSString *)playerID {
    return YES;
}

- (void)startSearching {}

@end
