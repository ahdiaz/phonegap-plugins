/*
 * Copyright (C) 2012 by Emergya
 *
 * Author: Antonio Hernández <ahernandez@emergya.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "FileViewer.h"
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <CoreServices/CoreServices.h>
#endif

@implementation FileViewer


/**
 * Transforms an UTI into a MimeType.
 */
- (NSString*) MimetypeFromUTI:(NSString*) uti
{
    CFStringRef UTIString = (__bridge CFStringRef) uti;
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTIString, kUTTagClassMIMEType);
    NSString* mimeType = (__bridge_transfer NSString*) MIMEType;
    return mimeType;
}


/**
 * Transforms a MimeType into an UTI.
 */
- (NSString*) UTIFromMimetype:(NSString*) mimeType
{
    CFStringRef MIMEType = (__bridge CFStringRef) mimeType;
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, MIMEType, NULL);
    NSString* uti = (__bridge_transfer NSString*) UTI;
    return uti;
}


/**
 * Returns an UIDocumentInteractionController instance for a specific path.
 * If mimeType is not nil, the corresponding UTI is calculated and used.
 */
- (UIDocumentInteractionController*) documentInteractionControllerForPath:(NSString*)resourcePath ofType:(NSString*) mimeType
{
    
    NSString* absPath = nil;
    
    if ([resourcePath isAbsolutePath]) {
        
        // If the path is absolute we look for the resource in the Documents directory of the application.
        NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* docsDir = [dirPaths objectAtIndex:0];
        absPath = [docsDir stringByAppendingPathComponent:resourcePath];
        
    } else {
        
        // If the path is relative we asume the resource is in the application bundle.
        NSString* baseName = [[resourcePath lastPathComponent] stringByDeletingPathExtension];
        NSString* extension = [resourcePath pathExtension];
        NSString* basePath = [NSString stringWithFormat:@"www/%@", [resourcePath stringByDeletingLastPathComponent]];
        absPath = [[NSBundle mainBundle] pathForResource:baseName ofType:extension inDirectory:basePath];
    }
    
    /*
    NSLog(@"FileViewer: resourcePath: %@", resourcePath);
    NSLog(@"FileViewer: baseName: %@", [[resourcePath lastPathComponent] stringByDeletingPathExtension]);
    NSLog(@"FileViewer: extension: %@", [resourcePath pathExtension]);
    NSLog(@"FileViewer: absolutePath: %@", absPath);
    */
    
    if (absPath == nil) {
               
        return nil;
        
    } else {
        
        NSFileManager *fileMgr = [[NSFileManager alloc] init];
        
        if (![fileMgr fileExistsAtPath:absPath]) {
            return nil;
        }
    }
    
    
    UIDocumentInteractionController *interactionController =
        [UIDocumentInteractionController interactionControllerWithURL: [NSURL fileURLWithPath:absPath]];
    
    interactionController.delegate = self;
    
    if (mimeType != nil) {
        
        // Find the appropiate UTI for the mimeType
        interactionController.UTI = [self UTIFromMimetype:mimeType];
    }
    
    return interactionController;
}


/**
 * Implements UIDocumentInteractionControllerDelegate::documentInteractionControllerViewControllerForPreview,
 * needed by UIDocumentInteractionController::presentPreviewAnimated.
 */
- (UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController*)interactionController
{
    UIViewController* viewController = [[[UIViewController alloc] init] autorelease];
    [self.viewController addChildViewController:viewController];
    return viewController;
}


/**
 * Calls an error or success callback in the Cordova client.
 */
- (void) publish:(NSInteger)status withMessage:(NSString*)message withCallback:(NSString*) callbackId
         withURL:(NSString*) url withUTI:(NSString*) uti withName:(NSString*) name
{
    NSString* mimeType = [self MimetypeFromUTI:uti];
    
    NSMutableDictionary* error = [NSMutableDictionary dictionaryWithCapacity:5];
    [error setObject:[NSNumber numberWithInteger: status] forKey: @"code"];
    [error setObject:message forKey: @"message"];
    [error setObject:url forKey: @"url"];
    [error setObject:mimeType forKey: @"type"];
    [error setObject:name forKey: @"name"];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:status messageAsDictionary:error];
    NSString* jsString = nil;
    
    if (status == CDVCommandStatus_OK) {
        
        jsString = [result toSuccessCallbackString:callbackId];
        
    } else {
        
        jsString = [result toErrorCallbackString:callbackId];
        
    }
    
    [self writeJavascript: jsString];
}


