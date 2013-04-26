//
//  SPPlaylist.h
//  CocoaLibSpotify
//
//  Created by Daniel Kennett on 2/14/11.
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

/** This class represents a list of items, be it a user's starred list, inbox, or a traditional "playlist". */

#import <Foundation/Foundation.h>
#import "CocoaLibSpotifyPlatformImports.h"

@class SPUser;
@class SPImage;
@class SPSession;
@protocol SPPlaylistDelegate;

@interface SPPlaylist : NSObject <SPPlaylistableItem, SPAsyncLoading, SPDelayableAsyncLoading, SPPartialAsyncLoading>

///----------------------------
/// @name Creating and Initializing Playlists
///----------------------------

/** Creates an SPPlaylist from the given opaque sp_playlist struct. 
 
 This convenience method creates an SPPlaylist object if one doesn't exist, or 
 returns a cached SPPlaylist if one already exists for the given struct.
 
 @param pl The sp_playlist struct to create an SPPlaylist for.
 @param aSession The SPSession the playlist should exist in.
 @return Returns the created SPPlaylist object. 
 */
+(SPPlaylist *)playlistWithPlaylistStruct:(sp_playlist *)pl inSession:(SPSession *)aSession;

/** Creates an SPPlaylist from the given Spotify playlist URL. 
 
 This convenience method creates an SPPlaylist object if one doesn't exist, or 
 returns a cached SPPlaylist if one already exists for the given URL.
 
 @warning If you pass in an invalid playlist URL (i.e., any URL not
 starting `spotify:user:XXXX:playlist:`, this method will return `nil`.

 @param playlistURL The playlist URL to create an SPPlaylist for.
 @param aSession The SPSession the playlist should exist in.
 @param block The block to be called with the created SPPlaylist object. 
 */
+(void)playlistWithPlaylistURL:(NSURL *)playlistURL inSession:(SPSession *)aSession callback:(void (^)(SPPlaylist *playlist))block;

/** Initializes an SPPlaylist from the given opaque sp_playlist struct. 
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @warning For better performance and built-in caching, it is recommended
 you create SPPlaylist objects using +[SPPlaylist playlistWithPlaylistStruct:inSession:], 
 +[SPPlaylist playlistWithPlaylistURL:inSession:callback:] or the instance methods on SPSession.
 
 @param pl The sp_playlist struct to create an SPPlaylist for.
 @param aSession The SPSession the playlist should exist in.
 @return Returns the created SPPlaylist object. 
 */
-(id)initWithPlaylistStruct:(sp_playlist *)pl inSession:(SPSession *)aSession;

///----------------------------
/// @name Properties
///----------------------------

/** Returns the playlist's delegate object. */
@property (nonatomic, readwrite, weak) id <SPPlaylistDelegate> delegate;

/** Returns `YES` if the playlist has changes not yet recognised by the Spotify servers, otherwise `NO`. */
@property (nonatomic, readonly) BOOL hasPendingChanges;

/** Returns `YES` if the playlist is collaborative (can be edited by users other than the owner), otherwise `NO`. */
@property (nonatomic, readwrite, getter=isCollaborative) BOOL collaborative;

/** Returns `YES` if the playlist has finished loading and all data is available. */ 
@property (nonatomic, readonly, getter=isLoaded) BOOL loaded;

/** Returns `YES` if the playlist is marked for offline playback. */
@property (nonatomic, readwrite, getter=isMarkedForOfflinePlayback) BOOL markedForOfflinePlayback;

/** Returns `YES` if the playlist is being updated, otherwise `NO`. 
 
 Typically, you should delay UI updates while this property is set to `YES`.
 */ 
@property (nonatomic, readonly, getter=isUpdating) BOOL updating;

/** Returns the download progress of the playlist (between 0 and 1) is it is marked for offline sync. */
@property (nonatomic, readonly) float offlineDownloadProgress;

/** Returns the offline status of the playlist. Possible values:
 
 SP_PLAYLIST_OFFLINE_STATUS_NO 	
 Playlist is not offline enabled.
 
 SP_PLAYLIST_OFFLINE_STATUS_YES 	
 Playlist is synchronized to local storage.
 
 SP_PLAYLIST_OFFLINE_STATUS_DOWNLOADING 	
 This playlist is currently downloading. Only one playlist can be in this state any given time.
 
 SP_PLAYLIST_OFFLINE_STATUS_WAITING 	
 Playlist is queued for download.
 */
@property (nonatomic, readonly) sp_playlist_offline_status offlineStatus;

/** Returns the owner of the playlist, or `nil` if the playlist hasn't loaded yet. */
@property (nonatomic, readonly, strong) SPUser *owner;

/** Returns the opaque structure used by the C LibSpotify API. 
 
 @warning This method *must* be called on the libSpotify thread. See the
 "Threading" section of the library's readme for more information.
 
 @warning This should only be used if you plan to directly use the 
 C LibSpotify API. The behaviour of CocoaLibSpotify is undefined if you use the C
 API directly on items that have CocoaLibSpotify objects associated with them. 
 */
@property (nonatomic, readonly) sp_playlist *playlist;

/** Returns the session object the playlist is loaded in. */
@property (nonatomic, readonly, weak) SPSession *session;

/** Returns the Spotify URI of the playlist profile, for example: `spotify:user:sarnesjo:playlist:3p2c7mmML3fIUh5fcZ8Hcq` */
@property (nonatomic, readonly, copy) NSURL *spotifyURL;

/** Returns the subscribers to the playlist as an array of Spotify usernames. */
@property (nonatomic, readonly, strong) NSArray *subscribers;

