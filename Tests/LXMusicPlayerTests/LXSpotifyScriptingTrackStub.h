//
//  LXSpotifyScriptingTrackStub.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Stands in for Spotify's `SpotifyTrack` scripting object. `LXScriptingTrack`
/// only ever reaches the scripting object through `respondsToSelector:` and
/// key-value coding, so a plain object that answers the same selectors with
/// the values Spotify really sends is enough to drive the adapter without a
/// running Spotify.
@interface LXSpotifyScriptingTrackStub : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier
              durationMilliseconds:(NSInteger)durationMilliseconds
                  artworkURLString:(nullable NSString *)artworkURLString;

/// Spotify names the track's identifier `id`, so the selector has to match.
- (NSString *)id;
- (NSString *)name;
- (NSString *)artist;
- (NSString *)album;
/// Spotify's dictionary calls this seconds; the application answers milliseconds.
- (NSInteger)duration;
- (nullable NSString *)artworkUrl;

@end

NS_ASSUME_NONNULL_END
