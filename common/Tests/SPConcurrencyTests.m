//
//  SPConcurrencyTests.m
//  CocoaLibSpotify iOS Library
//
//  Created by Daniel Kennett on 23/05/2012.
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

#import "SPConcurrencyTests.h"
#import "SPSession.h"
#import "SPAlbum.h"
#import "SPArtist.h"
#import "SPImage.h"
#import "SPPlaylist.h"
#import "SPTrack.h"
#import "SPUser.h"
#import "TestConstants.h"

@implementation SPConcurrencyTests

-(void)testSessionPropertyCallbacks {

	SPAssertTestCompletesInTimeInterval(kDefaultNonAsyncLoadingTestTimeout);

	// Ensure all block properties come back on the main queue
	SPSession *session = [SPSession sharedSession];

	[session fetchOfflineKeyTimeRemaining:^(NSTimeInterval remainingTime) {
		SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"OfflineKeyTimeRemaining callback on wrong queue.");

    [session fetchLoginUserName:^(NSString *loginUserName) {
      SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"FetchLoginUserName callback on wrong queue.");
      SPPassTest();
		}];
	}];
}

-(void)testInvalidGetterCallbacks {

	SPAssertTestCompletesInTimeInterval(kDefaultNonAsyncLoadingTestTimeout);
	
	// Ensure all blocks come back on the main queue
	SPSession *session = [SPSession sharedSession];
	
	[session albumForURL:nil callback:^(SPAlbum *album) {
		SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"albumForURL callback on wrong queue.");
		SPTestAssert(album == nil, @"Album callback with nil URL gave %@", album);
		
		[session artistForURL:nil callback:^(SPArtist *artist) {
			SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"artistForURL callback on wrong queue.");
			SPTestAssert(artist == nil, @"Artist callback with nil URL gave %@", artist);
			
			[session imageForURL:nil callback:^(SPImage *image) {
				SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"imageForURL callback on wrong queue.");
				SPTestAssert(image == nil, @"Image callback with nil URL gave %@", image);
				
				[session playlistForURL:nil callback:^(SPPlaylist *playlist) {
					SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"playlistForURL callback on wrong queue.");
					SPTestAssert(playlist == nil, @"Playlist callback with nil URL gave %@", playlist);

					[session searchForURL:nil callback:^(SPSearch *search) {
						SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"searchForURL callback on wrong queue.");
						SPTestAssert(search == nil, @"Search callback with nil URL gave %@", search);

						[session trackForURL:nil callback:^(SPTrack *track) {
							SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"trackForURL callback on wrong queue.");
							SPTestAssert(track == nil, @"Track callback with nil URL gave %@", track);

							[session userForURL:nil callback:^(SPUser *user) {
								SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"userForURL callback on wrong queue.");
								SPTestAssert(user == nil, @"User callback with nil URL gave %@", user);
								
								[session objectRepresentationForSpotifyURL:nil callback:^(sp_linktype linkType, id objectRepresentation) {
									SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"objectRepresentationForSpotifyURL callback on wrong queue.");
									SPTestAssert(objectRepresentation == nil, @"Object representation callback with nil URL gave %@", objectRepresentation);
									SPTestAssert(linkType == SP_LINKTYPE_INVALID, @"Object representation callback with nil URL gave linktype of %lu", linkType);
									SPPassTest();
								}];							
							}];
						}];
					}];
				}];
			}];
		}];
	}];
}

-(void)testValidGetterCallbacks {

	SPAssertTestCompletesInTimeInterval(kDefaultNonAsyncLoadingTestTimeout);
	
	// Ensure all blocks come back on the main queue
	SPSession *session = [SPSession sharedSession];
	
	[session albumForURL:[NSURL URLWithString:kAlbumLoadingTestURI] callback:^(SPAlbum *album) {
		SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"albumForURL callback on wrong queue.");
		SPTestAssert(album != nil, @"Album callback with valid URL gave nil");
		
		[session artistForURL:[NSURL URLWithString:kArtistLoadingTestURI] callback:^(SPArtist *artist) {
			SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"artistForURL callback on wrong queue.");
			SPTestAssert(artist != nil, @"Artist callback with valid URL gave nil");
			
			[session imageForURL:[NSURL URLWithString:kImageLoadingTestURI] callback:^(SPImage *image) {
				SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"imageForURL callback on wrong queue.");
				SPTestAssert(image != nil, @"Image callback with valid URL gave nil");
				
				[session playlistForURL:[NSURL URLWithString:kPlaylistLoadingTestURI] callback:^(SPPlaylist *playlist) {
					SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"playlistForURL callback on wrong queue.");
					SPTestAssert(playlist != nil, @"Playlist callback with valid URL gave nil");
					
					[session searchForURL:[NSURL URLWithString:kSearchLoadingTestURI] callback:^(SPSearch *search) {
						SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"searchForURL callback on wrong queue.");
						SPTestAssert(search != nil, @"Search callback with valid URL gave nil");
						
						[session trackForURL:[NSURL URLWithString:kTrackLoadingTestURI] callback:^(SPTrack *track) {
							SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"trackForURL callback on wrong queue.");
							SPTestAssert(track != nil, @"Track callback with valid URL gave nil");
							
							[session userForURL:[NSURL URLWithString:kUserLoadingTestURI] callback:^(SPUser *user) {
								SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"userForURL callback on wrong queue.");
								SPTestAssert(user != nil, @"User callback with valid URL gave nil");
								
								[session objectRepresentationForSpotifyURL:[NSURL URLWithString:kTrackLoadingTestURI] callback:^(sp_linktype linkType, id objectRepresentation) {
									SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"objectRepresentationForSpotifyURL callback on wrong queue.");
									SPTestAssert(objectRepresentation != nil, @"Object representation callback with valid URL gave nil");
									SPTestAssert(linkType != SP_LINKTYPE_INVALID, @"Object representation callback with valid URL gave linktype of %lu", linkType);
									SPPassTest();
								}];							
							}];
						}];
					}];
				}];
			}];
		}];
	}];
}

