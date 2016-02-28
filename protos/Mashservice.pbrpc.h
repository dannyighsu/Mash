#import "protos/Mashservice.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>


@protocol MashService <NSObject>

#pragma mark Register(RegisterRequest) returns (RegisterResponse)

- (void)registerWithRequest:(RegisterRequest *)request handler:(void(^)(RegisterResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRegisterWithRequest:(RegisterRequest *)request handler:(void(^)(RegisterResponse *response, NSError *error))handler;


#pragma mark SignIn(SignInRequest) returns (SignInResponse)

- (void)signInWithRequest:(SignInRequest *)request handler:(void(^)(SignInResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToSignInWithRequest:(SignInRequest *)request handler:(void(^)(SignInResponse *response, NSError *error))handler;


#pragma mark SignOut(UserRequest) returns (SuccessResponse)

- (void)signOutWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToSignOutWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark UserGet(UserRequest) returns (UserResponse)

- (void)userGetWithRequest:(UserRequest *)request handler:(void(^)(UserResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserGetWithRequest:(UserRequest *)request handler:(void(^)(UserResponse *response, NSError *error))handler;


#pragma mark RecordingGet(RecordingRequest) returns (RecordingResponse)

- (void)recordingGetWithRequest:(RecordingRequest *)request handler:(void(^)(RecordingResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingGetWithRequest:(RecordingRequest *)request handler:(void(^)(RecordingResponse *response, NSError *error))handler;


#pragma mark FollowersGet(UserRequest) returns (UserPreviews)

- (void)followersGetWithRequest:(UserRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler;

- (ProtoRPC *)RPCToFollowersGetWithRequest:(UserRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler;


#pragma mark FollowingsGet(UserRequest) returns (UserPreviews)

- (void)followingsGetWithRequest:(UserRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler;

- (ProtoRPC *)RPCToFollowingsGetWithRequest:(UserRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler;


#pragma mark UserDelete(UserRequest) returns (SuccessResponse)

- (void)userDeleteWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserDeleteWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingDelete(RecordingRequest) returns (SuccessResponse)

- (void)recordingDeleteWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingDeleteWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark UserFollow(UserRequest) returns (SuccessResponse)

- (void)userFollowWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserFollowWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark UserUnfollow(UserRequest) returns (SuccessResponse)

- (void)userUnfollowWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserUnfollowWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingUpload(RecordingUploadRequest) returns (SuccessResponse)

- (void)recordingUploadWithRequest:(RecordingUploadRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingUploadWithRequest:(RecordingUploadRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingAnalyze(RecordingAnalyzeRequest) returns (SuccessResponse)

- (void)recordingAnalyzeWithRequest:(RecordingAnalyzeRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingAnalyzeWithRequest:(RecordingAnalyzeRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingPlay(RecordingRequest) returns (SuccessResponse)

- (void)recordingPlayWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingPlayWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingLike(RecordingRequest) returns (SuccessResponse)

- (void)recordingLikeWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingLikeWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingUnlike(RecordingRequest) returns (SuccessResponse)

- (void)recordingUnlikeWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingUnlikeWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingUpdate(RecordingUpdateRequest) returns (SuccessResponse)

- (void)recordingUpdateWithRequest:(RecordingUpdateRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingUpdateWithRequest:(RecordingUpdateRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark UserUpdate(UserUpdateRequest) returns (SuccessResponse)

- (void)userUpdateWithRequest:(UserUpdateRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserUpdateWithRequest:(UserUpdateRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark UserRecordings(UserRequest) returns (UserRecordingsResponse)

- (void)userRecordingsWithRequest:(UserRequest *)request handler:(void(^)(UserRecordingsResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserRecordingsWithRequest:(UserRequest *)request handler:(void(^)(UserRecordingsResponse *response, NSError *error))handler;


#pragma mark Feed(FeedRequest) returns (FeedResponse)

- (void)feedWithRequest:(FeedRequest *)request handler:(void(^)(FeedResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToFeedWithRequest:(FeedRequest *)request handler:(void(^)(FeedResponse *response, NSError *error))handler;


#pragma mark GlobalFeed(FeedRequest) returns (FeedResponse)

- (void)globalFeedWithRequest:(FeedRequest *)request handler:(void(^)(FeedResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToGlobalFeedWithRequest:(FeedRequest *)request handler:(void(^)(FeedResponse *response, NSError *error))handler;


#pragma mark SearchTag(SearchTagRequest) returns (Recordings)

- (void)searchTagWithRequest:(SearchTagRequest *)request handler:(void(^)(Recordings *response, NSError *error))handler;

- (ProtoRPC *)RPCToSearchTagWithRequest:(SearchTagRequest *)request handler:(void(^)(Recordings *response, NSError *error))handler;


#pragma mark UserSearch(UserSearchRequest) returns (UserPreviews)

- (void)userSearchWithRequest:(UserSearchRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserSearchWithRequest:(UserSearchRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler;


#pragma mark RecordingMash(RecordingRequest) returns (Recordings)

- (void)recordingMashWithRequest:(RecordingRequest *)request handler:(void(^)(Recordings *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingMashWithRequest:(RecordingRequest *)request handler:(void(^)(Recordings *response, NSError *error))handler;


#pragma mark Version(VersionRequest) returns (VersionResponse)

- (void)versionWithRequest:(VersionRequest *)request handler:(void(^)(VersionResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToVersionWithRequest:(VersionRequest *)request handler:(void(^)(VersionResponse *response, NSError *error))handler;


#pragma mark UserDevice(DeviceRequest) returns (SuccessResponse)

- (void)userDeviceWithRequest:(DeviceRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserDeviceWithRequest:(DeviceRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingLikers(RecordingRequest) returns (UserPreviews)

- (void)recordingLikersWithRequest:(RecordingRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingLikersWithRequest:(RecordingRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler;


#pragma mark RecordingAdd(RecordingRequest) returns (SuccessResponse)

- (void)recordingAddWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingAddWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark APNSend(APNServerRequest) returns (SuccessResponse)

- (void)aPNSendWithRequest:(APNServerRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToAPNSendWithRequest:(APNServerRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface MashService : ProtoService<MashService>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
@end
