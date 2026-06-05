# 🔒 SSL Certificate Issue - Root Cause Analysis & Backend Fix

## 📋 Executive Summary

**Issue**: Flutter app fails to connect with: `CERTIFICATE_VERIFY_FAILED: Hostname mismatch`

**Root Cause**: Backend SSL certificate CN/SAN does NOT match domain `backend.gyaanplant.com`

**Location**: Server-side (NOT frontend code)

**Severity**: Production blocker - HTTPS connections fail

---

## 🔍 Frontend Analysis: ✅ CONFIRMED CORRECT

### URLs are properly configured
```dart
// File: lib/network/app_constants.dart (primary)
static const String baseUrl = 'https://backend.gyaanplant.com';

// File: .env (backup)
BASE_URL=https://backend.gyaanplant.com

// File: lib/config/api_config.dart (legacy)
static const String baseUrl = "https://backend.gyaanplant.com";
```

**Conclusion**: Frontend is using the CORRECT domain consistently. Frontend code is NOT the issue.

### Dio SSL Verification: Standard & Correct
```dart
// File: lib/network/api_manager.dart (lines 41-68)
_dio = Dio(BaseOptions(
  baseUrl: _config.baseUrl,
  // ... other options
));
// No custom SSL bypasses in PRODUCTION builds
```

**Conclusion**: Dio uses standard HTTPS verification (correct for production).

---

## ❌ Backend Problem: Certificate Hostname Mismatch

### Error Details from Flutter Logs
```
DioException [unknown]: null
Error: HandshakeException: Handshake error in client (OS Error: 
      CERTIFICATE_VERIFY_FAILED: Hostname mismatch(handshake.cc:298))
```

### What This Means

The server at `backend.gyaanplant.com` is presenting an SSL certificate that:

1. ✅ **Valid for a DIFFERENT hostname** (not `backend.gyaanplant.com`)
2. ✅ **Certificate CN or SAN fields don't include** `backend.gyaanplant.com`
3. ✅ **Example misconfigurations**:
   - Cert issued for `gyaanplant.com` (missing `backend.` subdomain)
   - Cert issued for `api.gyaanplant.com` (wrong subdomain)
   - Cert issued for `*.gyaanplant.com` but SAN doesn't include wildcard properly
   - Self-signed certificate with custom hostname

### How to Verify (Run on Backend Server)

```bash
# Check certificate details
openssl s_client -connect backend.gyaanplant.com:443 -showcerts

# Look for the CN (Common Name) field in the certificate output
# Example WRONG:
#   Subject: CN = gyaanplant.com        ❌ Missing 'backend.'
#   Subject: CN = api.gyaanplant.com   ❌ Wrong subdomain

# Example CORRECT:
#   Subject: CN = backend.gyaanplant.com ✅
#   Subject Alt Name: backend.gyaanplant.com ✅
```

---

## ✅ Backend Configuration: What Must Be Fixed

### Option 1: Let's Encrypt / Valid SSL Certificate (RECOMMENDED)

**For nginx/apache reverse proxy:**

```bash
# Using Certbot (Let's Encrypt)
sudo certbot certonly --nginx -d backend.gyaanplant.com

# This generates:
# - Certificate: /etc/letsencrypt/live/backend.gyaanplant.com/fullchain.pem
# - Private Key: /etc/letsencrypt/live/backend.gyaanplant.com/privkey.pem
```

**Nginx configuration:**
```nginx
server {
    listen 443 ssl http2;
    server_name backend.gyaanplant.com;  # ✅ Exact match required

    # Path to certificate - MUST be for backend.gyaanplant.com
    ssl_certificate /etc/letsencrypt/live/backend.gyaanplant.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/backend.gyaanplant.com/privkey.pem;

    # Security headers
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://localhost:5000;  # Backend API
    }
}
```

