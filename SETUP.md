# Setup Guide

## GitHub Pages Setup

1. Go to: https://github.com/dutchiono/ionoi.eth.sucks/settings/pages
2. Under "Source", select **GitHub Actions**
3. Save

Your site will be live at: **https://dutchiono.github.io/ionoi.eth.sucks**

## ENS Domain Setup

1. Go to: https://app.ens.domains
2. Connect your wallet
3. Search for `ionoi.eth.sucks`
4. Go to **Records** tab
5. Add a **Text Record**:
   - **Name:** `website`
   - **Value:** `https://dutchiono.github.io/ionoi.eth.sucks`
6. Save and confirm transaction

## Deploying Updates

Just push to `main` branch:
```bash
git add .
git commit -m "Your update message"
git push
```

GitHub Actions will automatically deploy. Updates go live in 1-2 minutes.

