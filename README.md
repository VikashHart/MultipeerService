# MultipeerService

The MultipeerService package separates the download and sharing services into their own respective files for less bloated code and allows for more streamline use of the library through the use of delegation.

## Minimum Version

iOS v8 (8.0.0)

### Implementation

- In order to use this package first make sure that you have the minimum version required.
- You will need to create instances of the "DownloadService" and "SharingService" in the files that will be using them.
- Make sure to have your class(es) conform to the "DownloadServiceDelegate" and "SharingServiceDelegate" methods respectively.