**Apache configuration:**
```apache
<VirtualHost *:443>
    ServerName backend.gyaanplant.com  # ✅ Exact match required
    
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/backend.gyaanplant.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/backend.gyaanplant.com/privkey.pem
    
    ProxyPreserveHost On
    ProxyPass / http://localhost:5000/
</VirtualHost>
```

---

### Option 2: Wildcard Certificate (if you have multiple subdomains)

**Certificate must be issued for**: `*.gyaanplant.com`

**Nginx:**
```nginx
server {
    listen 443 ssl http2;
    server_name backend.gyaanplant.com;
    
    ssl_certificate /path/to/wildcard.gyaanplant.com/fullchain.pem;
    ssl_certificate_key /path/to/wildcard.gyaanplant.com/privkey.pem;
    # ... rest of config
}
```

---

### Option 3: Multi-domain Certificate (SAN)

If you need multiple specific domains, use Subject Alt Name (SAN):

**Certificate CN**: `backend.gyaanplant.com`
**SAN entries**: `backend.gyaanplant.com`, `api.gyaanplant.com`, `admin.gyaanplant.com`

---

## 🛑 Common Mistakes to Avoid

| ❌ WRONG | ✅ CORRECT |
|----------|----------|
| Cert for `gyaanplant.com` | Cert for `backend.gyaanplant.com` |
| Using `api.gyaanplant.com` cert | Certificate must match exactly |
| Self-signed without matching CN | Use Let's Encrypt for free certs |
| Expired certificate | Keep certs renewed (auto-renewal recommended) |
| Mismatched domain in DNS | Ensure `backend.gyaanplant.com` → server IP is correct |

---

## 🔧 Frontend Development Workaround (Temporary)

**Status**: Already applied to [lib/network/api_manager.dart](../lib/network/api_manager.dart)

**For DEBUG mode only** (not production):
```dart
// This accepts invalid certificates in debug builds
if (kDebugMode) {
  (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
}
```

⚠️ **This is ONLY for development testing while backend SSL is being fixed**

---

## 📝 Checklist for Backend Team

- [ ] Verify current SSL certificate domain (run `openssl s_client` command above)
- [ ] Identify which certificate is currently deployed
- [ ] Generate new certificate for `backend.gyaanplant.com` (Let's Encrypt recommended)
- [ ] Update nginx/apache config with correct certificate paths
- [ ] Reload web server (`systemctl reload nginx` / `systemctl reload apache2`)
- [ ] Verify certificate is valid with Chrome (should show 🔒 lock)
- [ ] Test from browser: `https://backend.gyaanplant.com` should load without warning
- [ ] Test Flutter app: Should connect successfully
- [ ] Set up auto-renewal for certificate (Certbot handles this)

---

## ✔️ Verification After Fix

**From Command Line:**
```bash
openssl s_client -connect backend.gyaanplant.com:443 -showcerts | grep -A2 "Subject:"
# Should show: Subject: ... CN = backend.gyaanplant.com
```

**From Browser:**
1. Navigate to `https://backend.gyaanplant.com`
2. Should NOT show "Your connection is not private"
3. Click 🔒 lock → "Certificate" should show `backend.gyaanplant.com`

**From Flutter App:**
1. Run app with latest code
2. Dashboard should load without SSL errors
3. Check logs: should NOT see `CERTIFICATE_VERIFY_FAILED`

---

## 📚 Resources

- [Let's Encrypt - Certbot](https://certbot.eff.org/)
- [Nginx SSL Configuration](https://nginx.org/en/docs/http/ngx_http_ssl_module.html)
- [Apache SSL Configuration](https://httpd.apache.org/docs/2.4/ssl/ssl_howto.html)
- [Android Network Security Config](https://developer.android.com/training/articles/security-config)

---

## ❓ Questions?

This is a **server-side SSL certificate issue**, not an app issue. Contact your DevOps/Backend team to regenerate the SSL certificate for the correct domain.

**Issue Origin**: Server certificate misconfiguration
**Solution**: Regenerate SSL certificate with CN/SAN = `backend.gyaanplant.com`
