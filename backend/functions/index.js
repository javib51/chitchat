'use strict';

const admin = require('firebase-admin');
const generateThumbnail = require('./generateThumbnail');
const messageNotifications = require('./messageNotifications');
const chatNotifications = require('./chatNotifications');

//Gobal init
admin.initializeApp();

const settings = {/* your settings... */ timestampsInSnapshots: true};
admin.firestore().settings(settings);

// Functions definition
exports.generateThumbnail = generateThumbnail.handler;
exports.messageNotifications = messageNotifications.handler;
exports.chatNotificationsCreation = chatNotifications.createHandler;