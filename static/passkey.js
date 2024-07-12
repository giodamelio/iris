import { toUint8Array } from 'https://cdn.jsdelivr.net/npm/js-base64@3.7.7/base64.mjs';

(async () => {
  if (
    typeof window.PublicKeyCredential === 'undefined'
  ) {
    console.log('No Passkey Support');
    return;
  }

  // Get the challenge from the script tag
  const challenge = JSON.parse(document.getElementById('challenge').innerText);

  // Parse the Base46 parts into Uint8Arrays
  challenge.publicKey.challenge = toUint8Array(challenge.publicKey.challenge);
  challenge.publicKey.user.id = toUint8Array(challenge.publicKey.user.id);

  // Create the passkey
  const webAuthnResponse = await navigator.credentials.create(challenge);
  console.log(webAuthnResponse);
})();
