#import "RouteRequest.h"
#import "HTTPMessage.h"

@interface RouteRequest()

@property (strong)NSArray *parameters;

@end

@implementation RouteRequest {
	HTTPMessage *message;
}

@synthesize params;

- (id)initWithHTTPMessage:(HTTPMessage *)msg parameters:(NSDictionary *)parameters {
	if (self = [super init]) {
		params = parameters;
		message = msg;
        [self parseBody];
	}
	return self;
}

- (NSDictionary *)headers {
	return [message allHeaderFields];
}

- (NSString *)header:(NSString *)field {
	return [message headerField:field];
}

- (id)param:(NSString *)name {
	return [params objectForKey:name];
}

- (NSString *)method {
	return [message method];
}

- (NSURL *)url {
	return [message url];
}

- (NSData *)body {
	return [message body];
}

- (NSString *)description {
	NSData *data = [message messageData];
	return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (NSString *)valueForFormField:(NSString*)field {
    for (NSDictionary *dict in self.parameters) {
        NSString *name = dict[@"name"];
        if ([name isEqualToString:field]) {
            return dict[@"value"];
        }
    }
    
    return nil;
}

-(void) parseBody {
    NSString *body =  [[NSString alloc] initWithData:[self body] encoding:NSASCIIStringEncoding];
    if ([[self body] length] == 0) {
        return;
    }
    
    NSArray *rawParameters = [body componentsSeparatedByString:@"&"];
    NSMutableArray *parameters = [NSMutableArray array];
    for (NSString* parameter in rawParameters) {
        NSArray *parameterParts = [parameter componentsSeparatedByString:@"="];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"name"] = parameterParts[0];
        dict[@"value"] = [self decodeFromPercentEscapedString:parameterParts[1]];
        [parameters addObject:dict];
    }
    
    self.parameters = [NSArray arrayWithArray:parameters];
}

- (NSString *)decodeFromPercentEscapedString:(NSString *) encodedSring {
    return (__bridge NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding( NULL, (__bridge CFStringRef)encodedSring, CFSTR(""), kCFStringEncodingUTF8);
}

@end
