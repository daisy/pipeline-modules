To use Google Cloud Text-to-Speech (https://cloud.google.com/text-to-speech/docs/quickstart-client-libraries)

1. In Cloud Console (https://console.cloud.google.com), on the project selection page, select or create a Cloud project.

2. Make sure billing is turned on for your Google Cloud project.

3. Activate APICloud Text-to-Speech.

4. Configure authentication :

    a. In Cloud Console, go to the Create Service Account Key page. 

    b. From the Service Account list, select New Service Account.

    c. In the Service account name field, enter a name.

    d. Do not select a value from the Role list. No role is required to access this service.

    e. Click on Create. A note is displayed to indicate that this service account is not associated with any role.

    f. Click Create without role. A JSON file containing your key is downloaded to your computer.

5. Set the GOOGLE_APPLICATION_CREDENTIALS environment variable to point to the path to the JSON file containing your service account key. This variable only applies to the current shell session. Therefore, if you open a new session, you must define it again.

    Linux or macOs :
    Replace [PATH] with the path to the JSON file containing your service account key.
        export GOOGLE_APPLICATION_CREDENTIALS="[PATH]"
    
    Windows :
    Replace [PATH] with the path to the JSON file containing your service account key and [FILE_NAME] with the name of the file.
        With PowerShell :
        $env:GOOGLE_APPLICATION_CREDENTIALS="[PATH]"
        With the command prompt:
        set GOOGLE_APPLICATION_CREDENTIALS=[PATH]

Or indicate the path to the JSON file containing your service account key as an option command.


6. Install and initialize the Cloud SDK.