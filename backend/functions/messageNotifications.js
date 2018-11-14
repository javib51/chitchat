'use strict';

const functions = require('firebase-functions');
const mkdirp = require('mkdirp-promise');
const admin = require('firebase-admin');
admin.initializeApp();
const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');

exports.handler = functions.firestore
    .document('users/{userId}/{chatId}/{messageId}')
    .onCreate((snap, context) => {

    });