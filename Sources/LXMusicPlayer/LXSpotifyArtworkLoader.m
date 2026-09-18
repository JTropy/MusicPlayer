//
//  LXSpotifyArtworkLoader.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

#import <AppKit/AppKit.h>
#import <stdatomic.h>
#import "LXSpotifyArtworkLoader.h"

@implementation LXSpotifyArtworkLoader {
    LXSpotifyArtworkDataProvider _dataProvider;
    /// Bumped by every request and by `cancel`, so a delivery can tell whether
    /// it is still the one wanted. Requests may start on the player's polling
    /// queue while deliveries land on the main queue.
    _Atomic(NSUInteger) _generation;
}

- (instancetype)init {
    return [self initWithDataProvider:^(NSURL *artworkURL, LXSpotifyArtworkDataHandler handler) {
        NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:artworkURL
                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            handler(error == nil ? data : nil);
        }];
        [task resume];
    }];
}

- (instancetype)initWithDataProvider:(LXSpotifyArtworkDataProvider)dataProvider {
    if ((self = [super init])) {
        _dataProvider = [dataProvider copy];
        atomic_init(&_generation, 0);
    }
    return self;
}

- (void)loadArtworkForTrack:(LXSpotifyTrack *)track completion:(void (^)(LXSpotifyTrack *))completion {
    NSUInteger generation = atomic_fetch_add(&_generation, 1) + 1;
    NSURL *artworkURL = track.artworkURL;
    if (artworkURL == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    _dataProvider(artworkURL, ^(NSData *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) strongSelf = weakSelf;
            if (strongSelf == nil || atomic_load(&strongSelf->_generation) != generation) {
                return;
            }
            NSImage *image = data != nil ? [[NSImage alloc] initWithData:data] : nil;
            if (image == nil) {
                return;
            }
            track.artwork = image;
            completion(track);
        });
    });
}

- (void)cancel {
    atomic_fetch_add(&_generation, 1);
}

@end

#endif
