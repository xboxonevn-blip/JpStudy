const firebaseSdkVersion = "12.12.0";
window.flutterfire_web_sdk_version = firebaseSdkVersion;

async function preloadFirebaseSdk() {
  const base = `https://www.gstatic.com/firebasejs/${firebaseSdkVersion}`;
  const [firebaseCore, firebaseAuth, firebaseStorage, firebaseAnalytics] =
    await Promise.all([
      import(`${base}/firebase-app.js`),
      import(`${base}/firebase-auth.js`),
      import(`${base}/firebase-storage.js`),
      import(`${base}/firebase-analytics.js`),
    ]);

  window.firebase_core = firebaseCore;
  window.firebase_auth = firebaseAuth;
  window.firebase_storage = firebaseStorage;
  window.firebase_analytics = firebaseAnalytics;
}

function setAccessibleViewport() {
  let viewport = document.querySelector('meta[name="viewport"]');
  if (!viewport) {
    viewport = document.createElement("meta");
    viewport.name = "viewport";
    document.head.appendChild(viewport);
  }
  viewport.content = "width=device-width, initial-scale=1.0";
}

window.setAccessibleViewport = setAccessibleViewport;

function wireA11yNavigation() {
  document.querySelectorAll(".jpstudy-a11y-nav [data-route]").forEach((item) => {
    item.addEventListener("click", () => {
      window.location.hash = item.getAttribute("data-route") || "/";
    });
  });
}

function loadFlutterBootstrap() {
  setAccessibleViewport();
  wireA11yNavigation();
  const script = document.createElement("script");
  script.src = "flutter_bootstrap.js";
  script.async = true;
  document.body.appendChild(script);
}

preloadFirebaseSdk()
  .catch((error) => {
    console.warn(
      "Firebase SDK preload failed; cloud features may be unavailable.",
      error,
    );
  })
  .finally(loadFlutterBootstrap);