-(void)testInvalidConstructorCallbacks {

	SPAssertTestCompletesInTimeInterval(kDefaultNonAsyncLoadingTestTimeout);
	
	// Ensure all blocks come back on the main queue
	SPSession *session = [SPSession sharedSession];
	
	[SPAlbum albumWithAlbumURL:nil inSession:session callback:^(SPAlbum *album) {
		SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"albumWithAlbumURL callback on wrong queue.");
		SPTestAssert(album == nil, @"Album callback with nil URL gave %@", album);
		
		[SPArtist artistWithArtistURL:nil inSession:session callback:^(SPArtist *artist) {
			SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"artistWithArtistURL callback on wrong queue.");
			SPTestAssert(artist == nil, @"Artist callback with nil URL gave %@", artist);
			
			[SPImage imageWithImageURL:nil inSession:session callback:^(SPImage *image) {
				SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"imageWithImageURL callback on wrong queue.");
				SPTestAssert(image == nil, @"Image callback with nil URL gave %@", image);
				
				[SPPlaylist playlistWithPlaylistURL:nil inSession:session callback:^(SPPlaylist *playlist) {
					SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"playlistWithPlaylistURL callback on wrong queue.");
					SPTestAssert(playlist == nil, @"Playlist callback with nil URL gave %@", playlist);
					
					[SPTrack trackForTrackURL:nil inSession:session callback:^(SPTrack *track) {
						SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"trackForTrackURL callback on wrong queue.");
						SPTestAssert(track == nil, @"Track callback with nil URL gave %@", track);
						
						[SPUser userWithURL:nil inSession:session callback:^(SPUser *user) {
							SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"userWithURL callback on wrong queue.");
							SPTestAssert(user == nil, @"User callback with nil URL gave %@", user);
							SPPassTest();
						}];
					}];
				}];
			}];
		}];
	}];
}

-(void)testValidConstructorCallbacks {

	SPAssertTestCompletesInTimeInterval(kDefaultNonAsyncLoadingTestTimeout);
	
	// Ensure all blocks come back on the main queue
	SPSession *session = [SPSession sharedSession];
	
	[SPAlbum albumWithAlbumURL:[NSURL URLWithString:kAlbumLoadingTestURI] inSession:session callback:^(SPAlbum *album) {
		SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"albumForURL callback on wrong queue.");
		SPTestAssert(album != nil, @"Album callback with valid URL gave nil");
		
		[SPArtist artistWithArtistURL:[NSURL URLWithString:kArtistLoadingTestURI] inSession:session callback:^(SPArtist *artist) {
			SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"artistForURL callback on wrong queue.");
			SPTestAssert(artist != nil, @"Artist callback with valid URL gave nil");
			
			[SPImage imageWithImageURL:[NSURL URLWithString:kImageLoadingTestURI] inSession:session callback:^(SPImage *image) {
				SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"imageForURL callback on wrong queue.");
				SPTestAssert(image != nil, @"Image callback with valid URL gave nil");
				
				[SPPlaylist playlistWithPlaylistURL:[NSURL URLWithString:kPlaylistLoadingTestURI] inSession:session callback:^(SPPlaylist *playlist) {
					SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"playlistForURL callback on wrong queue.");
					SPTestAssert(playlist != nil, @"Playlist callback with valid URL gave nil");
					
					[SPTrack trackForTrackURL:[NSURL URLWithString:kTrackLoadingTestURI] inSession:session callback:^(SPTrack *track) {
						SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"trackForURL callback on wrong queue.");
						SPTestAssert(track != nil, @"Track callback with valid URL gave nil");
						
						[SPUser userWithURL:[NSURL URLWithString:kUserLoadingTestURI] inSession:session callback:^(SPUser *user) {
							SPTestAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"userForURL callback on wrong queue.");
							SPTestAssert(user != nil, @"User callback with valid URL gave nil");
							SPPassTest();						
						}];
					}];
				}];
			}];
		}];
	}];
}

@end
