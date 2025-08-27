
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Example: when an attendance record is created, compute daily total hours
exports.onAttendanceWrite = functions.firestore
  .document("attendance/{docId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const uid = data.uid;
    const dayId = data.dayId;

    const db = admin.firestore();
    const qs = await db.collection("attendance")
      .where("uid", "==", uid)
      .where("dayId", "==", dayId)
      .orderBy("timestamp", "asc")
      .get();

    let firstIn = null;
    let lastOut = null;
    for (const d of qs.docs) {
      const rec = d.data();
      if (rec.type === "check-in" && !firstIn) firstIn = rec.timestamp.toDate();
      if (rec.type === "check-out") lastOut = rec.timestamp.toDate();
    }

    if (firstIn && lastOut) {
      const hours = (lastOut - firstIn) / (1000 * 60 * 60);
      await db.collection("daily_totals").doc(`${uid}_${dayId}`).set({
        uid, dayId, hours
      }, { merge: true });
    }
    return null;
  });
