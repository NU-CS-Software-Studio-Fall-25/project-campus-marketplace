# Project Name:
NU Campus Marketplace

## Project Description:
A platform designed for university students to buy and sell textbooks, furniture, electronics, and other things within their campus community. The marketplace would provide verified student logins to ensure trust and safety, along with features like messaging .This platform would help students save money, reduce waste, and easily connect with verified peers for reliable secondhand purchases.

# Group members:
- Ishaan Jalan
- Aryaman Chawla
- Rohan Sekhar 
- Aaron Kazi

# MVP: 
An online marketplace where users can list and buy items from each other.

## Functions:
Users should be able to create an account, enter items along with description and desired price to be listed to buyers, buyers should be able to contact sellers and negotiate/process the payments.

## Basic functionality:
- 2 models: Users and listings
- 4 views: show all listings, create new listing, show user's existing listings, show one listings
- Buyers can place bids on listings; sellers receive email alerts for new offers and can accept, reject, or counter directly from their dashboard, which emails the buyer with the outcome.


# Website:
[https://new-campus-app-f068baeccf6f.herokuapp.com/](https://northwestern-project-7264569948bb.herokuapp.com/)

## Google Sign-In configuration

Enable Google authentication by adding the following environment variables (for example in `.env` or your hosting provider's config):

- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_OAUTH_ALLOWED_DOMAIN` (optional, use to restrict logins to a specific Google Workspace domain)
- `GOOGLE_ALLOWED_EMAIL_DOMAINS` (comma-separated list, e.g. `u.northwestern.edu,northwestern.edu`; defaults to `u.northwestern.edu`)

After configuring these values, restart the Rails server. Users can then click **Continue with Google** on the sign-in screen to link an existing account or create a new one automatically.

