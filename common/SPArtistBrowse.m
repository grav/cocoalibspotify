//
//  SPArtistBrowse.m
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 4/24/11.
/*
 Copyright 2013 Spotify AB

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

// IMPORTANT: This class was implemented while enjoying a lovely spring afternoon by a lake 
// in Sweden. This is my view right now:  http://twitpic.com/4oy9zn

#import "SPArtistBrowse.h"
#import "SPErrorExtensions.h"
#import "SPTrack.h"
#import "SPAlbum.h"
#import "SPArtist.h"
#import "SPImage.h"
#import "SPSession.h"

@interface SPArtistBrowse ()

@property (nonatomic, readwrite, getter=isLoaded) BOOL loaded;
@property (nonatomic, readwrite, copy) NSError *loadError;
@property (nonatomic, readwrite, strong) SPArtist *artist;
@property (nonatomic, readwrite, strong) SPSession *session;

@property (nonatomic, readwrite, strong) NSArray *portraits;

@property (nonatomic, readwrite, strong) NSArray *topTracks;
@property (nonatomic, readwrite, strong) NSArray *albums;
@property (nonatomic, readwrite, strong) NSArray *relatedArtists;

@property (nonatomic, readwrite, copy) NSString *biography;

@property (nonatomic, readwrite) sp_artistbrowse *artistBrowse;

@end

void artistbrowse_complete(sp_artistbrowse *result, void *userdata);
void artistbrowse_complete(sp_artistbrowse *result, void *userdata) {
	
	@autoreleasepool {
		
		// This is on the libSpotify thread
		
		SPArtistBrowse *artistBrowse = (__bridge_transfer SPArtistBrowse *)userdata;
		
		BOOL isLoaded = sp_artistbrowse_is_loaded(result);
		sp_error errorCode = sp_artistbrowse_error(result);
		NSError *error = errorCode == SP_ERROR_OK ? nil : [NSError spotifyErrorWithCode:errorCode];
		
		NSString *newBio = nil;
		NSArray *newTopTracks = nil;
		NSArray *newRelatedArtists = nil;
		NSArray *newAlbums = nil;
		NSArray *newPortraits = nil;
		
		if (isLoaded) {
			
			newBio = [NSString stringWithUTF8String:sp_artistbrowse_biography(result)];

			int topTrackCount = sp_artistbrowse_num_tophit_tracks(result);
			NSMutableArray *topTracks = [NSMutableArray arrayWithCapacity:topTrackCount];
			for (int currentTopTrack =  0; currentTopTrack < topTrackCount; currentTopTrack++) {
				sp_track *track = sp_artistbrowse_tophit_track(result, currentTopTrack);
				if (track != NULL) {
					[topTracks addObject:[SPTrack trackForTrackStruct:track inSession:artistBrowse.session]];
				}
			}
			
			newTopTracks = [NSArray arrayWithArray:topTracks];
			
			int albumCount = sp_artistbrowse_num_albums(result);
			NSMutableArray *albums = [NSMutableArray arrayWithCapacity:albumCount];
			for (int currentAlbum =  0; currentAlbum < albumCount; currentAlbum++) {
				sp_album *album = sp_artistbrowse_album(result, currentAlbum);
				if (album != NULL) {
					[albums addObject:[SPAlbum albumWithAlbumStruct:album inSession:artistBrowse.session]];
				}
			}
			
			newAlbums = [NSArray arrayWithArray:albums];
			
			int relatedArtistCount = sp_artistbrowse_num_similar_artists(result);
			NSMutableArray *relatedArtists = [NSMutableArray arrayWithCapacity:relatedArtistCount];
			for (int currentArtist =  0; currentArtist < relatedArtistCount; currentArtist++) {
				sp_artist *artist = sp_artistbrowse_similar_artist(result, currentArtist);
				if (artist != NULL) {
					[relatedArtists addObject:[SPArtist artistWithArtistStruct:artist inSession:artistBrowse.session]];
				}
			}
			
			newRelatedArtists = [NSArray arrayWithArray:relatedArtists];
			
			int portraitCount = sp_artistbrowse_num_portraits(result);
			NSMutableArray *portraits = [NSMutableArray arrayWithCapacity:portraitCount];
			for (int currentPortrait =  0; currentPortrait < portraitCount; currentPortrait++) {
				const byte *portraitId = sp_artistbrowse_portrait(result, currentPortrait);
				SPImage *portrait = [SPImage imageWithImageId:portraitId inSession:artistBrowse.session];
				if (portrait != nil) {
					[portraits addObject:portrait];
				}
			}
			
			newPortraits = [NSArray arrayWithArray:portraits];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			artistBrowse.loadError = error;
			artistBrowse.biography = newBio;
			artistBrowse.relatedArtists = newRelatedArtists;
			artistBrowse.albums = newAlbums;
			artistBrowse.portraits = newPortraits;
			artistBrowse.topTracks = newTopTracks;
			artistBrowse.loaded = isLoaded;
		});
	}
}

@implementation SPArtistBrowse

+(SPArtistBrowse *)browseArtist:(SPArtist *)anArtist inSession:(SPSession *)aSession type:(sp_artistbrowse_type)browseMode {
	return [[SPArtistBrowse alloc] initWithArtist:anArtist
										inSession:aSession
											 type:browseMode];
}

+(void)browseArtistAtURL:(NSURL *)artistURL inSession:(SPSession *)aSession type:(sp_artistbrowse_type)browseMode callback:(void (^)(SPArtistBrowse *artistBrowse))block {
	
	[SPArtist artistWithArtistURL:artistURL inSession:aSession callback:^(SPArtist *artist) {
		if (block) dispatch_async(dispatch_get_main_queue(), ^() { block([[SPArtistBrowse alloc] initWithArtist:artist inSession:aSession type:browseMode]); });
	}];
}

-(id)initWithArtist:(SPArtist *)anArtist inSession:(SPSession *)aSession type:(sp_artistbrowse_type)browseMode {
	
	if (anArtist == nil || aSession == nil) {
		return nil;
	}
	
	if ((self = [super init])) {
		self.session = aSession;
		self.artist = anArtist;
		
		SPDispatchAsync(^{
			self.artistBrowse = sp_artistbrowse_create(aSession.session,
													   anArtist.artist,
													   browseMode,
													   &artistbrowse_complete,
													   (__bridge_retained void *)(self));
		});
	}
	
	return self;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@: %@", [super description], self.artist];
}

-(sp_artistbrowse *)artistBrowse {
#if DEBUG
	SPAssertOnLibSpotifyThread();
#endif 
	return _artistBrowse;
}

+(NSSet *)keyPathsForValuesAffectingFirstPortrait {
	return [NSSet setWithObject:@"portraits"];
}

-(SPImage *)firstPortrait {
	if (self.portraits.count > 0) {
		return [self.portraits objectAtIndex:0];
	}
	return nil;
}

- (void)dealloc {
	sp_artistbrowse *outgoing_browse = _artistBrowse;
	_artistBrowse = NULL;
	if (outgoing_browse) SPDispatchAsync(^() { sp_artistbrowse_release(outgoing_browse); });
}

@end
