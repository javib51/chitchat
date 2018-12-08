'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');


exports.handler = functions.firestore
    .document('chats/{chatId}/messages/{messageId}')
    .onCreate((snap, context) => {
        const chatId = context.params.chatId;

        const userFromRef = snap.data().userFrom;
        return userFromRef.get().then(userFrom => {
            const chatRef = admin.firestore().collection('chats').doc(chatId);
            chatRef.get().then(chat => {
                if (!chat.exists) {
                    console.log('No such document!');
                } else {

                    const title = (chat.data().type == "G") ? chat.name : userFrom.data().nickname;
                    const body = (snap.data().type == "text") ? snap.data().payload : "photo";

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
                    return sendNotifications(chat.data(), payload, userFrom.data());
                }
            });
        });
    });

function sendNotifications(chat, payload, userFrom) {
    console.log("Send notifications");
    let usersRef = admin.firestore().collection('chats').doc(chat.id).collection('users');
    usersRef.get().then( users => {
        users.forEach(userMap => {
            let user = userMap.data();
            try {
                if (user['id'] != userFrom.id) {
                    const userRef = admin.firestore().collection('users').doc(user['id']);
                    userRef.get().then(userData => {

                        admin.messaging().sendToDevice(userData.data().notificationToken, payload)
                            .then((response) => {
                                // Response is a message ID string.
                                console.log('Successfully sent message:', response);
                            })
                            .catch((error) => {
                                console.log('Error sending message:', error);
                            });
                    });
                }
            } catch (error) {
                console.error(error);
            }
        });
    });
    console.log("Notifications sent");

    return 0;
}