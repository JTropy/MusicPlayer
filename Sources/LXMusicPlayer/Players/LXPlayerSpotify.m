//
//  LXPlayerSpotify.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

#import "LXScriptingMusicPlayer+Private.h"
#import "LXMusicTrack+Private.h"
#import "LXSpotifyArtworkLoader.h"
#import "Spotify.h"

static LXMusicTrack* currentTrack(SpotifyApplication *app) {
    SpotifyTrack *t = app.currentTrack;
    if (t) {
        return [[LXSpotifyTrack alloc] initWithSBTrack:t];
    } else {
        return nil;
    }
}

static LXPlaybackState playbackState(SpotifyApplication *app) {
    switch (app.playerState) {
        case SpotifyEPlSStopped: return LXPlaybackStateStopped;
        case SpotifyEPlSPlaying: return LXPlaybackStatePlaying;
        case SpotifyEPlSPaused: return LXPlaybackStatePaused;
        default: return LXPlaybackStateStopped;
    }
}

static LXPlayerState* playerState(SpotifyApplication *app) {
    return [LXPlayerState state:playbackState(app) playbackTime:app.playerPosition];
}

@interface LXPlayerSpotify ()

@property (nonatomic, readonly) LXSpotifyArtworkLoader *artworkLoader;

@end

@implementation LXPlayerSpotify

+ (LXMusicPlayerName)playerName {
    return LXMusicPlayerNameSpotify;
}

- (SpotifyApplication *)app {
    return (SpotifyApplication *)super.originalPlayer;
}

- (instancetype)init {
    if ((self = [super init])) {
        _artworkLoader = [[LXSpotifyArtworkLoader alloc] init];
        if (self.isRunning) {
            self.currentTrack = currentTrack(self.app);
            self.playerState = playerState(self.app);
        }
        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(playerInfoNotification:) name:@"com.spotify.client.PlaybackStateChanged" object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
}

- (void)playerInfoNotification:(NSNotification *)notification {
    if (!self.isRunning) { return; }
    NSString *persistentID = notification.userInfo[@"Track ID"];
    if (![self.currentTrack.persistentID isEqualToString:persistentID]) {
        self.currentTrack = currentTrack(self.app);
    }
    LXPlaybackState playbackState;
    NSString *stateStr = notification.userInfo[@"Player State"];
    NSTimeInterval position = [notification.userInfo[@"Playback Position"] doubleValue];
    if ([stateStr isEqualToString:@"Playing"]) {
        playbackState = LXPlaybackStatePlaying;
    } else if ([stateStr isEqualToString:@"Paused"]) {
        playbackState = LXPlaybackStatePaused;
    } else {
        playbackState = LXPlaybackStateStopped;
    }
    LXPlayerState *state = [LXPlayerState state:playbackState playbackTime:position];
    [self setPlayerState:state tolerate:0.5];
}

- (void)setPlaybackTime:(NSTimeInterval)playbackTime {
    if (!self.isRunning) { return; }
    self.app.playerPosition = playbackTime;
    self.playerState = [LXPlayerState state:self.playerState.state playbackTime:playbackTime];
}

// Spotify's `artwork` property is deprecated and never set, so a new track
// arrives without a cover; the cover is fetched from its `artwork url` and the
// track is published a second time once it is in place.
- (void)setCurrentTrack:(LXMusicTrack *)currentTrack {
    [super setCurrentTrack:currentTrack];
    [self loadArtworkIfNeededForTrack:currentTrack];
}

- (void)loadArtworkIfNeededForTrack:(LXMusicTrack *)track {
    if (![track isKindOfClass:LXSpotifyTrack.class] || track.artwork != nil) {
        [self.artworkLoader cancel];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.artworkLoader loadArtworkForTrack:(LXSpotifyTrack *)track completion:^(LXSpotifyTrack *loadedTrack) {
        typeof(self) strongSelf = weakSelf;
        if (strongSelf == nil || strongSelf.currentTrack != loadedTrack) { return; }
        // The same track again, now with its cover: observers of `currentTrack`
        // see the change, and the setter finds the artwork in place instead of
        // starting another request.
        strongSelf.currentTrack = loadedTrack;
    }];
}

- (void)updatePlayerState {
    if (!self.isRunning) { return; }
    LXMusicTrack *track = currentTrack(self.app);
    LXPlayerState *state = playerState(self.app);
    if ([self.currentTrack.persistentID isEqualToString:track.persistentID]) {
        [self setPlayerState:state tolerate:0.5];
    } else {
        self.currentTrack = track;
        self.playerState = state;
    }
}

- (void)resume {
    if (!self.isRunning) { return; }
    [self.app play];
}

- (void)pause {
    if (!self.isRunning) { return; }
    [self.app pause];
}

- (void)playPause {
    if (!self.isRunning) { return; }
    [self.app playpause];
}

- (void)skipToNextItem {
    if (!self.isRunning) { return; }
    [self.app nextTrack];
}

- (void)skipToPreviousItem {
    if (!self.isRunning) { return; }
    [self.app previousTrack];
}

@end

#endif
