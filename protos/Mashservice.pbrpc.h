#import "Protos/mashservice.pbobjc.h"

#import <ProtoRPC/ProtoService.h>


@protocol GRXWriteable;
@protocol GRXWriter;

@protocol MashService <NSObject>

#pragma mark Register(RegisterRequest) returns (RegisterResponse)

- (void)registerWithRequest:(RegisterRequest *)request handler:(void(^)(RegisterResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRegisterWithRequest:(RegisterRequest *)request handler:(void(^)(RegisterResponse *response, NSError *error))handler;


#pragma mark SignIn(SignInRequest) returns (SignInResponse)

- (void)signInWithRequest:(SignInRequest *)request handler:(void(^)(SignInResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToSignInWithRequest:(SignInRequest *)request handler:(void(^)(SignInResponse *response, NSError *error))handler;


#pragma mark UserGet(UserGetRequest) returns (UserGetResponse)

- (void)userGetWithRequest:(UserGetRequest *)request handler:(void(^)(UserGetResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserGetWithRequest:(UserGetRequest *)request handler:(void(^)(UserGetResponse *response, NSError *error))handler;


#pragma mark RecordingGet(RecordingInfoRequest) returns (RecordingGetResponse)

- (void)recordingGetWithRequest:(RecordingInfoRequest *)request handler:(void(^)(RecordingGetResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingGetWithRequest:(RecordingInfoRequest *)request handler:(void(^)(RecordingGetResponse *response, NSError *error))handler;


#pragma mark FollowersGet(FollowGetRequest) returns (FollowGetResponse)

- (void)followersGetWithRequest:(FollowGetRequest *)request handler:(void(^)(FollowGetResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToFollowersGetWithRequest:(FollowGetRequest *)request handler:(void(^)(FollowGetResponse *response, NSError *error))handler;


#pragma mark FollowingsGet(FollowGetRequest) returns (FollowGetResponse)

- (void)followingsGetWithRequest:(FollowGetRequest *)request handler:(void(^)(FollowGetResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToFollowingsGetWithRequest:(FollowGetRequest *)request handler:(void(^)(FollowGetResponse *response, NSError *error))handler;


#pragma mark UserDelete(UserDeleteRequest) returns (SuccessResponse)

- (void)userDeleteWithRequest:(UserDeleteRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserDeleteWithRequest:(UserDeleteRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingDelete(RecordingInfoRequest) returns (SuccessResponse)

- (void)recordingDeleteWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingDeleteWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark UserFollow(UserFollowRequest) returns (SuccessResponse)

- (void)userFollowWithRequest:(UserFollowRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserFollowWithRequest:(UserFollowRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark UserUnfollow(UserFollowRequest) returns (SuccessResponse)

- (void)userUnfollowWithRequest:(UserFollowRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToUserUnfollowWithRequest:(UserFollowRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingUpload(RecordingUploadRequest) returns (SuccessResponse)

- (void)recordingUploadWithRequest:(RecordingUploadRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingUploadWithRequest:(RecordingUploadRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingPlay(RecordingInfoRequest) returns (SuccessResponse)

- (void)recordingPlayWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingPlayWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingLike(RecordingInfoRequest) returns (SuccessResponse)

- (void)recordingLikeWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingLikeWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


#pragma mark RecordingUnlike(RecordingInfoRequest) returns (SuccessResponse)

- (void)recordingUnlikeWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToRecordingUnlikeWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface MashService : ProtoService<MashService>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
@end