/**
 * Calls an error or success callback in the Cordova client with default values for some parameters.
 */
- (void) publish:(NSInteger)status withMessage:(NSString*)message withCallback:(NSString*) callbackId
{
    [self publish:status withMessage:message withCallback:callbackId withURL:@"" withUTI:@"" withName:@""];
}


/**
 * Opens a document preview.
 */
-(void) preview:(NSString*) resourcePath ofType:(NSString*) mimeType withCallback:(NSString*) callbackId
{
    UIDocumentInteractionController* ic = [self documentInteractionControllerForPath:resourcePath ofType:mimeType];
    
    if (ic == nil) {
        [self publish:CDVCommandStatus_ERROR withMessage:@"Can't find the resource." withCallback:callbackId];
        return;
    }
    
    
    BOOL ret = [ic presentPreviewAnimated:YES];
    
    if (ret == YES) {
        
        [self publish:CDVCommandStatus_OK withMessage:@"Ok." withCallback:callbackId
              withURL:[ic.URL absoluteString] withUTI:ic.UTI withName:ic.name];
        
    } else {
        
        [self publish:CDVCommandStatus_ERROR withMessage:@"Can't open the preview." withCallback:callbackId
              withURL:[ic.URL absoluteString] withUTI:ic.UTI withName:ic.name];
        
    }
}


/**
 * Opens a document preview.
 */
- (void) preview:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* callbackId = [arguments pop];
    VERIFY_ARGUMENTS(arguments, 1, callbackId)
    
    NSString* resourcePath = [arguments objectAtIndex:0];
    
    [self preview:resourcePath ofType:nil withCallback:callbackId];
}


/**
 * Opens a document preview specifying the mimetype.
 */
- (void) previewByMimetype:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* callbackId = [arguments pop];
    VERIFY_ARGUMENTS(arguments, 1, callbackId)
    
    NSString* resourcePath = [arguments objectAtIndex:0];
    NSString* mimeType = [arguments objectAtIndex:1];
    
    [self preview:resourcePath ofType:mimeType withCallback:callbackId];
}


/**
 * Opens a menu with options to open the document.
 */
-(void) open:(NSString*) resourcePath ofType:(NSString*) mimeType withCallback:(NSString*) callbackId
{
    UIDocumentInteractionController* ic = [self documentInteractionControllerForPath:resourcePath ofType:mimeType];
    
    if (ic == nil) {
        [self publish:CDVCommandStatus_ERROR withMessage:@"Can't find the resource." withCallback:callbackId];
        return;
    }
    
    
    BOOL ret = [ic presentOptionsMenuFromRect:self.webView.frame inView:self.webView animated:YES];
    //BOOL ret = [ic presentOpenInMenuFromRect:self.webView.frame inView:self.webView animated:YES];
    
    if (ret == YES) {
        
        [self publish:CDVCommandStatus_OK withMessage:@"Ok." withCallback:callbackId
              withURL:[ic.URL absoluteString] withUTI:ic.UTI withName:ic.name];
        
    } else {
        
        [self publish:CDVCommandStatus_ERROR withMessage:@"Can't open the options menu." withCallback:callbackId
              withURL:[ic.URL absoluteString] withUTI:ic.UTI withName:ic.name];
        
    }
}


/**
 * Opens a menu with options to open the document.
 */
- (void) open:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* callbackId = [arguments pop];
    VERIFY_ARGUMENTS(arguments, 1, callbackId)
    
    NSString* resourcePath = [arguments objectAtIndex:0];
    
    [self open:resourcePath ofType:nil withCallback:callbackId];
}


/**
 * Opens a menu with options to open the document specifying the mimetype.
 */
- (void) openByMimetype:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString* callbackId = [arguments pop];
    VERIFY_ARGUMENTS(arguments, 1, callbackId)
    
    NSString* resourcePath = [arguments objectAtIndex:0];
    NSString* mimeType = [arguments objectAtIndex:1];
    
    [self open:resourcePath ofType:mimeType withCallback:callbackId];
}


@end
