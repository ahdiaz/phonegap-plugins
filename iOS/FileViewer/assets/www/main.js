/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/


var deviceInfo = function() {
    document.getElementById("platform").innerHTML = device.platform;
    document.getElementById("version").innerHTML = device.version;
    document.getElementById("uuid").innerHTML = device.uuid;
    document.getElementById("name").innerHTML = device.name;
    document.getElementById("width").innerHTML = screen.width;
    document.getElementById("height").innerHTML = screen.height;
    document.getElementById("colorDepth").innerHTML = screen.colorDepth;
};


function success(status) {
	console.log('--- Success ---');
    console.log('Code: ' + status.code);
    console.log('Message: ' + status.message);
    console.log('URL: ' + status.url);
    console.log('Type: ' + status.uti);
    console.log('Name: ' + status.name);
}


function fail(error) {
	console.log('--- Error ---');
    console.log('Code: ' + error.code);
    console.log('Message: ' + error.message);
    console.log('URL: ' + error.url);
    console.log('Type: ' + error.uti);
    console.log('Name: ' + error.name);
}


function preview(filepath) {

	var fileViewer = window.plugins.FileViewer;
    fileViewer.preview(filepath, success, fail);
}


function open(filepath) {
    
	var fileViewer = window.plugins.FileViewer;
    fileViewer.open(filepath, success, fail);
}


function previewImage() {
    preview('assets/kayak.jpg');
}


function openImage() {
    open('assets/kayak.jpg');
}


function previewPDF() {
    preview('assets/kayak.pdf');
}


function openPDF() {
    open('assets/kayak.pdf');
}


function init() {
    document.addEventListener("deviceready", deviceInfo, true);
}

