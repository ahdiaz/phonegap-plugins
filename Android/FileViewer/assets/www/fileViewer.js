/*
* Copyright (C) 2012 by Emergya
*
* Author: Jose A. Jimenez <jajimc@gmail.com>
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

/**
 * Constructor
 */
function FileViewer() {
}

/**
 * Define method FileViewer::open()
 */
FileViewer.prototype.open = function(url, successCallback, errorCallback) {
    if (successCallback && (typeof successCallback !== "function")) {
        console.log("FileViewer error: 'successCallback' is not a function");
        return;
    }                                                                                                                                                                               
    if (errorCallback && (typeof errorCallback !== "function")) {
        console.log("FileViewer error: 'errorCallback' is not a function");
        return;
    }

	cordova.exec(successCallback, errorCallback, "FileViewer", "open", [url]);
};

/**
 * Define method FileViewer::openByMimetype()
 */
FileViewer.prototype.openByMimetype = function(url, mimetype, successCallback, errorCallback) {
    if (successCallback && (typeof successCallback !== "function")) {
        console.log("FileViewer Error: successCallback is not a function");
        return;
    }                                                                                                                                                                               
    if (errorCallback && (typeof errorCallback !== "function")) {
        console.log("FileViewer Error: errorCallback is not a function");
        return;
    }

	cordova.exec(successCallback, errorCallback, "FileViewer", "openByMimetype", [url, mimetype]);
};

/**
 * Define method FileViewer::preview()
 */
FileViewer.prototype.preview = function(url, successCallback, errorCallback) {
    if (successCallback && (typeof successCallback !== "function")) {
        console.log("FileViewer error: 'successCallback' is not a function");
        return;
    }                                                                                                                                                                               
    if (errorCallback && (typeof errorCallback !== "function")) {
        console.log("FileViewer error: 'errorCallback' is not a function");
        return;
    }

	cordova.exec(successCallback, errorCallback, "FileViewer", "preview", [url]);
};

/**
 * Define method FileViewer::previewByMimetype()
 */
FileViewer.prototype.previewByMimetype = function(url, mimetype, successCallback, errorCallback) {
    if (successCallback && (typeof successCallback !== "function")) {
        console.log("FileViewer Error: successCallback is not a function");
        return;
    }                                                                                                                                                                               
    if (errorCallback && (typeof errorCallback !== "function")) {
        console.log("FileViewer Error: errorCallback is not a function");
        return;
    }

	cordova.exec(successCallback, errorCallback, "FileViewer", "previewByMimetype", [url, mimetype]);
};

/**
 * Load FileViewer
 */
if(!window.plugins) {
    window.plugins = {};
}

if (!window.plugins.FileViewer) {
    window.plugins.FileViewer = new FileViewer();
}
