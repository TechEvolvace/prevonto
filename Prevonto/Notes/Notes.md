# Notes with info to know

The Prevonto app uses the provonto-backend API that is currently run in a local development environment. There is a significant name difference in the app and the API that is used for the API because the name of the API currently has a typo in regards to the name of the app that this is a backend API of ("provonto" instead of should be "prevonto"). This app is able to communicate with that API, despite the typo in the current name of the API.

## The folders in this Prevonto app

The Assets.xcassets folder contains the images and other additoinal files that are used for the app. The unique icons used for Prevonto app is stored as image files in this folder. 

The Content folder is organized to contain files for the Dashboard page, Settings page, metric pages, and other pages the user can access after they have finished onboarding for this app. 

The Data folder contains files that help define the structure of the data needed, like responses received from the API.

The Notes folder provides a place to provide notes, like this file here. 

The Onboarding folder is organized to contain files for the Welcome page, the App Intro pages, the Sign Up page, the Sign In page, the 10 onboarding pages, and those pages' associated components.

The Services folder is organized to contain files that help this app communicate with that API at the specified endpoints by making a request and then waiting for the associated response from the API.

The Color.swift file specifies the colors that are used very frequently on many pages of the app, but the colors used for only a specific page can be explicitly specified in a private Color struct in that specific file associated with that page. 


## There are some aspects of the API that currently either have bugs or are directly different from the planned design of the Prevonto app.

1) The API only supports the following steps activity metric: the step counts, the distance, and the number of active minutes. The Steps & Activity page planned design shows a display of the steps counts, the number of calories burned vs the target number of calories burned, the number of minutes moving vs the target number of minutes moving, and the number of hours standing vs the target number of hours standing. Some of the metrics planned to be displayed in Steps & Activity page according to the planned design is not supported and will not be stored by the API in its current version.

2) The API currently doesn't support or store "instructions for intake" for medications data, even though it needs to be displayed for the app.

3) The Weights Tracker page planned design shows a message about the user's BMI (BMI is determined by using the user's weight and height) being displayed. However, the planned design has no interface or pages designed for the user to specify their height, so it's not possible to give an accurate message about the user's BMI without the user's height. Additionally, the API currently doesn't support or store the user's height.

4) The API currently determines a period range to get AI-generated insights on health metrics data by taking the current time and applies the number of days back from that current time (in a variable called days_back), and then those insights are delivered to the app at the GET /api/ai/insights endpoint. The first problem is that the AI-gneerated insights will not be accurate for a specified fixed period, such as a specific day like December 25 when that specific day is not 1 day back from now. The second problem is that that making the API get AI-generated insights a few minutes apart from each other on the same day (like 12 PM and 12:05 PM today) can often get very different AI-generated insights even if no new data has been included. 

5) Same problem happens for the GET /api/ai/anomalies endpoint and for the POST /api/ai/analyze endpoint as mentioned in Problem #4 because the API uses the same days_back method.

6) The API stores refresh tokens using "randomized encryption", which simply means that the same refresh token will look different every time it's encrypted by this "randomized encryption", making it impossible for the database to find and match that refresh token later. The result is the API will always return a 401 Unauthorized error when the valid, not-expired refresh token is sent to the API to get a new access token.

7) The API refers to metrics spelled out in two or more words with underscores (such as blood_glucose for blood glucose), and it uses that spelling for referring to the metrics in a highlight or insight. An example of a highlight from the API is "Unusual blood_glucose reading detected" under the highlights section in the Blood Glucose page, and this message here is in that exact response from the API. So, the unusual spelling of metrics with underscores instead of spaces is directly because of the API and not of the app.