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

function init() {
    document.addEventListener("deviceready", deviceInfo, true);
}

function deviceInfo() {
    document.getElementById("platform").innerHTML = device.platform;
    document.getElementById("version").innerHTML = device.version;
    document.getElementById("uuid").innerHTML = device.uuid;
    document.getElementById("name").innerHTML = device.name;
    document.getElementById("width").innerHTML = screen.width;
    document.getElementById("height").innerHTML = screen.height;
    document.getElementById("colorDepth").innerHTML = screen.colorDepth;
}

function openFile() {
    console.log("open");
    var file = document.getElementById("filePath").value;
    window.plugins.FileViewer.open(file, onSuccess, onError);
}

function openFileByMimetype() {
    console.log("openByMimetype");
    var file = document.getElementById("filePath").value;
    var mimetype = document.getElementById("mimetype").value; 
    window.plugins.FileViewer.openByMimetype(file, mimetype, onSuccess, onError);
}

function onSuccess(message) {
    console.log("Success");
    showMessage(message);
}

function onError(message) {
    console.log("Error");
    showMessage(message);
}

function showMessage(message) {
    console.log("type: " + message.type);
    console.log("code: " + message.code);
    console.log("message: " + message.message);
    console.log("url: " + message.url);
    console.log("name: " + message.name);
}
