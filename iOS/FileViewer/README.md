## FileViewer plugin

This plugin shows a preview of a document or a list of actions and applications to open the document with.

## Usage

A full example can be found in main.js

If you specify a relative path to the doucment, the plugin will look for it in the application bundle.
If you specify an absolute path to the document, the plugin will look for it in the device Documents folder.

    var fileViewer = window.plugins.FileViewer;
  
    fileViewer.preview('path/to/file/in/app/bundle', function(status) {
        console.log('Ok');
    }, function(error) {
        console.log('Error');
    });
  
    fileViewer.open('/path/to/file/in/documents/folder', function(status) {
        console.log('Ok');
    }, function(error) {
        console.log('Error');
    });

