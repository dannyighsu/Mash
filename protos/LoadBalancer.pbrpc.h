#import "protos/LoadBalancer.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>


@protocol LoadBalancer <NSObject>

#pragma mark GetServerAddress(ServerAddressRequest) returns (ServerAddressResponse)

- (void)getServerAddressWithRequest:(ServerAddressRequest *)request handler:(void(^)(ServerAddressResponse *response, NSError *error))handler;

- (ProtoRPC *)RPCToGetServerAddressWithRequest:(ServerAddressRequest *)request handler:(void(^)(ServerAddressResponse *response, NSError *error))handler;


@end

// Basic service implementation, over gRPC, that only does marshalling and parsing.
@interface LoadBalancer : ProtoService<LoadBalancer>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
@end
