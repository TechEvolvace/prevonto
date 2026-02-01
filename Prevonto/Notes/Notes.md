# Notes 

The Prevonto App uses the provonto-backend API, which is currently run in a local development environment. The name of the API currently has a typo in regards to the name of the app that it is a backend API of (“provonto” instead of should be “prevonto”), but that’s the current name of the API there and this app is able to communicate with that API.

## About many of the folders in this app

The Assets.xcassets folder contains images and other additional files that are used for the app.

The Content folder contains files for the Dashboard page, Settings page, metric pages, and other pages the user can access after they finished onboarding.

The Data folder contains files that helps define the structure of the data needed, such as responses received from the API.

The Notes folder provides a place to provide notes, like this file here.

The Onboarding folder contains files for the Welcome page, the App Intro Pages, the Sign Up page, the Sign In page,  the 10 Onboarding Pages, and those pages' associated components.

The Services folder contains files that help this app communicate with that API at the specified endpoints by making a request and waiting for the assocaited response from the API.

The colors used very frequently on many pages of the app are in Color.swift file, but the colors used for a specific page can be explicitly specified in a private Color struct in that specific file associated with that page.

## There are some aspects of the API that currently either have bugs or are directly different from the planned design of the Prevonto app.

1) The steps activity metric data the API only supports are the step counts, the distance, and the number of active minutes. The Steps & Activity page planned design shows the steps counts, the number of calories burned vs the target number of calories burned, the number of minutes moving vs the target number of minutes moving, and the number of hours standing vs the target number of hours standing. Which one will it be then? 

2) The API currently doesn’t support “instructions for intake” for medications data, even though it needs to be displayed for the app.

3) The API takes the current time and applies the number of days back from that current time (variable days_back) that will be the period range to get AI-generated insights on the health metrics data to deliver to the app at the GET /api/ai/insights endpoint. The first problem is that the AI-generated insights will not be accurate for a specified fixed period, such as a specific day like December 25 when that specific day is not 1 day back from now. The second problem is that making the API get AI-generated insights a few minutes apart from each other on the same day (like 12 PM and 12:05 PM today) can often get very different AI-generated insights.

4) Same problem as #3 for the GET /api/ai/anomalies endpoint and for the POST /api/ai/analyze endpoint because of the API using the same days_back method. 

5) The API stores refresh tokens using “randomized encryption”, which means the same refresh token looks different every time it’s encrypted, making it impossible for the database to find and match it later. The result is the API always returns a 401 Unauthorized error when the valid, not-expired refresh token is sent to the API to get a new access token.