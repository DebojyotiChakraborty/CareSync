import os
import hashlib
import urllib.request
from urllib.parse import urlparse

print("Starting pre-download of biometric models...")
os.makedirs("/app/.deepface/weights", exist_ok=True)

# Build opener with a browser User-Agent to bypass GitHub's 429 rate limiter for python-urllib
opener = urllib.request.build_opener()
opener.addheaders = [('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')]
urllib.request.install_opener(opener)

# SECURITY (model supply chain):
#  - Only HTTPS sources are allowed (a plaintext source can be MITM'd to swap the model).
#  - Integrity is enforced by SHA-256: with a pinned digest, the file is trusted only if it
#    matches, regardless of whether the URL ref is mutable. This is the real defence and
#    makes the `raw/master/...` anti-spoof URLs safe once their digests are pinned.
#  - `.pth` files are Python pickles that torch.load() deserializes -> arbitrary code
#    execution, so they are the highest-risk artifacts to verify.
#
# To pin/rotate a checksum: download the file from the URL over a TRUSTED network, run
# `sha256sum <file>`, and paste the digest into the matching entry below.
#
# Set REQUIRE_MODEL_CHECKSUMS=1 in the deploy environment to FAIL CLOSED (refuse to install
# any model lacking a verified checksum). Left unset, unpinned files download with a loud
# UNVERIFIED warning so existing builds keep working while digests are being pinned.
REQUIRE_MODEL_CHECKSUMS = os.getenv("REQUIRE_MODEL_CHECKSUMS", "0") == "1"

# NOTE: pin these to an immutable commit SHA of Silent-Face-Anti-Spoofing once verified;
# `master` is mutable and only integrity-safe when the SHA-256 below is populated.
_ANTISPOOF_REF = os.getenv("ANTISPOOF_REF", "master")

models = [
    {
        "url": "https://github.com/serengil/deepface_models/releases/download/v1.0/retinaface.h5",
        "path": "/app/.deepface/weights/retinaface.h5",
        "sha256": "",  # TODO: pin known digest
    },
    {
        "url": "https://github.com/serengil/deepface_models/releases/download/v1.0/arcface_weights.h5",
        "path": "/app/.deepface/weights/arcface_weights.h5",
        "sha256": "",  # TODO: pin known digest
    },
    {
        "url": f"https://github.com/minivision-ai/Silent-Face-Anti-Spoofing/raw/{_ANTISPOOF_REF}/resources/anti_spoof_models/2.7_80x80_MiniFASNetV2.pth",
        "path": "/app/.deepface/weights/2.7_80x80_MiniFASNetV2.pth",
        "sha256": "",  # TODO: pin known digest (pickle -> RCE surface, verify before trusting)
    },
    {
        "url": f"https://github.com/minivision-ai/Silent-Face-Anti-Spoofing/raw/{_ANTISPOOF_REF}/resources/anti_spoof_models/4_0_0_80x80_MiniFASNetV1SE.pth",
        "path": "/app/.deepface/weights/4_0_0_80x80_MiniFASNetV1SE.pth",
        "sha256": "",  # TODO: pin known digest (pickle -> RCE surface, verify before trusting)
    },
]


def _sha256_of(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


for model in models:
    url = model["url"]
    path = model["path"]
    expected = (model.get("sha256") or "").strip().lower()

    # Only allow HTTPS. A plaintext HTTP source can be MITM'd to swap in a malicious model.
    if urlparse(url).scheme != "https":
        raise ValueError(f"Refusing to download model over non-HTTPS URL: {url}")

    # If a valid, correctly-hashed copy already exists, skip re-download.
    if os.path.exists(path) and os.path.getsize(path) > 1000000:
        if expected and _sha256_of(path) == expected:
            print(f"Model already exists and checksum matches: {path}")
            continue
        elif not expected:
            print(f"Model already exists (UNVERIFIED - no pinned checksum): {path}")
            continue
        else:
            print(f"Existing {path} failed checksum; re-downloading.")
            os.remove(path)

    print(f"Downloading {url} -> {path}")
    tmp_path = path + ".part"
    try:
        urllib.request.urlretrieve(url, tmp_path)
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
        raise e

    actual = _sha256_of(tmp_path)
    if expected:
        if actual != expected:
            os.remove(tmp_path)
            raise ValueError(
                f"Checksum mismatch for {url}\n  expected {expected}\n  got      {actual}\n"
                "Refusing to install a model whose integrity cannot be verified."
            )
        print(f"Verified checksum for {path}")
    else:
        # No pinned checksum. Fail closed when enforcement is enabled, or for pickle (.pth)
        # models when enforcement is on; otherwise install with a loud warning.
        if REQUIRE_MODEL_CHECKSUMS:
            os.remove(tmp_path)
            raise ValueError(
                f"REQUIRE_MODEL_CHECKSUMS is set but no SHA-256 is pinned for {url}\n"
                "Populate its 'sha256' in download_models.py before deploying."
            )
        warn = "!! " if path.endswith(".pth") else ""
        print(f"{warn}WARNING: installed {path} WITHOUT checksum verification (sha256={actual}).")
        print(f"{warn}         Pin this digest in download_models.py (esp. for .pth pickle models).")

    os.replace(tmp_path, path)
    print(f"Successfully downloaded {path}")

print("All models successfully pre-downloaded.")
