'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');


exports.createHandler = functions.firestore
    .document('chats/{chatId}/users/{userId}')
    .onCreate((snap, context) => {
        const chatRef = admin.firestore().collection('chats').doc(context.params.chatId);
        chatRef.get().then(chat => {

            if (chat.data().type == "G") {
                const title = chat.data().name;
                const body = "Added to group";
                sendNotifications(context.params.userId, title, body);
            }
        });
        return 0;
    });

/*exports.updateHandler = functions.firestore
    .document('chats/{chatId}/users/{userId}')
    .onDelete((snap, context) => {

        const chatRef = admin.firestore().collection('chats').doc(context.params.chatId);
        chatRef.get().then(chat => {
            if (chat.data().type == "G") {
                const title = chat.data().name;
                const body = "Removed from group";
                    sendNotifications(context.params.userId, title, body);
            }
        });
        return 0;
    });*/

function sendNotifications(userId, title, body) {
    console.log("Send notifications");

    const payload = {
        notification: {
            title: title,
            body: body,
            sound: 'default'
        },
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            id: '1',
            status: 'done',
            title: title,
            body: body,
        },
    };
    try {
        const userRef = admin.firestore().collection('users').doc(userId);
        userRef.get().then(user => {
            console.log(user.data());
            admin.messaging().sendToDevice(user.data().notificationToken, payload)
                .then((response) => {
                    // Response is a message ID string.
                    console.log('Successfully sent message:', response);
                })
                .catch((error) => {
                    console.log('Error sending message:', error);
                });
        });
    } catch (error) {
        console.error(error);
    }
    console.log("Notifications sent");

    return 0;
}