#import "FlutterFlappyChainPlugin.h"

@implementation FlutterFlappyChainPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_flappy_chain"
            binaryMessenger:[registrar messenger]];
  FlutterFlappyChainPlugin* instance = [[FlutterFlappyChainPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

    result(FlutterMethodNotImplemented);
}

@end
