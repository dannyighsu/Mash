#import "protos/LoadBalancer.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

static NSString *const kPackageName = @"Mash";
static NSString *const kServiceName = @"LoadBalancer";

@implementation LoadBalancer

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


#pragma mark GetServerAddress(ServerAddressRequest) returns (ServerAddressResponse)

- (void)getServerAddressWithRequest:(ServerAddressRequest *)request handler:(void(^)(ServerAddressResponse *response, NSError *error))handler{
  [[self RPCToGetServerAddressWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
- (ProtoRPC *)RPCToGetServerAddressWithRequest:(ServerAddressRequest *)request handler:(void(^)(ServerAddressResponse *response, NSError *error))handler{
  return [self RPCToMethod:@"GetServerAddress"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ServerAddressResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleValueHandler:handler]];
}
@end
