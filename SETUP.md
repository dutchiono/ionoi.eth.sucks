# Setup Guide

## GitHub Pages Setup

1. Go to: https://github.com/dutchiono/ionoi.eth.sucks/settings/pages
2. Under "Source", select **GitHub Actions**
3. Save

Your site will be live at: **https://dutchiono.github.io/ionoi.eth.sucks**

## ENS Domain Setup (IPFS Content Hash)

Since `.eth.sucks` and `.eth.limo` domains only work with IPFS content hashes, we'll create a redirect page on IPFS:

1. **Upload redirect page to IPFS:**
   - Use Pinata, Infura, or any IPFS service
   - Upload the `redirect.html` file from this repo
   - Get the IPFS CID (e.g., `Qm...`)

2. **Set Content Hash in ENS:**
   - Go to: https://app.ens.domains
   - Connect your wallet (the one that owns `ionoi.eth.sucks`)
   - Search for `ionoi.eth.sucks` and select it
   - Click on the **Records** tab
   - Go to **Other** tab
   - Find **Content Hash**
   - Set it to: `/ipfs/YOUR_CID_HERE` (e.g., `/ipfs/Qm...`)
   - Click **Save** and confirm the transaction

3. **Alternative: Use Pinata:**
   ```bash
   # If you have Pinata CLI or use their web interface
   # Upload redirect.html and get the CID
   ```

**Note:** The redirect page will automatically send visitors to your GitHub Pages site. This works for `.eth.sucks` and `.eth.limo` domains that require IPFS content hashes.

## Deploying Updates

Just push to `main` branch:
```bash
git add .
git commit -m "Your update message"
git push
```

GitHub Actions will automatically deploy. Updates go live in 1-2 minutes.

