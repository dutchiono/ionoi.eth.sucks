# Upload redirect.html to IPFS

## Option 1: Pinata Web Interface (Easiest)

1. Go to: https://pinata.cloud
2. Sign in to your account
3. Click **Upload** → **File**
4. Upload `redirect.html`
5. Copy the **CID** (starts with `Qm...` or `bafy...`)

## Option 2: Pinata CLI

```bash
# Install Pinata CLI (if not already installed)
npm install -g @pinata/cli

# Authenticate
pinata auth

# Upload the file
pinata pin-file redirect.html
```

## Option 3: Local IPFS Node

```bash
# If you have IPFS installed locally
ipfs add redirect.html

# This will give you a CID like: Qm...
```

## After Getting the CID

1. Go to ENS app: https://app.ens.domains
2. Set Content Hash to: `/ipfs/YOUR_CID_HERE`
3. Save and confirm transaction

The redirect page will automatically send visitors to your GitHub Pages site.