///----------------------------
/// @name Metadata
///----------------------------

/** Returns the custom image for the playlist, or `nil` if the playlist hasn't loaded yet or it doesn't have a custom image. */
@property (nonatomic, readonly, strong) SPImage *image;

/** Returns the name of the playlist, or `nil` if the playlist hasn't loaded yet. */
@property (nonatomic, readwrite, copy) NSString *name;

/** Returns the custom description for the playlist, or `nil` if the playlist hasn't loaded yet or it doesn't have a custom description. */
@property (nonatomic, readonly, copy) NSString *playlistDescription;

///----------------------------
/// @name Working with Items
///----------------------------

/* Returns the number of items in the playlist. */
@property (nonatomic, readonly) NSUInteger itemCount;

/** Fetch the playlist's items in the given range.
 
 @note It's generally not a good idea to blindly request all the items in a
 playlist without good reason as playlists can get *very* large and memory
 usage is a concern on mobile devices. If you're implementing a table view, 
 for instance, it's a better idea to only request the visible items plus a screen
 or so of rows each way. See the `Playlist TableViews` example project to see
 this in action.
 
 @param range The range of items to retreive. Must be in the range [0..itemCount].
 @param block Callback to be called with the requested items, or an error if one occurred.
 */
-(void)fetchItemsInRange:(NSRange)range callback:(void (^)(NSError *error, NSArray *items))block;

/** Move item(s) to another location in the list. 
 
 All indexes are given relative to the state of the item order before the move is executed. Therefore, you
 *don't* need to adjust the destination index to take into account items that will be moved from above it.
 
 @warning This operation can fail, for example if you give invalid indexes. Please make sure 
 you check the result of this method.
 
 @param indexes The indexes of the items to move.
 @param newLocation The index the items should be moved to.
 @param block The `SPErrorableOperationCallback` block to be called with an `NSError` if the operation failed or `nil` if the operation succeeded.
 */
-(void)moveItemsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)newLocation callback:(SPErrorableOperationCallback)block;

/** Add an item to the playlist at the given location.
 
 @warning This operation can fail, for example if you give invalid indexes. Please make sure 
 you check the result of this method.
 
 @param item The item to add.
 @param index The target index for the item. Must be within the range 0..`playlist.length`.
 @param block The `SPErrorableOperationCallback` block to be called with an `NSError` if the operation failed or `nil` if the operation succeeded.
 */
-(void)addItem:(SPTrack *)item atIndex:(NSUInteger)index callback:(SPErrorableOperationCallback)block;

/** Add items to the playlist at the given location.
 
 @warning This operation can fail, for example if you give invalid indexes. Please make sure 
 you check the result of this method.
 
 @param items An array of `SPTrack` objects to add.
 @param index The target index for the items. Must be within the range 0..`playlist.length`.
 @param block The `SPErrorableOperationCallback` block to be called with an `NSError` if the operation failed or `nil` if the operation succeeded.
 */
-(void)addItems:(NSArray *)items atIndex:(NSUInteger)index callback:(SPErrorableOperationCallback)block;


/** Remove an item from the playlist at the given location.
 
 @warning This operation can fail, for example if you give invalid indexes. Please make sure 
 you check the result of this method.
 
 @param index The target index for the item. Must be a valid index.
 @param block The `SPErrorableOperationCallback` block to be called with an `NSError` if the operation failed or `nil` if the operation succeeded.
 */
-(void)removeItemAtIndex:(NSUInteger)index callback:(SPErrorableOperationCallback)block;

@end

/** Delegate callbacks from SPPlaylist to help with item reordering. */

@protocol SPPlaylistDelegate <NSObject>
@optional

/** Called when one or more items in the playlist updated their metadata. 
 
 @param aPlaylist The playlist in which items updated their metadata.
 */
-(void)itemsInPlaylistDidUpdateMetadata:(SPPlaylist *)aPlaylist;

///----------------------------
/// @name Item Removal
///----------------------------

/** Called after one or more items in the playlist were removed from the playlist. 
 
 @warning The index set passed to this method is not valid for the given items since they've been removed.
 
 @param aPlaylist The playlist in which items were removed.
 @param theseIndexesArentValidAnymore The (now invalid) indexes of the items.
 */
-(void)playlist:(SPPlaylist *)aPlaylist didRemoveItemsAtIndexes:(NSIndexSet *)theseIndexesArentValidAnymore;

///----------------------------
/// @name Item Addition
///----------------------------

/** Called after one or more items are added to the playlist. 
 
 @param aPlaylist The playlist in which items were added.
 @param newIndexes The destination indexes of the items.
 */
-(void)playlist:(SPPlaylist *)aPlaylist didAddItemsAtIndexes:(NSIndexSet *)newIndexes;

///----------------------------
/// @name Item Reordering
///----------------------------

/** Called after one or more items are moved within the playlist.
 
 @param aPlaylist The playlist in which items will be moved.
 @param oldIndexes The (invalid) old indexes of the items.
 @param newIndexes The now current indexes of the items.
 */
-(void)playlist:(SPPlaylist *)aPlaylist didMoveItemsAtIndexes:(NSIndexSet *)oldIndexes toIndexes:(NSIndexSet *)newIndexes;

///----------------------------
/// @name Other Changes
///----------------------------

/** Called after a change that isn't a simple add, remove or move operation to the items in the playlist.

 @param aPlaylist The playlist in which items will be changed.
 */
-(void)playlistDidChangeItems:(SPPlaylist *)aPlaylist;

@end