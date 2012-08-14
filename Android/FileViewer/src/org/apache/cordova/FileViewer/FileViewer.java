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

package org.apache.cordova.FileViewer;

import java.io.File;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.Intent;
import android.net.Uri;
import android.webkit.MimeTypeMap;

import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;

import org.apache.cordova.api.LOG;

import android.content.res.AssetManager;
import java.io.FileOutputStream;
import java.io.InputStream;

public class FileViewer extends Plugin {
    /**
    * Executes the request and returns PluginResult.
    *
    * @param action        The action to execute.
    * @param args          JSONArry of arguments for the plugin.
    * @param callbackId    The callback id used when calling back into JavaScript.
    * @return              A PluginResult object with a status and message.
    */
    public PluginResult execute(String action, JSONArray args, String callbackId) {
        PluginResult.Status status = PluginResult.Status.OK;
        JSONObject result = null;

        try {
            if (action.equals("open")) {
                String url = args.getString(0);
                result = this.open(url);
            } else if (action.equals("openByMimetype")) {
                String url = args.getString(0);
                String mimetype = args.getString(1);
                result = this.openByMimetype(url, mimetype);
            } else if (action.equals("preview")) {
                String url = args.getString(0);
                result = this.preview(url);
            } else if (action.equals("previewByMimetype")) {
                String url = args.getString(0);
                String mimetype = args.getString(1);
                result = this.previewByMimetype(url, mimetype);
            } else {
                status = PluginResult.Status.INVALID_ACTION;
                result = getStateData(status.toString(), "Action not exists", "", "", "");
            }
        } catch (JSONException e) {
            status = PluginResult.Status.JSON_EXCEPTION;
            return new PluginResult(status); 
        }

        return new PluginResult(status, result);
    }

    /**
     * Identifies if action to be executed returns a value and should be run synchronously.
     *
     * @param action    The action to execute
     * @return          T=returns value
     */
    public boolean isSynch(String action) {
        return false;
    }

    //--------------------------------------------------------------------------
    // LOCAL METHODS
    //--------------------------------------------------------------------------

    public JSONObject open(String filePath) throws JSONException {
        return openByMimetype(filePath, getUrlMimetype(filePath));
    }

    public JSONObject openByMimetype(String filePath, String mimetype) throws JSONException {
        String tag = "FileViewer";

        File file = new File(filePath);
        String fileName = file.getName();
        AssetManager am = this.ctx.getAssets();

        if (!file.exists()) {
            try {
                String tmpFileName = "/sdcard/" + file.getName();
                InputStream in = am.open(filePath);
                FileOutputStream out = new FileOutputStream(tmpFileName);

                byte[] buffer = new byte[1024];
                int i = in.read(buffer);

                while (i != -1) {
                    out.write(buffer, 0, i);
                    i = in.read(buffer);
                }

                in.close();
                out.close();

                file = new File(tmpFileName);

            } catch (Exception e) {
                LOG.e(tag, "FileViewer: " + e.toString());
                file = null;
            }
        }

        if (file != null && file.exists()) {
            try {
                Uri path = Uri.fromFile(file);
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setDataAndType(path, mimetype);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

                this.ctx.startActivity(intent);
                return getStateData(PluginResult.Status.OK.toString(), "", filePath, mimetype, fileName);

            } catch (android.content.ActivityNotFoundException e) {
                System.out.println("FileViewer: Error loading '" + filePath + "' url: "+ e.toString());
                return getStateData(PluginResult.Status.INVALID_ACTION.toString(), e.toString(), filePath, mimetype, fileName);
            }

        } else {
            LOG.e(tag, "FileViewer: '" + file.getAbsolutePath() +  "' file not found");
            return getStateData(PluginResult.Status.ERROR.toString(), "File not found", filePath, mimetype, fileName);
        }
    }

    public JSONObject preview(String filePath) throws JSONException {
        return open(filePath);
    }

    public JSONObject previewByMimetype(String filePath, String mimetype) throws JSONException {
        return openByMimetype(filePath, mimetype);
    }

    private String getUrlMimetype(String url) {
        String mimetype = MimeTypeMap.getSingleton().getMimeTypeFromExtension(MimeTypeMap.getFileExtensionFromUrl(url.substring(url.lastIndexOf("."))));
        return mimetype;
    }

    private JSONObject getStateData(String code, String message, String url, String type, String name) throws JSONException {
        JSONObject data = new JSONObject();
        data.put("code", code);
        data.put("message", message);
        data.put("url", url);
        data.put("type", type);
        data.put("name", name);

        return data;
    }
}
