'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');


exports.createHandler = functions.firestore
    .document('chats/{chatId}')
    .onCreate((snap, context) => {
        const chat = snap.data();
        if (chat.type == "G") {
            const title = chat.name;
            const body = "Created group";
            sendNotifications(chat.users, title, body);
        }
        return 0;
    });

exports.updateHandler = functions.firestore
    .document('chats/{chatId}')
    .onUpdate((change, context) => {

        const newChat = change.after.data();
        const oldChat = change.before.data();

        if (newChat.type == "G") {
            let users = newChat.users.slice();
            users = users.filter((user) => {
                return !userIncluded(oldChat.users, user);
            });

            if (users.length > 0) {
                console.log(users);
                const title = newChat.name;
                const body = "Added to group";
                sendNotifications(users, title, body);
            }
        }
        return 0;
    });

function userIncluded(oldUsers, newUser) {
    let included = false;
    for(let oldUser in oldUsers) {
        if (objectsAreSame(newUser, oldUser)) {
            included = true;
            break;
        }
    }
    return included;
}

function objectsAreSame(x, y) {
    let objectsAreSame = true;
    for (let propertyName in x) {
        if (x[propertyName] !== y[propertyName]) {
            objectsAreSame = false;
            break;
        }
    }
    return objectsAreSame;
}

function sendNotifications(users, title, body) {
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
    users.forEach(user => {
        const userRef = admin.firestore().collection('users').doc(user['id']);
        userRef.get().then(user => {
            admin.messaging().sendToDevice(user.data().notificationToken, payload)
                .then((response) => {
                    // Response is a message ID string.
                    console.log('Successfully sent message:', response);
                })
                .catch((error) => {
                    console.log('Error sending message:', error);
                });
        });
    });
    console.log("Notifications sent");

    return 0;
}