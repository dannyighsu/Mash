#import "protos/Mashservice.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"mash.mashservice";
static NSString *const kServiceName = @"MashService";

@implementation MashService

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  return (self = [super initWithHost:host packageName:kPackageName serviceName:kServiceName]);
}

// Override superclass initializer to disallow different package and service names.
- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName {
  return [self initWithHost:host];
}

+ (instancetype)serviceWithHost:(NSString *)host {
  return [[self alloc] initWithHost:host];
}


#pragma mark Register(RegisterRequest) returns (RegisterResponse)

- (void)registerWithRequest:(RegisterRequest *)request handler:(void(^)(RegisterResponse *response, NSError *error))handler{
  [[self RPCToRegisterWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRegisterWithRequest:(RegisterRequest *)request handler:(void(^)(RegisterResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"Register"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[RegisterResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SignIn(SignInRequest) returns (SignInResponse)

- (void)signInWithRequest:(SignInRequest *)request handler:(void(^)(SignInResponse *response, NSError *error))handler{
  [[self RPCToSignInWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToSignInWithRequest:(SignInRequest *)request handler:(void(^)(SignInResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"SignIn"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SignInResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SignOut(UserRequest) returns (SuccessResponse)

- (void)signOutWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToSignOutWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToSignOutWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"SignOut"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UserGet(UserRequest) returns (UserResponse)

- (void)userGetWithRequest:(UserRequest *)request handler:(void(^)(UserResponse *response, NSError *error))handler{
  [[self RPCToUserGetWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserGetWithRequest:(UserRequest *)request handler:(void(^)(UserResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"UserGet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[UserResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark RecordingGet(RecordingRequest) returns (RecordingResponse)

- (void)recordingGetWithRequest:(RecordingRequest *)request handler:(void(^)(RecordingResponse *response, NSError *error))handler{
  [[self RPCToRecordingGetWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingGetWithRequest:(RecordingRequest *)request handler:(void(^)(RecordingResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingGet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[RecordingResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark FollowersGet(UserRequest) returns (UserPreviews)

- (void)followersGetWithRequest:(UserRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler{
  [[self RPCToFollowersGetWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToFollowersGetWithRequest:(UserRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler{
  return [self RPCToMethod:@"FollowersGet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[UserPreviews class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark FollowingsGet(UserRequest) returns (UserPreviews)

- (void)followingsGetWithRequest:(UserRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler{
  [[self RPCToFollowingsGetWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToFollowingsGetWithRequest:(UserRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler{
  return [self RPCToMethod:@"FollowingsGet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[UserPreviews class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UserDelete(UserRequest) returns (SuccessResponse)

- (void)userDeleteWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToUserDeleteWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserDeleteWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"UserDelete"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark RecordingDelete(RecordingRequest) returns (SuccessResponse)

- (void)recordingDeleteWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToRecordingDeleteWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingDeleteWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingDelete"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UserFollow(UserRequest) returns (SuccessResponse)

- (void)userFollowWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToUserFollowWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserFollowWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"UserFollow"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UserUnfollow(UserRequest) returns (SuccessResponse)

- (void)userUnfollowWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToUserUnfollowWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserUnfollowWithRequest:(UserRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"UserUnfollow"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark RecordingUpload(RecordingUploadRequest) returns (SuccessResponse)

- (void)recordingUploadWithRequest:(RecordingUploadRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToRecordingUploadWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingUploadWithRequest:(RecordingUploadRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingUpload"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark RecordingPlay(RecordingRequest) returns (SuccessResponse)

- (void)recordingPlayWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToRecordingPlayWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingPlayWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingPlay"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark RecordingLike(RecordingRequest) returns (SuccessResponse)

- (void)recordingLikeWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToRecordingLikeWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingLikeWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingLike"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark RecordingUnlike(RecordingRequest) returns (SuccessResponse)

- (void)recordingUnlikeWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToRecordingUnlikeWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingUnlikeWithRequest:(RecordingRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingUnlike"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark RecordingUpdate(RecordingUpdateRequest) returns (SuccessResponse)

- (void)recordingUpdateWithRequest:(RecordingUpdateRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToRecordingUpdateWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingUpdateWithRequest:(RecordingUpdateRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingUpdate"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UserUpdate(UserUpdateRequest) returns (SuccessResponse)

- (void)userUpdateWithRequest:(UserUpdateRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToUserUpdateWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserUpdateWithRequest:(UserUpdateRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"UserUpdate"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UserRecordings(UserRequest) returns (UserRecordingsResponse)

- (void)userRecordingsWithRequest:(UserRequest *)request handler:(void(^)(UserRecordingsResponse *response, NSError *error))handler{
  [[self RPCToUserRecordingsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserRecordingsWithRequest:(UserRequest *)request handler:(void(^)(UserRecordingsResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"UserRecordings"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[UserRecordingsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark Feed(FeedRequest) returns (FeedResponse)

- (void)feedWithRequest:(FeedRequest *)request handler:(void(^)(FeedResponse *response, NSError *error))handler{
  [[self RPCToFeedWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToFeedWithRequest:(FeedRequest *)request handler:(void(^)(FeedResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"Feed"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[FeedResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SearchTag(SearchTagRequest) returns (Recordings)

- (void)searchTagWithRequest:(SearchTagRequest *)request handler:(void(^)(Recordings *response, NSError *error))handler{
  [[self RPCToSearchTagWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToSearchTagWithRequest:(SearchTagRequest *)request handler:(void(^)(Recordings *response, NSError *error))handler{
  return [self RPCToMethod:@"SearchTag"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Recordings class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UserSearch(UserSearchRequest) returns (UserPreviews)

- (void)userSearchWithRequest:(UserSearchRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler{
  [[self RPCToUserSearchWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserSearchWithRequest:(UserSearchRequest *)request handler:(void(^)(UserPreviews *response, NSError *error))handler{
  return [self RPCToMethod:@"UserSearch"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[UserPreviews class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
