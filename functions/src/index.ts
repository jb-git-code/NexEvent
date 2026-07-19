import * as admin from "firebase-admin";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

admin.initializeApp();

export const sendAnnouncementNotification =
  onDocumentCreated(
    "announcements/{announcementId}",
    async (event) => {
      const data = event.data?.data();

      if (!data) return;

      await admin.messaging().send({
        topic: data.channelId,

        notification: {
          title: `📢 ${data.title}`,
          body: data.content,
        },

        data: {
          screen: "community",
          announcementId: event.params.announcementId,
        },
      });

      console.log(
        `Notification sent for announcement ${event.params.announcementId}`
      );
    }
  );
