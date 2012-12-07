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

(function(gap) {

/**
 * Constructor
 */
function FileViewer() {
};


/**
 * Define method FileViewer::preview().
 */
FileViewer.prototype.preview = function(filepath, successCallback, errorCallback) {

    if (successCallback && (typeof successCallback !== "function")) {
        console.log("FileViewer Error: successCallback is not a function");
        return;
    }
    
    if (errorCallback && (typeof errorCallback !== "function")) {
        console.log("FileViewer Error: errorCallback is not a function");
        return;
    }
    
    gap.exec(successCallback, errorCallback, "FileViewer", "preview", [filepath]);
};


/**
 * Define method FileViewer::previewByMimetype().
 */
FileViewer.prototype.previewByMimetype = function(filepath, mimetype, successCallback, errorCallback) {

    if (successCallback && (typeof successCallback !== "function")) {
        console.log("FileViewer Error: successCallback is not a function");
        return;
    }
    
    if (errorCallback && (typeof errorCallback !== "function")) {
        console.log("FileViewer Error: errorCallback is not a function");
        return;
    }
    
    gap.exec(successCallback, errorCallback, "FileViewer", "previewByMimetype", [filepath, mimetype]);
};


/**
 * Define method FileViewer::open().
 */
FileViewer.prototype.open = function(filepath, successCallback, errorCallback) {
    
    if (successCallback && (typeof successCallback !== "function")) {
        console.log("FileViewer Error: successCallback is not a function");
        return;
    }
    
    if (errorCallback && (typeof errorCallback !== "function")) {
        console.log("FileViewer Error: errorCallback is not a function");
        return;
    }
    
    gap.exec(successCallback, errorCallback, "FileViewer", "open", [filepath]);
};


/**
 * Define method FileViewer::openByMimetype().
 */
FileViewer.prototype.openByMimetype = function(filepath, mimetype, successCallback, errorCallback) {
    
    if (successCallback && (typeof successCallback !== "function")) {
        console.log("FileViewer Error: successCallback is not a function");
        return;
    }
    
    if (errorCallback && (typeof errorCallback !== "function")) {
        console.log("FileViewer Error: errorCallback is not a function");
        return;
    }
    
    gap.exec(successCallback, errorCallback, "FileViewer", "openByMimetype", [filepath, mimetype]);
};


/**
 * Load FileViewer.
 */
cordova.addConstructor(function() {
    if (!window.plugins) window.plugins = {};
    window.plugins.FileViewer = new FileViewer();
});

})(window.cordova || window.Cordova || window.PhoneGap);
