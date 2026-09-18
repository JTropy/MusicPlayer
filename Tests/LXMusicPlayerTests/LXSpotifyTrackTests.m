//
//  LXSpotifyTrackTests.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import <XCTest/XCTest.h>
#import "LXMusicTrack+Private.h"
#import "LXSpotifyScriptingTrackStub.h"

/// Spotify's scripting dictionary documents `duration` as seconds, but the
/// application answers in milliseconds: "We Don't Talk Anymore" is 3:37 long
/// and Spotify reports 217699 for it. Everything downstream — the scrubber,
/// the remaining-time label, lyrics ranking, the track-end poll — expects
/// seconds, so the adapter has to convert.
@interface LXSpotifyTrackTests : XCTestCase
@end

@implementation LXSpotifyTrackTests

static NSString *const LXSpotifyTrackTestsIdentifier = @"spotify:track:3zBhihYUHBmGd2bcQIobrF";

- (LXSpotifyTrack *)makeTrackWithDurationMilliseconds:(NSInteger)durationMilliseconds {
    LXSpotifyScriptingTrackStub *scriptingTrack =
        [[LXSpotifyScriptingTrackStub alloc] initWithIdentifier:LXSpotifyTrackTestsIdentifier
                                           durationMilliseconds:durationMilliseconds
                                               artworkURLString:nil];
    LXSpotifyTrack *track = [[LXSpotifyTrack alloc] initWithSBTrack:(SBObject *)scriptingTrack];
    XCTAssertNotNil(track, @"a scripting object with an id must yield a track");
    return track;
}

- (void)testDurationIsReportedInSecondsWhenSpotifyAnswersMilliseconds {
    LXSpotifyTrack *track = [self makeTrackWithDurationMilliseconds:217699];

    XCTAssertEqualWithAccuracy(track.duration.doubleValue, 217.699, 0.0005);
}

- (void)testArtworkURLComesFromSpotifysArtworkUrl {
    NSString *artworkURLString = @"https://i.scdn.co/image/ab67616d0000b273b1b4a3b4f1bd1b9f6e5c2b3a";
    LXSpotifyScriptingTrackStub *scriptingTrack =
        [[LXSpotifyScriptingTrackStub alloc] initWithIdentifier:LXSpotifyTrackTestsIdentifier
                                           durationMilliseconds:217699
                                               artworkURLString:artworkURLString];
    LXSpotifyTrack *track = [[LXSpotifyTrack alloc] initWithSBTrack:(SBObject *)scriptingTrack];

    XCTAssertEqualObjects(track.artworkURL, [NSURL URLWithString:artworkURLString]);
}

- (void)testArtworkURLIsAbsentWhenSpotifyOffersNone {
    LXSpotifyTrack *track = [self makeTrackWithDurationMilliseconds:217699];

    XCTAssertNil(track.artworkURL);
}

- (void)testACopyKeepsTheDurationInSeconds {
    LXSpotifyTrack *track = [self makeTrackWithDurationMilliseconds:217699];
    (void)track.duration;

    LXMusicTrack *copy = [track copy];

    XCTAssertEqualWithAccuracy(copy.duration.doubleValue, 217.699, 0.0005);
}

@end
