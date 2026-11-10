const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();

// PayHere Webhook (Notify URL)
exports.payhereNotify = functions.https.onRequest(async (req, res) => {
  try {
    // PayHere එකෙන් එවන විස්තර අල්ලගැනීම
    const merchant_id = req.body.merchant_id;
    const order_id = req.body.order_id;
    const payhere_amount = req.body.payhere_amount;
    const payhere_currency = req.body.payhere_currency;
    const status_code = req.body.status_code;
    const md5sig = req.body.md5sig;
    const userId = req.body.custom_1; // අපි ඇප් එකෙන් යවපු User ID එක
    const packageName = req.body.custom_2; // පැකේජ් එකේ නම

    // TODO: මෙතනට ඔයාගේ PayHere Merchant Secret එක අනිවාර්යයෙන්ම දාන්න
    const merchant_secret = "Mjk1Mzg0NjAxMTEwOTUxODg4Nzg0MjQ3NDcwNDE2NDEyMDY1NDk2NA==";

    // 1. MD5 Signature එක හදලා බලනවා මේක ඇත්තටම PayHere එකෙන් ආපු එකක්ද කියලා
    const hashedSecret = crypto.createHash('md5').update(merchant_secret).digest('hex').toUpperCase();
    const hashString = merchant_id + order_id + payhere_amount + payhere_currency + status_code + hashedSecret;
    const generatedSig = crypto.createHash('md5').update(hashString).digest('hex').toUpperCase();

    // 2. Signature එක සමානද කියලා බලනවා
    if (generatedSig === md5sig) {
      // 3. ගෙවීම සාර්ථකද කියලා බලනවා (status_code 2 කියන්නේ සාර්ථකයි)
      if (status_code === '2' && userId) {
        console.log(`Payment successful for user ${userId}, package: ${packageName}`);

        // පැකේජ් එක අනුව එකතු වෙන්න ඕනේ ප්‍රශ්න ගාණ (Coins) තීරණය කරනවා
        let addedCoins = 0;
        if (packageName.includes('Top-up 25')) addedCoins = 25;
        else if (packageName.includes('Top-up 50')) addedCoins = 50;
        else if (packageName.includes('Top-up 100')) addedCoins = 100;
        else addedCoins = 150; // මාසික පැකේජ සඳහා

        // 4. Firestore Database එකට Coins ටික Auto එකතු කරනවා
        const userRef = admin.firestore().collection('users').doc(userId);

        await userRef.set({
          'quota.paidBalance': admin.firestore.FieldValue.increment(addedCoins),
          'quota.lastPaymentDate': admin.firestore.FieldValue.serverTimestamp(),
          'quota.activePackage': packageName
        }, { merge: true });

        console.log('User balance updated successfully.');
        res.status(200).send("Success"); // PayHere එකට සාර්ථකයි කියලා යවනවා
      } else {
        console.log('Payment failed, canceled, or pending.');
        res.status(400).send("Payment not successful");
      }
    } else {
      console.error('Signature verification failed! Possible hacker attempt.');
      res.status(400).send("Signature verification failed");
    }
  } catch (error) {
    console.error('Error processing webhook:', error);
    res.status(500).send("Internal Server Error");
  }
});