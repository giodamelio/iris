(async () => {
  if (
    typeof window.PublicKeyCredential === 'undefined'
    || typeof window.PublicKeyCredential.isConditionalMediationAvailable !== 'function'
  ) {
    console.log('No Passkey Support');
    return;
  }

  const available = await PublicKeyCredential.isConditionalMediationAvailable();
  // Example challenge and user ID bytes (These should be randomly generated and provided by your server in a real application)
  const challengeBytes = new Uint8Array([211, 25, 178, 35, 112, 217, 96, 183, 225, 213, 120, 123, 210, 45, 224, 99]);
  const userIdBytes = new Uint8Array([85, 90, 83, 76, 56, 53, 84, 57, 65, 70, 67]); // This is just a sample; use a meaningful user ID in practice
  const publicKeyCredentialCreationOptions = {
    challenge: challengeBytes,
    rp: {
      name: "Testing",
      id: "localhost",
    },
    user: {
      id: userIdBytes,
      name: "gio@damelio.net",
      displayName: "Giovanni d'Amelio",
    },
    pubKeyCredParams: [{alg: -7, type: "public-key"}, {alg: -8, type: "public-key"}, {alg: -257, type: "public-key"}],
    authenticatorSelection: {
      authenticatorAttachment: "cross-platform",
    },
    timeout: 60000,
    attestation: "direct"
  };

  if (available) {
    try {
      console.log("HERE!!!");
      // Retrieve authentication options for `navigator.credentials.get()`
      // from your server.
      // const authOptions = await getAuthenticationOptions();
      // This call to `navigator.credentials.get()` is "set and forget."
      // The Promise will only resolve if the user successfully interacts
      // with the browser's autofill UI to select a passkey.
      const webAuthnResponse = await navigator.credentials.create({
        publicKey: {
          ...publicKeyCredentialCreationOptions,
          // see note about userVerification below
          // userVerification: "preferred",
        }
      });

      console.log("HERE?");
      console.log(webAuthnResponse);
    } catch (err) {
      console.error('Error with conditional UI:', err);
    }
  }
})();
