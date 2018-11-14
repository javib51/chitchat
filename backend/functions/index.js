'use strict';

const functions = require('firebase-functions');
const mkdirp = require('mkdirp-promise');
const admin = require('firebase-admin');
admin.initializeApp();
const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');

// Thumbnail prefix added to file names.
const THUMB_PREFIX = 'thumb_';

exports.generateThumbnail = functions.storage.object().onFinalize(async (object) => {
    // File and directory paths.
    console.log(object);

    const filePath = object.name;
    const fileDir = path.dirname(filePath);
    const fileName = path.basename(filePath);
    const tmpFilePath = path.normalize(path.join(fileDir, `${THUMB_PREFIX}${fileName}`));
    const tempFile = path.join(os.tmpdir(), tmpFilePath);
    const tempDir = path.dirname(tempFile);

    // Exit if this is triggered on a file that is not an image.
    if (!object.contentType.startsWith('image/')) {
        return console.log('This is not an image.');
    }

    // Exit if the image is already a thumbnail.
    if (fileName.startsWith(THUMB_PREFIX)) {
        return console.log('Already a Thumbnail.');
    }

    // Cloud Storage files.
    const bucket = admin.storage().bucket(object.bucket);
    const file = bucket.file(filePath);
    const maxResolution = object.metadata.resolution;


    // Create the temp directory where the storage file will be downloaded.
    await mkdirp(tempDir);
    // Download file from bucket.
    await file.download({destination: tempFile});
    console.log('The file has been downloaded to', tempFile);

    /**
     * Create thumb of lower resolutions only.
     * Default image contains resolution defined
     * on maxResolution variable.
     * Ex: maxResolution = 'high' -> thumb low
     */
    if(maxResolution == 'high' || maxResolution == 'full') {
        console.log('createThumb 640x480');
        await createThumb(object, tempFile, bucket, file, 640, 480);
    }

    if(maxResolution == 'full') {
        console.log('createThumb 1280x960');
        await createThumb(object, tempFile, bucket, file, 1280, 960);
    }

    fs.unlinkSync(tempFile);
    return console.log('Thumbnail URLs saved to database.');
});

async function createThumb(object, tempFile, bucket, file, max_width, max_height) {
    try {
        const thumb_prefix = THUMB_PREFIX + max_width + "_" + max_height + "_";
        const thumbFilePath = path.normalize(path.join(path.dirname(object.name), `${thumb_prefix}${path.basename(object.name)}`));

        const tempLocalThumbFile = path.join(os.tmpdir(), thumbFilePath);

        const thumbFile = bucket.file(thumbFilePath);
        const metadata = {
            contentType: object.contentType,
        };

        // Generate a thumbnail using ImageMagick.
        await spawn('convert', [tempFile, '-thumbnail', `${max_width}x${max_height}>`, tempLocalThumbFile], {capture: ['stdout', 'stderr']});
        console.log('Thumbnail created at', tempLocalThumbFile);
        // Uploading the Thumbnail.
        await bucket.upload(tempLocalThumbFile, {destination: thumbFilePath, metadata: metadata});
        console.log('Thumbnail uploaded to Storage at', thumbFilePath);
        // Once the image has been uploaded delete the local files to free up disk space.

        fs.unlinkSync(tempLocalThumbFile);
        // Get the Signed URLs for the thumbnail and original image.
        const config = {
            action: 'read',
            expires: '03-01-2500',
        };
        const results = await Promise.all([
            thumbFile.getSignedUrl(config),
            file.getSignedUrl(config),
        ]);
        console.log('Got Signed URLs.');
        const thumbResult = results[0];
        const originalResult = results[1];
        const thumbFileUrl = thumbResult[0];
        const fileUrl = originalResult[0];
        // Add the URLs to the Database
        await admin.database().ref('images').push({path: fileUrl, thumbnail: thumbFileUrl});
    } catch(error){
        console.error(error);
    }
}