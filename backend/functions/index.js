'use strict';

const functions = require('firebase-functions');
const generateThumbnail = require('./generateThumbnail');
const messageNotifications = require('./messageNotifications');

// Functions definition
exports.generateThumbnail = generateThumbnail.handler;
exports.messageNotifications = messageNotifications.handler;