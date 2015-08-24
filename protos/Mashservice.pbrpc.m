#import "Protos/mashservice.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriteable.h>
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


#pragma mark Register(RegisterRequest) returns (RegisterResponse)

- (void)registerWithRequest:(RegisterRequest *)request handler:(void(^)(RegisterResponse *response, NSError *error))handler{
  [[self RPCToRegisterWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRegisterWithRequest:(RegisterRequest *)request handler:(void(^)(RegisterResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"Register"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[RegisterResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
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
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark UserGet(UserGetRequest) returns (UserGetResponse)

- (void)userGetWithRequest:(UserGetRequest *)request handler:(void(^)(UserGetResponse *response, NSError *error))handler{
  [[self RPCToUserGetWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserGetWithRequest:(UserGetRequest *)request handler:(void(^)(UserGetResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"UserGet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[UserGetResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark RecordingGet(RecordingInfoRequest) returns (RecordingGetResponse)

- (void)recordingGetWithRequest:(RecordingInfoRequest *)request handler:(void(^)(RecordingGetResponse *response, NSError *error))handler{
  [[self RPCToRecordingGetWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingGetWithRequest:(RecordingInfoRequest *)request handler:(void(^)(RecordingGetResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingGet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[RecordingGetResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark FollowersGet(FollowGetRequest) returns (FollowGetResponse)

- (void)followersGetWithRequest:(FollowGetRequest *)request handler:(void(^)(FollowGetResponse *response, NSError *error))handler{
  [[self RPCToFollowersGetWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToFollowersGetWithRequest:(FollowGetRequest *)request handler:(void(^)(FollowGetResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"FollowersGet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[FollowGetResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark FollowingsGet(FollowGetRequest) returns (FollowGetResponse)

- (void)followingsGetWithRequest:(FollowGetRequest *)request handler:(void(^)(FollowGetResponse *response, NSError *error))handler{
  [[self RPCToFollowingsGetWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToFollowingsGetWithRequest:(FollowGetRequest *)request handler:(void(^)(FollowGetResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"FollowingsGet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[FollowGetResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark UserDelete(UserDeleteRequest) returns (SuccessResponse)

- (void)userDeleteWithRequest:(UserDeleteRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToUserDeleteWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserDeleteWithRequest:(UserDeleteRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"UserDelete"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark RecordingDelete(RecordingInfoRequest) returns (SuccessResponse)

- (void)recordingDeleteWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToRecordingDeleteWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingDeleteWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingDelete"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark UserFollow(UserFollowRequest) returns (SuccessResponse)

- (void)userFollowWithRequest:(UserFollowRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToUserFollowWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserFollowWithRequest:(UserFollowRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"UserFollow"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark UserUnfollow(UserFollowRequest) returns (SuccessResponse)

- (void)userUnfollowWithRequest:(UserFollowRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToUserUnfollowWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToUserUnfollowWithRequest:(UserFollowRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"UserUnfollow"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
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
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark RecordingPlay(RecordingInfoRequest) returns (SuccessResponse)

- (void)recordingPlayWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToRecordingPlayWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingPlayWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingPlay"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark RecordingLike(RecordingInfoRequest) returns (SuccessResponse)

- (void)recordingLikeWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToRecordingLikeWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingLikeWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingLike"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
#pragma mark RecordingUnlike(RecordingInfoRequest) returns (SuccessResponse)

- (void)recordingUnlikeWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  [[self RPCToRecordingUnlikeWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToRecordingUnlikeWithRequest:(RecordingInfoRequest *)request handler:(void(^)(SuccessResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"RecordingUnlike"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SuccessResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
@end
