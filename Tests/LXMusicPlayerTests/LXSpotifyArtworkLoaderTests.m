//
//  LXSpotifyArtworkLoaderTests.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import <AppKit/AppKit.h>
#import <XCTest/XCTest.h>
#import "LXMusicTrack+Private.h"
#import "LXSpotifyArtworkLoader.h"
#import "LXSpotifyScriptingTrackStub.h"

/// Spotify never fills `artwork`; the cover has to be fetched from the URL the
/// track points at. The network is the one thing stubbed here — the loader is
/// handed the bytes a request would have returned.
@interface LXSpotifyArtworkLoaderTests : XCTestCase
@end

@implementation LXSpotifyArtworkLoaderTests

static NSString *const LXSpotifyArtworkLoaderTestsURL = @"https://i.scdn.co/image/ab67616d0000b273b1b4a3b4f1bd1b9f6e5c2b3a";

- (LXSpotifyTrack *)makeTrackWithIdentifier:(NSString *)identifier artworkURLString:(NSString *)artworkURLString {
    LXSpotifyScriptingTrackStub *scriptingTrack =
        [[LXSpotifyScriptingTrackStub alloc] initWithIdentifier:identifier
                                           durationMilliseconds:217699
                                               artworkURLString:artworkURLString];
    return [[LXSpotifyTrack alloc] initWithSBTrack:(SBObject *)scriptingTrack];
}

/// The bytes of a real, if tiny, PNG — what a cover request delivers.
- (NSData *)makeCoverData {
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                        pixelsWide:2
                                                                        pixelsHigh:2
                                                                     bitsPerSample:8
                                                                   samplesPerPixel:4
                                                                          hasAlpha:YES
                                                                          isPlanar:NO
                                                                    colorSpaceName:NSDeviceRGBColorSpace
                                                                       bytesPerRow:0
                                                                      bitsPerPixel:0];
    return [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
}

- (void)testStoresTheCoverOnTheTrackAndReportsIt {
    NSData *coverData = [self makeCoverData];
    NSMutableArray<NSURL *> *requestedURLs = [NSMutableArray array];
    LXSpotifyArtworkLoader *loader = [[LXSpotifyArtworkLoader alloc] initWithDataProvider:^(NSURL *artworkURL, LXSpotifyArtworkDataHandler handler) {
        [requestedURLs addObject:artworkURL];
        handler(coverData);
    }];
    LXSpotifyTrack *track = [self makeTrackWithIdentifier:@"spotify:track:one" artworkURLString:LXSpotifyArtworkLoaderTestsURL];
    XCTestExpectation *reported = [self expectationWithDescription:@"cover reported"];

    [loader loadArtworkForTrack:track completion:^(LXSpotifyTrack *loadedTrack) {
        XCTAssertTrue(loadedTrack == track);
        [reported fulfill];
    }];

    [self waitForExpectations:@[reported] timeout:2];
    XCTAssertEqualObjects(requestedURLs, @[[NSURL URLWithString:LXSpotifyArtworkLoaderTestsURL]]);
    XCTAssertNotNil(track.artwork);
    XCTAssertEqual((NSInteger)track.artwork.size.width, 2);
}

- (void)testACoverArrivingForASupersededTrackIsDropped {
    NSData *coverData = [self makeCoverData];
    NSMutableArray<LXSpotifyArtworkDataHandler> *pendingHandlers = [NSMutableArray array];
    LXSpotifyArtworkLoader *loader = [[LXSpotifyArtworkLoader alloc] initWithDataProvider:^(NSURL *artworkURL, LXSpotifyArtworkDataHandler handler) {
        [pendingHandlers addObject:handler];
    }];
    LXSpotifyTrack *firstTrack = [self makeTrackWithIdentifier:@"spotify:track:one" artworkURLString:LXSpotifyArtworkLoaderTestsURL];
    LXSpotifyTrack *secondTrack = [self makeTrackWithIdentifier:@"spotify:track:two" artworkURLString:LXSpotifyArtworkLoaderTestsURL];
    NSMutableArray<LXSpotifyTrack *> *reportedTracks = [NSMutableArray array];
    XCTestExpectation *secondReported = [self expectationWithDescription:@"second cover reported"];

    [loader loadArtworkForTrack:firstTrack completion:^(LXSpotifyTrack *loadedTrack) {
        [reportedTracks addObject:loadedTrack];
    }];
    [loader loadArtworkForTrack:secondTrack completion:^(LXSpotifyTrack *loadedTrack) {
        [reportedTracks addObject:loadedTrack];
        [secondReported fulfill];
    }];
    XCTAssertEqual(pendingHandlers.count, 2);
    pendingHandlers[0](coverData);
    pendingHandlers[1](coverData);

    [self waitForExpectations:@[secondReported] timeout:2];
    XCTAssertEqualObjects(reportedTracks, @[secondTrack]);
    XCTAssertNil(firstTrack.artwork);
    XCTAssertNotNil(secondTrack.artwork);
}

- (void)testATrackWithoutACoverURLIsNotRequested {
    __block NSUInteger requestCount = 0;
    LXSpotifyArtworkLoader *loader = [[LXSpotifyArtworkLoader alloc] initWithDataProvider:^(NSURL *artworkURL, LXSpotifyArtworkDataHandler handler) {
        requestCount += 1;
        handler(nil);
    }];
    LXSpotifyTrack *track = [self makeTrackWithIdentifier:@"spotify:track:one" artworkURLString:nil];

    [loader loadArtworkForTrack:track completion:^(LXSpotifyTrack *loadedTrack) {
        XCTFail(@"nothing to report without a cover URL");
    }];

    XCTAssertEqual(requestCount, 0);
    XCTAssertNil(track.artwork);
}

@end
