# Quick Privacy Policy Hosting Guide

## 🚨 CRITICAL: You NEED a public URL for Privacy Policy before App Store submission

Apple requires a **publicly accessible URL** for your Privacy Policy. Here are the fastest ways to host it:

---

## Option 1: GitHub Pages (FASTEST - 5 minutes)

### Steps:

1. **Create a new GitHub repository** (if you don't have one)
   ```bash
   # Create new repo on github.com
   Repository name: solomine-legal
   Public: Yes
   ```

2. **Create privacy policy HTML file**
   ```bash
   mkdir solomine-legal
   cd solomine-legal
   touch privacy.html
   touch terms.html
   ```

3. **Copy content to HTML files**
   - See `privacy-template.html` and `terms-template.html` below
   - Paste privacy policy content from `PrivacyPolicyView.swift`
   - Paste terms content from `TermsOfServiceView.swift`

4. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Add legal documents"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/solomine-legal.git
   git push -u origin main
   ```

5. **Enable GitHub Pages**
   - Go to repo Settings
   - Scroll to "Pages"
   - Source: main branch
   - Click Save

6. **Your URLs will be:**
   ```
   https://YOUR_USERNAME.github.io/solomine-legal/privacy.html
   https://YOUR_USERNAME.github.io/solomine-legal/terms.html
   ```

7. **Update Config.swift**
   ```swift
   static let privacyPolicyURL = "https://YOUR_USERNAME.github.io/solomine-legal/privacy.html"
   static let termsOfServiceURL = "https://YOUR_USERNAME.github.io/solomine-legal/terms.html"
   ```

---

## Option 2: Vercel (VERY FAST - 10 minutes)

### Steps:

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Create project folder**
   ```bash
   mkdir solomine-legal
   cd solomine-legal
   ```

3. **Create files**
   ```bash
   touch privacy.html
   touch terms.html
   touch index.html
   ```

4. **Deploy**
   ```bash
   vercel
   # Follow prompts
   # Choose defaults
   ```

5. **Your URLs:**
   ```
   https://solomine-legal.vercel.app/privacy.html
   https://solomine-legal.vercel.app/terms.html
   ```

---

## Option 3: Netlify Drop (EASIEST - 2 minutes)

### Steps:

1. **Go to:** https://app.netlify.com/drop

2. **Create HTML files locally** (see templates below)

3. **Drag folder into Netlify**

4. **Get URLs immediately:**
   ```
   https://random-name-12345.netlify.app/privacy.html
   https://random-name-12345.netlify.app/terms.html
   ```

5. **Optional: Custom domain**
   - Settings → Domain Management
   - Add custom domain

---

## HTML Templates

### privacy.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - Solomine</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #9BAA7F;
            border-bottom: 2px solid #9BAA7F;
            padding-bottom: 10px;
        }
        h2 {
            color: #2c3e50;
            margin-top: 30px;
        }
        h3 {
            color: #34495e;
            margin-top: 20px;
        }
        .last-updated {
            color: #7f8c8d;
            font-style: italic;
        }
        ul {
            line-height: 1.8;
        }
        a {
            color: #9BAA7F;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .contact {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 4px;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Privacy Policy</h1>
        <p class="last-updated">Last updated: February 4, 2026</p>

        <h2>Your Privacy Matters</h2>
        <p>At Solomine, we are committed to protecting your privacy and ensuring transparency about how we collect, use, and safeguard your personal information. This Privacy Policy explains our practices regarding your data when you use our platform.</p>

        <h2>1. Information We Collect</h2>
        
        <h3>1.1 Information You Provide</h3>
        <p>When you create an account or use Solomine, you may provide:</p>
        <ul>
            <li>Profile information from X (Twitter) including username, display name, profile photo, bio, and follower counts</li>
            <li>Email address</li>
            <li>Skills, portfolio links, and professional information</li>
            <li>Project requirements and descriptions</li>
            <li>Messages and communications with other users</li>
            <li>Payment information (processed securely by third-party providers)</li>
        </ul>

        <h3>1.2 Automatically Collected Information</h3>
        <p>We automatically collect certain information when you use Solomine:</p>
        <ul>
            <li>Device information (model, operating system, unique identifiers)</li>
            <li>Usage data (features accessed, time spent, interactions)</li>
            <li>Log data (IP address, browser type, access times)</li>
            <li>Location data (if you grant permission)</li>
        </ul>

        <h3>1.3 Information from Third Parties</h3>
        <ul>
            <li>Public profile data from X (Twitter) when you authenticate</li>
            <li>Public repository data from GitHub (if you link your account)</li>
            <li>Payment processing information from Stripe or other payment providers</li>
        </ul>

        <h2>2. How We Use Your Information</h2>
        <p>We use your information to:</p>
        <ul>
            <li>Provide, maintain, and improve Solomine services</li>
            <li>Create and manage your account</li>
            <li>Connect builders with clients based on skills and requirements</li>
            <li>Process payments and transactions</li>
            <li>Send notifications about platform activity and updates</li>
            <li>Respond to your support requests</li>
            <li>Prevent fraud, abuse, and security incidents</li>
            <li>Analyze usage patterns to improve user experience</li>
            <li>Comply with legal obligations</li>
        </ul>

        <h2>3. How We Share Your Information</h2>
        <p>We do not sell your personal information. We may share your information in the following circumstances:</p>

        <h3>3.1 With Other Users</h3>
        <ul>
            <li>Your profile information is visible to other users on the platform</li>
            <li>Clients can see builder profiles, skills, and social links</li>
            <li>Messages and project communications are shared between parties</li>
        </ul>

        <h3>3.2 With Service Providers</h3>
        <ul>
            <li>Cloud hosting providers (for data storage)</li>
            <li>Payment processors (for transaction handling)</li>
            <li>Analytics providers (to understand usage patterns)</li>
            <li>Email service providers (for notifications)</li>
        </ul>

        <h3>3.3 For Legal Reasons</h3>
        <ul>
            <li>To comply with laws, regulations, or legal requests</li>
            <li>To protect rights, property, or safety of Solomine or users</li>
            <li>To enforce our Terms of Service</li>
            <li>In connection with a merger, acquisition, or sale of assets</li>
        </ul>

        <h2>4. Data Retention</h2>
        <p>We retain your information for as long as necessary to provide our services and fulfill the purposes described in this policy. When you delete your account, we will delete or anonymize your personal information, except where we must retain it for legal or security purposes.</p>

        <h2>5. Your Rights and Choices</h2>
        <p>You have the following rights regarding your data:</p>
        <ul>
            <li><strong>Access:</strong> Request a copy of your personal information</li>
            <li><strong>Correction:</strong> Update or correct inaccurate information</li>
            <li><strong>Deletion:</strong> Request deletion of your account and data</li>
            <li><strong>Portability:</strong> Receive your data in a machine-readable format</li>
            <li><strong>Object:</strong> Object to certain processing activities</li>
            <li><strong>Opt-out:</strong> Unsubscribe from marketing communications</li>
        </ul>

        <h2>6. Security</h2>
        <p>We implement industry-standard security measures to protect your information, including:</p>
        <ul>
            <li>Encryption of data in transit and at rest</li>
            <li>Secure authentication with OAuth 2.0</li>
            <li>Regular security audits and monitoring</li>
            <li>Access controls and authentication requirements</li>
        </ul>
        <p>However, no system is completely secure. We cannot guarantee absolute security of your data.</p>

        <h2>7. Children's Privacy</h2>
        <p>Solomine is not intended for users under the age of 18. We do not knowingly collect information from children. If we learn that we have collected information from a child under 18, we will delete it promptly.</p>

        <h2>8. California Privacy Rights (CCPA)</h2>
        <p>If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):</p>
        <ul>
            <li>Right to know what personal information is collected</li>
            <li>Right to know if personal information is sold or disclosed</li>
            <li>Right to opt-out of sale of personal information (we do not sell)</li>
            <li>Right to deletion of personal information</li>
            <li>Right to non-discrimination for exercising CCPA rights</li>
        </ul>

        <h2>9. GDPR Rights (European Users)</h2>
        <p>If you are in the European Economic Area (EEA), you have rights under the General Data Protection Regulation (GDPR):</p>
        <ul>
            <li>Right to access your personal data</li>
            <li>Right to rectification of inaccurate data</li>
            <li>Right to erasure ("right to be forgotten")</li>
            <li>Right to restrict processing</li>
            <li>Right to data portability</li>
            <li>Right to object to processing</li>
            <li>Right to withdraw consent</li>
        </ul>

        <h2>10. Changes to This Privacy Policy</h2>
        <p>We may update this Privacy Policy from time to time. We will notify you of material changes by email or through the platform. The "Last updated" date at the top indicates when the policy was last revised.</p>

        <div class="contact">
            <h2>Contact Us</h2>
            <p>If you have questions, concerns, or requests regarding this Privacy Policy or your data, please contact us at:</p>
            <p><strong>Email:</strong> <a href="mailto:rob@solomine.io">rob@solomine.io</a></p>
            <p>We will respond to your request within 30 days.</p>
        </div>
    </div>
</body>
</html>
```

### terms.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terms of Service - Solomine</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #9BAA7F;
            border-bottom: 2px solid #9BAA7F;
            padding-bottom: 10px;
        }
        h2 {
            color: #2c3e50;
            margin-top: 30px;
        }
        .last-updated {
            color: #7f8c8d;
            font-style: italic;
        }
        ul {
            line-height: 1.8;
        }
        a {
            color: #9BAA7F;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .contact {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 4px;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Terms of Service</h1>
        <p class="last-updated">Last updated: February 4, 2026</p>

        <h2>Welcome to Solomine</h2>
        <p>These Terms of Service ("Terms") govern your access to and use of Solomine, a platform connecting independent developers and designers with clients seeking their services. By accessing or using Solomine, you agree to be bound by these Terms.</p>

        <!-- Add rest of terms content here from TermsOfServiceView.swift -->
        <!-- Follow same structure as privacy.html -->

        <div class="contact">
            <h2>Contact</h2>
            <p>If you have questions about these Terms, please contact us at:</p>
            <p><strong>Email:</strong> <a href="mailto:rob@solomine.io">rob@solomine.io</a></p>
        </div>
    </div>
</body>
</html>
```

### index.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solomine - Legal</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 40px 20px;
            background-color: #1a1a1a;
            color: #ffffff;
            text-align: center;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
        }
        h1 {
            color: #9BAA7F;
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        p {
            color: #cccccc;
            font-size: 1.1em;
        }
        .links {
            margin-top: 40px;
        }
        a {
            display: inline-block;
            margin: 10px;
            padding: 15px 30px;
            background-color: #9BAA7F;
            color: #1a1a1a;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            transition: background-color 0.3s;
        }
        a:hover {
            background-color: #b5c499;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Solomine</h1>
        <p>Where Builders Meet Opportunity</p>
        
        <div class="links">
            <a href="privacy.html">Privacy Policy</a>
            <a href="terms.html">Terms of Service</a>
        </div>
        
        <p style="margin-top: 60px; font-size: 0.9em;">
            Contact: <a href="mailto:rob@solomine.io" style="background: none; padding: 0; color: #9BAA7F;">rob@solomine.io</a>
        </p>
    </div>
</body>
</html>
```

---

## ✅ After Hosting

1. **Test URLs work:**
   ```bash
   curl -I https://YOUR-URL/privacy.html
   # Should return: HTTP/2 200
   ```

2. **Update Config.swift:**
   ```swift
   static let privacyPolicyURL = "https://YOUR-URL/privacy.html"
   static let termsOfServiceURL = "https://YOUR-URL/terms.html"
   ```

3. **Test in app:**
   - Open app
   - Go to Settings
   - Tap Privacy Policy
   - Should open in Safari

4. **Add to App Store Connect:**
   - Privacy Policy URL field
   - Paste your URL
   - Save

---

## 🚨 IMPORTANT

- URLs must be **HTTPS** (not HTTP)
- Must return **200 OK** status
- Must be **publicly accessible** (no login required)
- Must be **permanent** (don't delete after approval)

---

**Recommended:** Use GitHub Pages - it's free, reliable, and permanent!
