//
//  LXSpotifyArtworkLoader.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import "LXMusicTrack+Private.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LXSpotifyArtworkDataHandler)(NSData *_Nullable data);
/// Performs one request for the bytes at `artworkURL` and hands them to
/// `handler`, on any queue. The default provider is `NSURLSession`; tests
/// supply the bytes directly.
typedef void (^LXSpotifyArtworkDataProvider)(NSURL *artworkURL, LXSpotifyArtworkDataHandler handler);

/// Fetches the cover Spotify points at through `artwork url` and stores it on
/// the track, because Spotify's own `artwork` property is deprecated and never
/// set. One cover is wanted at a time: asking for another track's cover drops
/// whatever an earlier request delivers later.
@interface LXSpotifyArtworkLoader : NSObject

- (instancetype)init;
- (instancetype)initWithDataProvider:(LXSpotifyArtworkDataProvider)dataProvider NS_DESIGNATED_INITIALIZER;

/// Requests the track's cover. `completion` runs on the main queue, and only
/// once an image has been stored on `track` while it is still the track most
/// recently asked for. A track without a cover URL is not requested at all.
- (void)loadArtworkForTrack:(LXSpotifyTrack *)track completion:(void (^)(LXSpotifyTrack *track))completion;

/// Drops whatever the outstanding request delivers.
- (void)cancel;

@end

NS_ASSUME_NONNULL_END

#endif
