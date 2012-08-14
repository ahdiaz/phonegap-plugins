## FileViewer plugin

This plugin shows a preview of a document or a list of actions and applications to open the document with.

## Setup

- Copy the fileviewer.js file to your www folder, and add a reference to it: <script type="text/javascript" charset="utf-8" src="fileviewer.js"></script>
- Copy the FileViewer.java file to you src folder
- Add a reference to the plugin to your res/xml/plugins.xml file: <plugin name="FileViewer" value="org.apache.cordova.FileViewer.FileViewer"/>


## API

#### FileViewer.preview (path, success, error)

Opens a preview of the document.

#### FileViewer.previewByMimetype (path, mimetype, success, error)

Opens a preview of the document asuming it is of the type "mimetype".

#### FileViewer.open (path, success, error)

Opens a menu with the posible actions for the document.

#### FileViewer.openByMimetype (path, mimetype, success, error)

Opens a menu with the posible actions for the document asuming it is of the type "mimetype".

#### Success and error callbacks

Both callbacks receives an object as an argument with this attributes:

* code: Error code.
* message: The error message.
* url: The full url of the document.
* type: The mime type of the document.
* name: The name of the document.

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

