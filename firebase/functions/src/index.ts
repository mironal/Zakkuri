import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const deleteHabitRecords = functions.firestore
  .document("users/{userId}/habits/{habitId}")
  .onDelete(async (_, context) => {
    const userId = context.params.userId;
    const habitId = context.params.habitId;

    // batch は 500件まで操作できるがメモリのことを考えて少なめにしておく.
    const LIMIT = 100 as const;
    const db = admin.firestore();
    do {
      const recordsSnapshot = await db
        .collection(`users/${userId}/records/`)
        .where("habitId", "==", habitId)
        .limit(LIMIT)
        .get();

      console.log(
        `Delete habit records at "users/${userId}/habits/${habitId}", size: ${recordsSnapshot.size}`
      );
      if (recordsSnapshot.size === 0) {
        break;
      }
      const batch = db.batch();
      recordsSnapshot.docs.forEach(doc => batch.delete(doc.ref));

      await batch.commit();
    } while (true);
  });
