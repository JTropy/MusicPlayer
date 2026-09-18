//
//  LXSpotifyScriptingTrackStub.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import "LXSpotifyScriptingTrackStub.h"

@implementation LXSpotifyScriptingTrackStub {
    NSString *_identifier;
    NSInteger _durationMilliseconds;
    NSString *_artworkURLString;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
              durationMilliseconds:(NSInteger)durationMilliseconds
                  artworkURLString:(NSString *)artworkURLString {
    if ((self = [super init])) {
        _identifier = [identifier copy];
        _durationMilliseconds = durationMilliseconds;
        _artworkURLString = [artworkURLString copy];
    }
    return self;
}

- (NSString *)id {
    return _identifier;
}

- (NSString *)name {
    return @"We Don't Talk Anymore (feat. Selena Gomez)";
}

- (NSString *)artist {
    return @"Charlie Puth";
}

- (NSString *)album {
    return @"Nine Track Mind";
}

- (NSInteger)duration {
    return _durationMilliseconds;
}

- (NSString *)artworkUrl {
    return _artworkURLString;
}

@end
