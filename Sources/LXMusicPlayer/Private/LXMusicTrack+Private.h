//
//  LXMusicTrack+Private.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

#import "LXMusicTrack.h"
#import "Music.h"
#import "Spotify.h"
#import "Swinsian.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXScriptingTrack : LXMusicTrack

+ (nullable NSString *)persistentIDKey;
+ (nullable NSString *)titleKey;
+ (nullable NSString *)albumKey;
+ (nullable NSString *)artistKey;
+ (nullable NSString *)durationKey;
+ (nullable NSString *)fileURLKey;
+ (nullable NSString *)artworkKey;

+ (nullable NSString *)persistentIDForTrack:(SBObject *)sbTrack;

- (instancetype)initWithPersistentID:(NSString *)persistentID NS_UNAVAILABLE;
- (nullable instancetype)initWithSBTrack:(SBObject *)track NS_DESIGNATED_INITIALIZER;

@end

@interface LXAppleMusicTrack : LXScriptingTrack
@end

@interface LXSpotifyTrack : LXScriptingTrack

/// Where Spotify keeps the cover. Its `artwork` property is documented as
/// deprecated and never set; `artwork url` is what the application offers
/// instead, so the cover has to be fetched from here.
@property (nonatomic, readonly, nullable) NSURL *artworkURL;

@end

@interface LXSwinsianTrack : LXScriptingTrack
@end

NS_ASSUME_NONNULL_END

#endif
