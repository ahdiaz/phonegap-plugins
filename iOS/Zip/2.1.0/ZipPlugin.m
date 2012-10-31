/*
 * Copyright (C) 2012 by Emergya
 *
 * Author: Alejandro Leiva <aleiva@emergya.com>
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

#import "ZipPlugin.h"

#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"

@implementation ZipPlugin

- (void) info:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSString* source = [command.arguments objectAtIndex:0];
    
    CDVPluginResult* result = nil;
    NSString* jsString = nil;
    
    @try {
        ZipFile *unzipFile = [[ZipFile alloc] initWithFileName:source mode:ZipFileModeUnzip];
        NSArray *infos = [unzipFile listFileInZipInfos];
        
        for (FileInZipInfo *info in infos) {
            NSLog(@"FILE - %@ %@ %d (%d)", info.name, info.date, info.size, info.level);
        }
        
        NSInteger entries = [unzipFile numFilesInZip];
        NSLog(@"Entries: %d", entries);
        
        [unzipFile close];
        
        // TODO: Use CDVFile getDirectoryEntry, it provides the same info as a NSDictionary.
        NSMutableDictionary* zipEntry = [NSMutableDictionary dictionaryWithCapacity:5];
        NSString* lastPart = [source lastPathComponent];
        
        [zipEntry setObject:[NSNumber numberWithBool: YES]  forKey:@"isFile"];
        [zipEntry setObject:[NSNumber numberWithBool: NO]  forKey:@"isDirectory"];
        [zipEntry setObject: source forKey: @"fullPath"];
        [zipEntry setObject: lastPart forKey:@"name"];
        [zipEntry setObject:[NSNumber numberWithInteger: entries] forKey:@"entries"];

        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:zipEntry];
        jsString = [result toSuccessCallbackString:callbackId];
        
    }
    @catch (ZipException *ze) {
        NSLog(@"ZipException caught: %d - %@", ze.error, [ze reason]);
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT messageAsString:[ze reason]];
        jsString = [result toErrorCallbackString:callbackId];
    }
    @catch (id e) {
        NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT messageAsString:[e description]];
        jsString = [result toErrorCallbackString:callbackId];
    }
    @finally {
        if (jsString != nil)
            [self writeJavascript: jsString];
    }
}

- (void) compress:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSString* source = [command.arguments objectAtIndex:0];
    NSString* target = [command.arguments objectAtIndex:1];
    
    CDVPluginResult *result = nil;
    NSString *jsString = nil;
    
    NSLog(@"source: %@ target: %@", source, target);
    
    //TODO: Implement it!
    
    [self writeJavascript: jsString];
}

- (void) uncompress:(CDVInvokedUrlCommand*)command
{
    // TODO: Handle exceptions.
    
    NSString* callbackId = command.callbackId;
    NSString* source = [command.arguments objectAtIndex:0];
    NSString* target = [command.arguments objectAtIndex:1];
    
    //NSLog(@"source: %@, target: %@", source, target);
    
    NSArray *dirPaths;
    NSString *docsDir;

    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];

    NSLog(@"uncompress - source: %@ target: %@", source, target);
    
    ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:source mode:ZipFileModeUnzip];
    [unzipFile goToFirstFileInZip];
    int totalEntities = [unzipFile numFilesInZip];
    processedEntities = 0;
    
    for (int i = 0; i < totalEntities; i++) {

        FileInZipInfo *info = [unzipFile getCurrentFileInZipInfo];
        NSLog(@"Processing: %@", info.name);
        
        // Checking if current entity is a file or a directory.
        BOOL isDir;
        if ([[info.name substringFromIndex:[info.name length] - 1] isEqualToString:@"/"]) {
            isDir = YES;
        } else {
            isDir = NO;
        }

        // Creating target path.
        NSString *targetPath = [target stringByAppendingPathComponent:info.name];
        
        if (isDir) {
            
            [self createDirectory:targetPath];

        } else {

            ZipReadStream *read = [unzipFile readCurrentFileInZip];
            NSMutableData *data = [[NSMutableData alloc] initWithLength:info.length];
            
            // Check existence of base directory path, create it otherwise.
            NSRange range = [targetPath rangeOfString:@"/" options: NSBackwardsSearch];
            NSString *basePath = [targetPath substringToIndex:range.location];

            [self createDirectory:basePath];
            
            [read readDataWithBuffer:data];
            [data writeToFile:targetPath atomically:NO];  
            [data release];
            [read finishedReading];
            
            processedEntities += 1;
            
            NSLog(@"Extracted file: %@ at: %@", info.name, targetPath);
            
            [self publish:targetPath isDirectory:isDir totalEntities:totalEntities callback:callbackId];
        }
        
        [unzipFile goToNextFileInZip];
    }

    [unzipFile close];
    [unzipFile release];
}

-(void) publish: (NSString*) fullPath isDirectory: (BOOL) isDir totalEntities:(int) totalEntities callback: (NSString *) callbackId
{
    CDVPluginResult* result = nil;
    NSString* jsString = nil;

    NSMutableDictionary* entry = [NSMutableDictionary dictionaryWithCapacity:6];
    NSString* lastPart = [fullPath lastPathComponent];
    
    [entry setObject:[NSNumber numberWithBool: !isDir]  forKey: @"isFile"];
    [entry setObject:[NSNumber numberWithBool: isDir]  forKey: @"isDirectory"];
    [entry setObject:fullPath forKey: @"fullPath"];
    [entry setObject:lastPart forKey: @"name"];
    [entry setObject:[NSNumber numberWithBool: totalEntities == processedEntities] forKey: @"completed"];
    [entry setObject:[NSNumber numberWithInteger: processedEntities] forKey: @"progress"];
    [entry setObject:[NSNumber numberWithInteger: totalEntities] forKey: @"entries"];

    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:entry];
    // IMPORTANT: Don't allow the javascript code unregister the callback so we can send more than one message.
    result.keepCallback = [NSNumber numberWithBool: YES];
    jsString = [result toSuccessCallbackString:callbackId];
    
    [self writeJavascript: jsString];
}

-(BOOL) createDirectory: (NSString*) path
{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    
    BOOL isDir;
    if ([fileMgr fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        NSLog(@"Directory %@ already exists.", path);
        return true;
    }
    
    NSError *error = nil;
    BOOL success = [fileMgr createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    
    [fileMgr release];
    
    if (success) {
        NSLog(@"Created directory: %@", path);
        return true;
    } else {
        NSLog(@"Failed to create directory: %@ with error:%@", path, error.description);
        return false;
    }

}


@end
